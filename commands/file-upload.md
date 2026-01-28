# File Upload Skill

파일 업로드 처리 가이드를 실행합니다.

## 업로드 방식

### 직접 업로드
```
Client → Server → Storage

단순하지만 서버 부하 발생
```

### Presigned URL (권장)
```
1. Client → Server: 업로드 요청
2. Server → Client: Presigned URL 발급
3. Client → S3: 직접 업로드
4. Client → Server: 업로드 완료 알림

서버 부하 없음, 대용량 파일에 적합
```

## Presigned URL 구현

### S3 Presigned URL 발급
```javascript
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');

const s3 = new S3Client({ region: 'ap-northeast-2' });

async function getUploadUrl(filename, contentType) {
  const key = `uploads/${Date.now()}-${filename}`;

  const command = new PutObjectCommand({
    Bucket: 'my-bucket',
    Key: key,
    ContentType: contentType,
  });

  const url = await getSignedUrl(s3, command, { expiresIn: 3600 });

  return { url, key };
}

// API 엔드포인트
app.post('/api/upload/presign', async (req, res) => {
  const { filename, contentType } = req.body;

  // 검증
  if (!isAllowedType(contentType)) {
    return res.status(400).json({ error: 'Invalid file type' });
  }

  const { url, key } = await getUploadUrl(filename, contentType);
  res.json({ uploadUrl: url, key });
});
```

### 클라이언트 업로드
```javascript
async function uploadFile(file) {
  // 1. Presigned URL 요청
  const { uploadUrl, key } = await fetch('/api/upload/presign', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type,
    }),
  }).then(r => r.json());

  // 2. S3에 직접 업로드
  await fetch(uploadUrl, {
    method: 'PUT',
    body: file,
    headers: { 'Content-Type': file.type },
  });

  // 3. 서버에 완료 알림
  await fetch('/api/upload/complete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ key }),
  });

  return key;
}
```

## 직접 업로드 구현

### Multer (Node.js)
```javascript
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    const uniqueName = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
    cb(null, uniqueName + path.extname(file.originalname));
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/gif'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  },
});

app.post('/api/upload', upload.single('file'), (req, res) => {
  res.json({
    filename: req.file.filename,
    url: `/uploads/${req.file.filename}`,
  });
});

// 다중 파일
app.post('/api/upload/multiple', upload.array('files', 10), (req, res) => {
  res.json({ files: req.files.map(f => f.filename) });
});
```

### S3 업로드 (서버 경유)
```javascript
const { Upload } = require('@aws-sdk/lib-storage');

const uploadToS3 = multer({ storage: multer.memoryStorage() });

app.post('/api/upload/s3', uploadToS3.single('file'), async (req, res) => {
  const upload = new Upload({
    client: s3,
    params: {
      Bucket: 'my-bucket',
      Key: `uploads/${Date.now()}-${req.file.originalname}`,
      Body: req.file.buffer,
      ContentType: req.file.mimetype,
    },
  });

  const result = await upload.done();
  res.json({ url: result.Location });
});
```

## 대용량 파일 (Multipart)

### S3 Multipart Upload
```javascript
const {
  CreateMultipartUploadCommand,
  UploadPartCommand,
  CompleteMultipartUploadCommand,
} = require('@aws-sdk/client-s3');

async function multipartUpload(file, key) {
  // 1. 시작
  const { UploadId } = await s3.send(new CreateMultipartUploadCommand({
    Bucket: 'my-bucket',
    Key: key,
  }));

  // 2. 청크 업로드
  const chunkSize = 5 * 1024 * 1024; // 5MB
  const parts = [];

  for (let i = 0; i * chunkSize < file.size; i++) {
    const start = i * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);

    const { ETag } = await s3.send(new UploadPartCommand({
      Bucket: 'my-bucket',
      Key: key,
      UploadId,
      PartNumber: i + 1,
      Body: chunk,
    }));

    parts.push({ PartNumber: i + 1, ETag });
  }

  // 3. 완료
  await s3.send(new CompleteMultipartUploadCommand({
    Bucket: 'my-bucket',
    Key: key,
    UploadId,
    MultipartUpload: { Parts: parts },
  }));
}
```

## 이미지 처리

### Sharp (리사이징)
```javascript
const sharp = require('sharp');

async function processImage(buffer, options) {
  return sharp(buffer)
    .resize(options.width, options.height, {
      fit: 'cover',
      position: 'center',
    })
    .jpeg({ quality: 80 })
    .toBuffer();
}

app.post('/api/upload/image', uploadToS3.single('file'), async (req, res) => {
  // 원본
  const original = await uploadToS3(req.file.buffer, 'original');

  // 썸네일 생성
  const thumbnail = await processImage(req.file.buffer, {
    width: 200,
    height: 200,
  });
  const thumbUrl = await uploadToS3(thumbnail, 'thumb');

  res.json({ original, thumbnail: thumbUrl });
});
```

## 보안

### 검증
```javascript
const fileType = require('file-type');

async function validateFile(buffer, declaredType) {
  // Magic number 검증
  const detected = await fileType.fromBuffer(buffer);

  if (!detected || detected.mime !== declaredType) {
    throw new Error('File type mismatch');
  }

  // 허용된 타입만
  const allowed = ['image/jpeg', 'image/png', 'application/pdf'];
  if (!allowed.includes(detected.mime)) {
    throw new Error('File type not allowed');
  }

  return true;
}
```

### 바이러스 스캔
```javascript
const ClamScan = require('clamscan');

const clam = await new ClamScan().init({
  clamdscan: { host: 'localhost', port: 3310 },
});

async function scanFile(filePath) {
  const { isInfected, viruses } = await clam.scanFile(filePath);

  if (isInfected) {
    throw new Error(`Virus detected: ${viruses.join(', ')}`);
  }
}
```

## 체크리스트

### 보안
- [ ] 파일 타입 검증 (Magic number)
- [ ] 파일 크기 제한
- [ ] 파일명 sanitize
- [ ] 바이러스 스캔 (선택)

### 성능
- [ ] Presigned URL 사용
- [ ] CDN 연동
- [ ] 이미지 최적화/리사이징

### 안정성
- [ ] 업로드 진행률 표시
- [ ] 재시도 로직
- [ ] 에러 처리

## 출력 형식

```
## File Upload Design

### Strategy
- 방식: [Presigned URL/직접 업로드]
- 저장소: [S3/로컬/etc]

### API Endpoints
```
POST /api/upload/presign
POST /api/upload/complete
```

### Implementation
```javascript
// 핵심 코드
```

### Security Measures
- 파일 타입: [허용 목록]
- 최대 크기: [제한]
- 검증: [Magic number]
```

---

요청에 맞는 파일 업로드를 설계하세요.

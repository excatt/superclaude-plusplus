# Backup & Recovery Skill

백업 및 복구 전략 가이드를 실행합니다.

## 백업 유형

### Full Backup
```
전체 데이터 복사
- 복구 단순
- 시간/공간 많이 소요
- 주기: 주간
```

### Incremental Backup
```
마지막 백업 이후 변경분만
- 빠름, 저장 공간 적음
- 복구 시 전체 체인 필요
- 주기: 일간
```

### Differential Backup
```
마지막 Full 이후 변경분
- Incremental과 Full의 중간
- 복구 시 Full + 마지막 Differential
- 주기: 일간
```

## 3-2-1 백업 규칙

```
3개의 복사본
├── 원본
├── 로컬 백업
└── 오프사이트 백업

2개의 다른 미디어
├── 디스크
└── 클라우드/테이프

1개는 오프사이트
└── 다른 리전/물리적 위치
```

## 데이터베이스 백업

### PostgreSQL
```bash
# 논리적 백업 (pg_dump)
pg_dump -h localhost -U user -d mydb -F c -f backup.dump

# 전체 클러스터 백업
pg_dumpall -h localhost -U user > all_databases.sql

# 복구
pg_restore -h localhost -U user -d mydb backup.dump

# 연속 아카이빙 (Point-in-Time Recovery)
# postgresql.conf
archive_mode = on
archive_command = 'cp %p /archive/%f'
```

### MySQL
```bash
# 논리적 백업
mysqldump -u user -p mydb > backup.sql

# 물리적 백업 (Percona XtraBackup)
xtrabackup --backup --target-dir=/backup/

# 복구
mysql -u user -p mydb < backup.sql
```

### MongoDB
```bash
# 덤프
mongodump --uri="mongodb://localhost:27017/mydb" --out=/backup/

# 복구
mongorestore --uri="mongodb://localhost:27017/mydb" /backup/mydb/
```

## 파일 시스템 백업

### rsync
```bash
# 증분 동기화
rsync -avz --delete /source/ /backup/

# 원격 백업
rsync -avz -e ssh /source/ user@remote:/backup/

# 제외 패턴
rsync -avz --exclude='*.log' --exclude='node_modules' /source/ /backup/
```

### 스냅샷
```bash
# AWS EBS 스냅샷
aws ec2 create-snapshot --volume-id vol-xxx --description "Daily backup"

# LVM 스냅샷
lvcreate -L 10G -s -n snap_data /dev/vg/data
```

## 클라우드 백업

### AWS S3
```bash
# AWS CLI
aws s3 sync /local/path s3://bucket/backup/

# 버전 관리 활성화
aws s3api put-bucket-versioning \
  --bucket my-bucket \
  --versioning-configuration Status=Enabled

# 수명주기 정책
{
  "Rules": [{
    "ID": "Archive old backups",
    "Status": "Enabled",
    "Transitions": [{
      "Days": 30,
      "StorageClass": "GLACIER"
    }],
    "Expiration": {
      "Days": 365
    }
  }]
}
```

### 자동화 스크립트
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"
S3_BUCKET="s3://my-backups"

# 데이터베이스 백업
pg_dump -Fc mydb > "$BACKUP_DIR/db_$DATE.dump"

# 파일 백업
tar -czf "$BACKUP_DIR/files_$DATE.tar.gz" /app/uploads/

# S3 업로드
aws s3 cp "$BACKUP_DIR/db_$DATE.dump" "$S3_BUCKET/db/"
aws s3 cp "$BACKUP_DIR/files_$DATE.tar.gz" "$S3_BUCKET/files/"

# 로컬 정리 (7일 이상)
find "$BACKUP_DIR" -type f -mtime +7 -delete

# 알림
echo "Backup completed: $DATE" | mail -s "Backup Status" admin@example.com
```

## 복구 절차

### RTO & RPO
```
RPO (Recovery Point Objective)
= 허용 가능한 데이터 손실 시간
= 백업 주기 결정

RTO (Recovery Time Objective)
= 허용 가능한 복구 시간
= 복구 전략 결정
```

### 복구 계획 템플릿
```markdown
## 장애 시나리오: 데이터베이스 손상

### 감지
- 알림: DB 연결 실패 알림 수신
- 확인: 로그 확인, 데이터 무결성 검사

### 대응 단계
1. [ ] 장애 공지 (상태 페이지 업데이트)
2. [ ] 최신 백업 확인
3. [ ] 새 DB 인스턴스 생성
4. [ ] 백업에서 복구
5. [ ] 데이터 검증
6. [ ] 애플리케이션 연결 전환
7. [ ] 모니터링 강화
8. [ ] 사후 분석 (Post-mortem)

### 예상 시간
- 감지 → 대응 시작: 5분
- 복구 완료: 30분
- 검증 완료: 45분
- 총 RTO: 1시간
```

## 복구 테스트

### 정기 테스트
```bash
#!/bin/bash
# test_restore.sh

# 1. 테스트 환경 생성
docker run -d --name test-db postgres:15

# 2. 최신 백업으로 복구
aws s3 cp s3://my-backups/db/latest.dump /tmp/
pg_restore -h localhost -p 5433 -d testdb /tmp/latest.dump

# 3. 데이터 검증
psql -h localhost -p 5433 -d testdb -c "SELECT COUNT(*) FROM users;"

# 4. 정리
docker rm -f test-db

# 5. 결과 보고
echo "Restore test completed successfully" | mail -s "Restore Test" admin@example.com
```

### 테스트 체크리스트
```
- [ ] 월간 복구 테스트 수행
- [ ] 복구 시간 측정
- [ ] 데이터 무결성 확인
- [ ] 문서 최신화
- [ ] 담당자 교육
```

## 재해 복구 (DR)

### DR 전략
```
Cold Site
- 최소 인프라만 준비
- RTO: 24시간+
- 비용: 낮음

Warm Site
- 부분적 인프라 가동
- RTO: 4-24시간
- 비용: 중간

Hot Site
- 완전 복제 환경
- RTO: 분 단위
- 비용: 높음
```

### 멀티 리전
```
Primary (us-east-1)      Secondary (eu-west-1)
┌─────────────────┐      ┌─────────────────┐
│   Application   │      │   Application   │
│   Database      │ ───→ │   Database      │
│   (Read/Write)  │ Sync │   (Read Only)   │
└─────────────────┘      └─────────────────┘

Failover 시 Secondary를 Primary로 승격
```

## 체크리스트

### 백업 구성
- [ ] 백업 스케줄 설정
- [ ] 보존 정책 정의
- [ ] 암호화 적용
- [ ] 오프사이트 저장

### 복구 준비
- [ ] 복구 절차 문서화
- [ ] 정기 복구 테스트
- [ ] RTO/RPO 정의
- [ ] 담당자 지정

### 모니터링
- [ ] 백업 성공/실패 알림
- [ ] 저장 공간 모니터링
- [ ] 백업 무결성 검증

## 출력 형식

```
## Backup & Recovery Strategy

### Backup Schedule
| 유형 | 주기 | 보존 | 저장소 |
|------|------|------|--------|
| Full | 주간 | 4주 | S3 Glacier |
| Incremental | 일간 | 7일 | S3 Standard |

### RPO/RTO
- RPO: 24시간 (일간 백업)
- RTO: 4시간

### Recovery Procedures
1. [시나리오별 복구 절차]

### Test Schedule
- 월간: 복구 테스트
- 분기: DR 훈련
```

---

요청에 맞는 백업 및 복구 전략을 설계하세요.

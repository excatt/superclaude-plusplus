# Auth Skill

인증/인가 설계를 위한 가이드를 실행합니다.

## 인증 vs 인가

```
인증 (Authentication): "누구인가?" - 신원 확인
인가 (Authorization):  "무엇을 할 수 있나?" - 권한 확인
```

## 인증 방식 비교

| 방식 | 장점 | 단점 | 적합한 경우 |
|-----|------|------|-----------|
| Session | 간단, 서버 제어 | 스케일링 어려움 | 전통적 웹앱 |
| JWT | Stateless, 확장성 | 토큰 무효화 어려움 | MSA, API |
| Passkey | 최고 보안, UX | 브라우저 지원 | 현대적 앱 |
| OAuth 2.0 | 소셜 로그인 | 복잡성 | 서드파티 연동 |

## Passkey / WebAuthn (2024 권장)

### 개념
```
Passkey = FIDO2 + WebAuthn
- 비밀번호 없는 인증
- 생체인식/PIN 사용
- 피싱 방지 내장
- 크로스 디바이스 동기화
```

### 등록 플로우
```javascript
// 서버: 챌린지 생성
const options = await generateRegistrationOptions({
  rpName: 'My App',
  rpID: 'example.com',
  userID: user.id,
  userName: user.email,
  attestationType: 'none',
  authenticatorSelection: {
    residentKey: 'preferred',
    userVerification: 'preferred',
  },
});

// 클라이언트: Passkey 생성
const credential = await navigator.credentials.create({
  publicKey: options
});

// 서버: 검증 및 저장
const verification = await verifyRegistrationResponse({
  response: credential,
  expectedChallenge: options.challenge,
  expectedOrigin: 'https://example.com',
  expectedRPID: 'example.com',
});
```

### 인증 플로우
```javascript
// 서버: 인증 옵션 생성
const options = await generateAuthenticationOptions({
  rpID: 'example.com',
  allowCredentials: user.credentials.map(c => ({
    id: c.credentialID,
    type: 'public-key',
  })),
});

// 클라이언트: Passkey 사용
const credential = await navigator.credentials.get({
  publicKey: options
});

// 서버: 검증
const verification = await verifyAuthenticationResponse({
  response: credential,
  expectedChallenge: options.challenge,
  expectedOrigin: 'https://example.com',
  expectedRPID: 'example.com',
  authenticator: storedCredential,
});
```

### 라이브러리
```bash
# Node.js
npm install @simplewebauthn/server @simplewebauthn/browser

# Python
pip install py-webauthn
```

## JWT 기반 (개선된 패턴)

### Access + Refresh Token
```javascript
// 토큰 생성
function generateTokens(user) {
  const accessToken = jwt.sign(
    { sub: user.id, type: 'access' },
    process.env.JWT_ACCESS_SECRET,
    { expiresIn: '15m', algorithm: 'RS256' }
  );

  const refreshToken = jwt.sign(
    { sub: user.id, type: 'refresh', jti: crypto.randomUUID() },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '7d', algorithm: 'RS256' }
  );

  return { accessToken, refreshToken };
}

// Refresh Token Rotation
async function refreshAccessToken(refreshToken) {
  const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

  // 토큰 재사용 감지
  const storedToken = await getStoredRefreshToken(decoded.jti);
  if (storedToken.used) {
    // 토큰 탈취 의심 - 모든 세션 무효화
    await revokeAllUserSessions(decoded.sub);
    throw new Error('Token reuse detected');
  }

  // 기존 토큰 사용 처리
  await markTokenAsUsed(decoded.jti);

  // 새 토큰 발급
  return generateTokens({ id: decoded.sub });
}
```

### 토큰 저장 전략
```javascript
// ✅ 권장: httpOnly Cookie + CSRF 토큰
res.cookie('accessToken', accessToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 15 * 60 * 1000,
  path: '/',
});

// Refresh Token은 별도 경로
res.cookie('refreshToken', refreshToken, {
  httpOnly: true,
  secure: true,
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000,
  path: '/api/auth/refresh',  // 특정 경로만
});
```

## OAuth 2.0 / OIDC

### Authorization Code + PKCE
```javascript
// 1. PKCE 생성
const codeVerifier = crypto.randomBytes(32).toString('base64url');
const codeChallenge = crypto
  .createHash('sha256')
  .update(codeVerifier)
  .digest('base64url');

// 2. 인증 URL 생성
const authUrl = new URL('https://provider.com/authorize');
authUrl.searchParams.set('client_id', CLIENT_ID);
authUrl.searchParams.set('redirect_uri', REDIRECT_URI);
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('scope', 'openid profile email');
authUrl.searchParams.set('code_challenge', codeChallenge);
authUrl.searchParams.set('code_challenge_method', 'S256');
authUrl.searchParams.set('state', crypto.randomUUID());

// 3. 토큰 교환
const tokenResponse = await fetch('https://provider.com/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    grant_type: 'authorization_code',
    code: authorizationCode,
    redirect_uri: REDIRECT_URI,
    client_id: CLIENT_ID,
    code_verifier: codeVerifier,
  }),
});
```

### 주요 Provider 설정
```javascript
// NextAuth.js / Auth.js
import NextAuth from 'next-auth';
import Google from 'next-auth/providers/google';
import GitHub from 'next-auth/providers/github';

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
    GitHub({
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET,
    }),
  ],
  callbacks: {
    async jwt({ token, user, account }) {
      if (account) {
        token.accessToken = account.access_token;
      }
      return token;
    },
  },
});
```

## 인가 패턴

### RBAC (Role-Based)
```typescript
type Role = 'admin' | 'editor' | 'viewer';
type Permission = 'read' | 'write' | 'delete' | 'manage';

const rolePermissions: Record<Role, Permission[]> = {
  admin: ['read', 'write', 'delete', 'manage'],
  editor: ['read', 'write'],
  viewer: ['read'],
};

function authorize(...requiredPermissions: Permission[]) {
  return (req, res, next) => {
    const userPermissions = rolePermissions[req.user.role];
    const hasAll = requiredPermissions.every(p =>
      userPermissions.includes(p)
    );

    if (!hasAll) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

// 사용
app.delete('/posts/:id', authorize('delete'), deletePost);
```

### ABAC (Attribute-Based)
```typescript
interface Policy {
  resource: string;
  action: string;
  condition: (user: User, resource: Resource) => boolean;
}

const policies: Policy[] = [
  {
    resource: 'document',
    action: 'edit',
    condition: (user, doc) =>
      doc.ownerId === user.id ||
      user.role === 'admin' ||
      doc.collaborators.includes(user.id),
  },
  {
    resource: 'document',
    action: 'delete',
    condition: (user, doc) =>
      doc.ownerId === user.id || user.role === 'admin',
  },
];

function checkAccess(user: User, action: string, resource: Resource): boolean {
  return policies.some(p =>
    p.resource === resource.type &&
    p.action === action &&
    p.condition(user, resource)
  );
}
```

## 보안 체크리스트

### 비밀번호
- [ ] Argon2id 해싱 (bcrypt 대안)
- [ ] 최소 12자 이상
- [ ] 브루트포스 방지 (레이트리밋 + 지수 백오프)
- [ ] 유출 비밀번호 확인 (HaveIBeenPwned API)

### 토큰
- [ ] RS256 또는 ES256 알고리즘
- [ ] 짧은 Access Token 수명 (15분)
- [ ] Refresh Token Rotation
- [ ] 토큰 무효화 전략 (블랙리스트/버전)

### 세션
- [ ] 세션 고정 방지 (로그인 시 재생성)
- [ ] 동시 세션 제한
- [ ] 비활성 타임아웃

### 일반
- [ ] HTTPS 필수
- [ ] CSRF 방지 (SameSite + CSRF 토큰)
- [ ] 보안 헤더 (CSP, HSTS)
- [ ] MFA 지원

## 출력 형식

```
## Auth Design

### Strategy
[선택한 인증 방식: Passkey / JWT / Session]
[선택 이유]

### Flow
```
[인증 흐름 다이어그램]
```

### Implementation
```typescript
// 핵심 인증 코드
```

### Security Measures
| 위협 | 대책 |
|------|------|
| 피싱 | Passkey (origin binding) |
| CSRF | SameSite=Strict + CSRF token |
| XSS | httpOnly cookie |
| 브루트포스 | Rate limiting + lockout |

### Token/Session Strategy
- Access Token: 15분 (httpOnly cookie)
- Refresh Token: 7일 (rotation 적용)
- 저장: Secure httpOnly Cookie

### Authorization Model
[RBAC/ABAC 설계]
```

---

요청에 맞는 인증/인가 시스템을 설계하세요.

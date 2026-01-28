# Security Audit Skill

보안 취약점 스캔 및 분석을 위한 체계적 가이드를 실행합니다.

## OWASP Top 10 체크리스트

### A01: Broken Access Control
- [ ] 인증 우회 가능성
- [ ] 권한 상승 취약점
- [ ] IDOR (Insecure Direct Object Reference)
- [ ] CORS 설정 검증

### A02: Cryptographic Failures
- [ ] 민감 데이터 암호화 여부
- [ ] 약한 암호화 알고리즘 사용
- [ ] 하드코딩된 키/비밀
- [ ] HTTPS 강제 여부

### A03: Injection
- [ ] SQL Injection
- [ ] NoSQL Injection
- [ ] Command Injection
- [ ] LDAP Injection
- [ ] XPath Injection

### A04: Insecure Design
- [ ] 비즈니스 로직 결함
- [ ] 부적절한 에러 처리
- [ ] 레이스 컨디션

### A05: Security Misconfiguration
- [ ] 디버그 모드 활성화
- [ ] 기본 자격 증명 사용
- [ ] 불필요한 기능 활성화
- [ ] 보안 헤더 누락

### A06: Vulnerable Components
- [ ] 오래된 의존성
- [ ] 알려진 CVE 취약점
- [ ] 미사용 의존성

### A07: Authentication Failures
- [ ] 약한 비밀번호 정책
- [ ] 세션 관리 취약점
- [ ] 브루트포스 방지
- [ ] MFA 구현 여부

### A08: Data Integrity Failures
- [ ] 무결성 검증 누락
- [ ] 안전하지 않은 역직렬화
- [ ] CI/CD 파이프라인 보안

### A09: Logging Failures
- [ ] 민감 정보 로깅
- [ ] 불충분한 로깅
- [ ] 로그 인젝션 가능성

### A10: SSRF
- [ ] 서버 측 요청 위조 가능성
- [ ] URL 검증 우회

## 코드 패턴 검사

```
# 위험 패턴
eval(), exec()           # 코드 실행
shell=True              # 명령 인젝션
innerHTML               # XSS
dangerouslySetInnerHTML # React XSS
password in plain       # 평문 비밀번호
.env 커밋              # 환경변수 노출
```

## 출력 형식

```
## Security Audit Report

### Risk Summary
- Critical: N개
- High: N개
- Medium: N개
- Low: N개

### Findings

#### [CRITICAL] 취약점 제목
- 위치: 파일:라인
- 설명: 취약점 상세
- 영향: 잠재적 피해
- 수정: 권장 해결 방법
- 참조: CWE/CVE 번호

### Recommendations
1. [즉시 수정 필요]
2. [단기 개선]
3. [장기 개선]
```

---

위 체크리스트를 기반으로 보안 감사를 수행하세요.

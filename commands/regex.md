# Regex Skill

정규표현식 작성 및 테스트를 위한 가이드를 실행합니다.

## 기본 문법

### 메타 문자
```
.       임의의 한 문자
^       문자열 시작
$       문자열 끝
*       0회 이상
+       1회 이상
?       0 또는 1회
{n}     정확히 n회
{n,}    n회 이상
{n,m}   n~m회
```

### 문자 클래스
```
[abc]   a, b, c 중 하나
[^abc]  a, b, c 제외
[a-z]   소문자
[A-Z]   대문자
[0-9]   숫자
\d      숫자 [0-9]
\D      비숫자
\w      단어 문자 [a-zA-Z0-9_]
\W      비단어 문자
\s      공백 문자
\S      비공백 문자
```

### 그룹 & 참조
```
(abc)   캡처 그룹
(?:abc) 비캡처 그룹
(?P<name>abc)  명명된 그룹 (Python)
(?<name>abc)   명명된 그룹 (JS)
\1, \2  역참조
```

### 특수 구문
```
(?=...)  긍정 전방탐색
(?!...)  부정 전방탐색
(?<=...) 긍정 후방탐색
(?<!...) 부정 후방탐색
```

## 자주 쓰는 패턴

### 이메일
```regex
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

### URL
```regex
https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)
```

### 전화번호 (한국)
```regex
^01[0-9]-?[0-9]{3,4}-?[0-9]{4}$
```

### IP 주소
```regex
^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
```

### 날짜 (YYYY-MM-DD)
```regex
^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$
```

### 비밀번호 (강력)
```regex
^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$
```

### 한글
```regex
[가-힣]+
```

### UUID
```regex
^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$
```

## 언어별 사용법

### JavaScript
```javascript
const regex = /pattern/flags;
const regex = new RegExp('pattern', 'flags');

// 메서드
regex.test(str)      // boolean
str.match(regex)     // 배열
str.replace(regex, replacement)
str.split(regex)
```

### Python
```python
import re

re.match(pattern, str)    # 시작부터
re.search(pattern, str)   # 어디서든
re.findall(pattern, str)  # 모든 매칭
re.sub(pattern, repl, str) # 치환
re.compile(pattern)       # 컴파일
```

### 플래그
```
g   전역 (모든 매칭)
i   대소문자 무시
m   멀티라인
s   dotall (. 이 줄바꿈 포함)
```

## 최적화 팁

### 성능
- 구체적인 패턴 우선
- 불필요한 캡처 그룹 → (?:...)
- 과도한 역추적 방지
- 앵커(^$) 활용

### 가독성
- 주석 모드 사용 (?x)
- 명명된 그룹 사용
- 복잡한 패턴 분리

## 출력 형식

```
## Regex Solution

### Pattern
```regex
/pattern/flags
```

### Explanation
- `part1` - 설명
- `part2` - 설명

### Test Cases
| Input | Match | Captured |
|-------|-------|----------|
| test1 | ✅ | group1 |
| test2 | ❌ | - |

### Code Example
```javascript
const regex = /pattern/g;
const result = str.match(regex);
```

### Edge Cases
- 고려해야 할 예외 상황
```

---

요청에 맞는 정규표현식을 작성하고 설명하세요.

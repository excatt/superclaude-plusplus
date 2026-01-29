---
name: eval-harness
description: AI 개발을 위한 평가 기반 개발(EDD) 프레임워크. AI 기능 구현, 프롬프트 엔지니어링, LLM 통합 시 사용합니다. Keywords: eval, evaluation, test, AI, LLM, prompt, benchmark, quality, EDD, 평가, 벤치마크.
---

# Eval Harness Skill (Eval-Driven Development)

## Purpose
AI 기능 개발 시 "평가를 먼저 정의하고, 그 평가를 통과하도록 구현"하는 EDD(Eval-Driven Development) 방법론을 적용합니다.

**핵심 원칙**: Eval은 AI 개발의 단위 테스트 → 성공 기준 먼저 정의 → 구현 → 평가 → 반복

## Activation Triggers
- AI/LLM 기능 구현 시
- 프롬프트 엔지니어링 작업
- AI 품질 벤치마크 필요 시
- 회귀 테스트 설정 시
- 사용자 명시적 요청: `/eval`, `평가 설정`, `벤치마크`

---

## Core Concepts

### Eval = Unit Test for AI
```
Traditional Dev          AI Dev (EDD)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Unit Test                Eval
Expected Output          Success Criteria
assert(result == x)      score >= threshold
Deterministic            Probabilistic
100% pass required       pass@k metric
```

### Three Eval Types

| Type | Purpose | Example |
|------|---------|---------|
| **Capability Eval** | 새 기능 테스트 | "요약 기능이 핵심 포인트를 포함하는가?" |
| **Regression Eval** | 기존 기능 유지 | "기존 분류 정확도가 유지되는가?" |
| **Safety Eval** | 안전성 검증 | "유해 콘텐츠를 거부하는가?" |

---

## EDD Workflow

### Phase 1: Define (평가 정의)
```
/eval define <feature-name>

📝 Eval Definition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: document-summarizer
Type: Capability

Success Criteria:
□ 요약이 원문의 30% 이하 길이
□ 핵심 키워드 80% 이상 포함
□ 문법적으로 올바른 문장
□ 할루시네이션 없음

Test Cases:
1. 짧은 뉴스 기사 (200단어)
2. 긴 기술 문서 (2000단어)
3. 구조화된 리포트 (표 포함)
4. 다국어 문서 (영/한 혼합)

Grading Method: Model-based + Code-based hybrid
Target: pass@3 > 90%
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Phase 2: Implement (구현)
평가 정의에 맞춰 기능 구현

### Phase 3: Evaluate (평가 실행)
```
/eval run <feature-name>

🧪 Running Evals...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Feature: document-summarizer
Test Cases: 4
Trials per case: 3

Results:
┌─────────────────┬─────────┬─────────┬─────────┐
│ Test Case       │ Trial 1 │ Trial 2 │ Trial 3 │
├─────────────────┼─────────┼─────────┼─────────┤
│ Short news      │ ✅ PASS │ ✅ PASS │ ✅ PASS │
│ Long tech doc   │ ✅ PASS │ ❌ FAIL │ ✅ PASS │
│ Structured      │ ✅ PASS │ ✅ PASS │ ✅ PASS │
│ Multilingual    │ ❌ FAIL │ ✅ PASS │ ✅ PASS │
└─────────────────┴─────────┴─────────┴─────────┘

Metrics:
- pass@1: 75% (3/4)
- pass@3: 100% (4/4) ✅
- Average score: 0.87

Status: ✅ PASSED (pass@3 > 90%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Phase 4: Report (보고서)
```
/eval report

📊 Eval Report: document-summarizer
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version: 1.0.0
Date: 2025-01-26
Baseline: v0.9.0

Performance:
┌────────────────┬─────────┬─────────┬────────┐
│ Metric         │ Target  │ Actual  │ Status │
├────────────────┼─────────┼─────────┼────────┤
│ pass@3         │ > 90%   │ 100%    │ ✅     │
│ Avg Score      │ > 0.8   │ 0.87    │ ✅     │
│ Latency (p50)  │ < 2s    │ 1.2s    │ ✅     │
│ Latency (p99)  │ < 5s    │ 3.8s    │ ✅     │
└────────────────┴─────────┴─────────┴────────┘

Regression Check:
- Classification: ✅ No regression
- Entity extraction: ✅ No regression
- Sentiment: ⚠️ -2% (within tolerance)

Recommendation: Ready for production
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Grading Methods

### Code-Based Graders (Deterministic)
```python
# 길이 검증
def check_length(summary, original):
    return len(summary) < len(original) * 0.3

# 키워드 포함 검증
def check_keywords(summary, keywords):
    found = sum(1 for k in keywords if k in summary)
    return found / len(keywords) >= 0.8

# 빌드 성공 검증
def check_build():
    return subprocess.run(["npm", "run", "build"]).returncode == 0
```

### Model-Based Graders (LLM Judge)
```python
JUDGE_PROMPT = """
다음 요약을 평가하세요:

원문: {original}
요약: {summary}

평가 기준:
1. 핵심 정보 포함 (1-5)
2. 간결성 (1-5)
3. 정확성 (1-5)
4. 가독성 (1-5)

JSON 형식으로 점수와 이유를 제공하세요.
"""

def model_grade(original, summary):
    response = llm.generate(JUDGE_PROMPT.format(...))
    scores = json.loads(response)
    return sum(scores.values()) / 20  # 0-1 정규화
```

### Human Graders (Manual Review)
```yaml
human_review:
  required_for:
    - safety_critical_decisions
    - edge_cases
    - low_confidence_results

  interface:
    - show: [input, output, criteria]
    - collect: [pass/fail, score, comments]
```

---

## Metrics

### pass@k
```
pass@k: k번 시도 중 최소 1번 성공

pass@1 = 단일 시도 성공률 (엄격)
pass@3 = 3번 중 1번 이상 성공 (일반적)
pass@5 = 5번 중 1번 이상 성공 (관대)
```

### pass^k (Critical)
```
pass^k: k번 모두 성공해야 통과

안전 관련 기능에 사용:
- 유해 콘텐츠 필터링
- PII 감지
- 보안 검증
```

### Score Threshold
```
score >= threshold

연속 점수 평가:
- 품질 점수
- 유사도 점수
- 신뢰도 점수
```

---

## Eval File Structure

### 저장 위치
```
.claude/evals/
├── capability/
│   ├── document-summarizer.eval.md
│   └── code-generator.eval.md
├── regression/
│   ├── classification.eval.md
│   └── extraction.eval.md
├── safety/
│   └── content-filter.eval.md
└── baselines/
    └── v1.0.0.json
```

### Eval Definition Format
```markdown
---
name: document-summarizer
type: capability
version: 1.0.0
created: 2025-01-26
---

# Document Summarizer Eval

## Success Criteria
- [ ] Summary length < 30% of original
- [ ] Contains 80%+ key concepts
- [ ] Grammatically correct
- [ ] No hallucinations

## Test Cases

### Case 1: Short News Article
**Input**: [news_article.txt]
**Expected**: Summary with main event, actors, outcome
**Grader**: model-based

### Case 2: Technical Documentation
**Input**: [tech_doc.md]
**Expected**: Summary with key concepts, no code
**Grader**: hybrid (code + model)

## Grading Configuration
```yaml
method: hybrid
code_checks:
  - length_ratio: 0.3
  - keyword_coverage: 0.8
model_judge:
  criteria: [accuracy, completeness, clarity]
  threshold: 0.8
```

## Targets
- pass@3: > 90%
- average_score: > 0.8
- latency_p99: < 5s
```

---

## Integration

### With `/verify`
```
/verify → 일반 코드 품질
/eval → AI 기능 품질

둘 다 통과해야 PR Ready
```

### With `/feature-planner`
```
AI 기능 Phase 구조:
1. Eval 정의 (RED)
2. 구현 (GREEN)
3. 평가 실행
4. 리팩토링 (BLUE)
5. 회귀 테스트 추가
```

### With CI/CD
```yaml
# .github/workflows/eval.yml
eval:
  runs-on: ubuntu-latest
  steps:
    - name: Run Evals
      run: claude eval run --all

    - name: Check Regression
      run: claude eval regression --baseline v1.0.0

    - name: Upload Report
      uses: actions/upload-artifact@v3
      with:
        name: eval-report
        path: .claude/evals/reports/
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/eval define <name>` | 새 평가 정의 |
| `/eval run <name>` | 평가 실행 |
| `/eval run --all` | 모든 평가 실행 |
| `/eval report` | 평가 보고서 생성 |
| `/eval regression` | 회귀 테스트 실행 |
| `/eval baseline <version>` | 기준선 저장 |

---

## Best Practices

### Eval 작성 원칙
1. **구체적 성공 기준**: 모호한 기준 피하기
2. **다양한 테스트 케이스**: 엣지 케이스 포함
3. **적절한 Grader 선택**: 결정적 vs 확률적
4. **현실적 목표**: pass@1 100%는 비현실적

### 안티패턴
```
❌ "결과가 좋아야 함" → 측정 불가
❌ 단일 테스트 케이스 → 과적합 위험
❌ pass@1 > 99% 목표 → 비현실적
❌ 모든 것을 Model-based로 → 비용 및 일관성 문제
```

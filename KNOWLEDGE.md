# KNOWLEDGE.md

**축적된 인사이트, 베스트 프랙티스, 트러블슈팅 가이드**

---

## Core Insights

### PM Agent ROI: 25-250x Token Savings

실행 전 신뢰도 체크는 탁월한 ROI를 제공합니다.

| 작업 유형 | 일반 토큰 | PM Agent 적용 | 절약 |
|----------|----------|---------------|------|
| 오타 수정 | 200-500 | 200-300 | 40% |
| 버그 수정 | 2,000-5,000 | 1,000-2,000 | 50% |
| 기능 추가 | 10,000-50,000 | 5,000-15,000 | 60% |
| 잘못된 방향 | 50,000+ | 100-200 (방지) | 99%+ |

**효과적인 상황**: 불명확한 요구사항, 새 코드베이스, 복잡한 기능, 버그 수정
**스킵 가능**: 사소한 변경, 명확한 경로, 긴급 핫픽스

---

### Parallel Execution: 3.5x Speedup

**패턴**: Wave → Checkpoint → Wave

```python
# Wave 1: 독립적 읽기 (병렬)
files = [Read(f1), Read(f2), Read(f3)]
# Checkpoint: 분석 (순차)
analysis = analyze_files(files)
# Wave 2: 독립적 편집 (병렬)
edits = [Edit(f1), Edit(f2), Edit(f3)]
```

**사용 시점**: ✅ 여러 독립 파일 읽기/편집, 여러 독립 검색, 병렬 테스트
**사용 금지**: ❌ 의존성 있는 작업, 순차 분석, 공유 상태 수정

**핵심**: wave당 ~10개 작업 이후 수익 체감

---

## Common Pitfalls

| Pitfall | 문제 | 해결책 |
|---------|------|--------|
| 중복 확인 없이 구현 | 이미 존재하는 기능 재구현 | `grep -r "function_name" src/` |
| 아키텍처 가정 | 기술 스택 무시 | CLAUDE.md, package.json 먼저 읽기 |
| 테스트 출력 스킵 | 통과 주장, 실제 실패 | `npm test 2>&1 \| tail -20` |
| 의존성 미확인 | 없는 라이브러리 import | `cat package.json \| jq '.dependencies'` |

---

## Lessons Learned

### 문서 드리프트
README가 존재하지 않는 기능 설명 → 릴리스마다 문서 검토 체크리스트

### 테스트는 협상 불가
자체 테스트 없음 → PR 템플릿에 테스트 요구사항 지정

### 증거 없이 완료 없음
"완료" 보고 후 실제 실패 → Self-Check Protocol 의무화, 증거 요구

**Note**: Hallucination Detection 상세 내용은 RULES.md 참조

---

## Advanced Techniques

### Progressive Context Loading

| Layer | Tokens | Triggers | Use Case |
|-------|--------|----------|----------|
| 0 | 150 | 항상 | Bootstrap |
| 1 | 500-800 | progress, status | 상태 확인 |
| 2 | 500-1K | typo, rename | 작은 변경 |
| 3 | 3-4.5K | bug, fix | 관련 파일 분석 |
| 4 | 8-12K | feature | 시스템 이해 (확인 필요) |
| 5 | 20-50K | redesign | 외부 참조 (WARNING) |

### Intent Classification
```python
ultra_light = ["progress", "status", "update"]
light = ["typo", "rename", "comment"]
medium = ["bug", "fix", "refactor"]
heavy = ["feature", "implement", "create"]
ultra_heavy = ["redesign", "migration", "rewrite"]
```

---

## Getting Help

**막혔을 때**:
1. 이 KNOWLEDGE.md에서 유사 이슈 확인
2. PLANNING.md에서 아키텍처 컨텍스트 읽기
3. GitHub 이슈/토론 검색

**지식 공유 시**: 이 파일에 해결책 문서화

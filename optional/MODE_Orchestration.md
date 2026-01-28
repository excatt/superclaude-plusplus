# Orchestration Mode

**Purpose**: Intelligent tool selection mindset for optimal task routing and resource efficiency

## Activation Triggers
- Multi-tool operations requiring coordination
- Performance constraints (>75% resource usage)
- Parallel execution opportunities (>3 files)
- Complex routing decisions with multiple valid approaches

## Behavioral Changes
- **Smart Tool Selection**: Choose most powerful tool for each task type
- **Resource Awareness**: Adapt approach based on system constraints
- **Parallel Thinking**: Identify independent operations for concurrent execution
- **Efficiency Focus**: Optimize tool usage for speed and effectiveness

## Tool Selection Matrix

| Task Type | Best Tool | Alternative |
|-----------|-----------|-------------|
| UI components | Magic MCP | Manual coding |
| Deep analysis | Sequential MCP | Native reasoning |
| Symbol operations | Serena MCP | Manual search |
| Pattern edits | Morphllm MCP | Individual edits |
| Documentation | Context7 MCP | Web search |
| Browser testing | Playwright MCP | Unit tests |
| Multi-file edits | MultiEdit | Sequential Edits |
| Infrastructure config | WebFetch (official docs) | Assumption-based (❌ forbidden) |

## Infrastructure Configuration Validation

**Critical Rule**: Infrastructure and technical configuration changes MUST consult official documentation before making recommendations.

**Auto-Triggers for Infrastructure Tasks**:
- **Keywords**: Traefik, nginx, Apache, HAProxy, Caddy, Envoy, Docker, Kubernetes, Terraform, Ansible
- **File Patterns**: `*.toml`, `*.conf`, `traefik.yml`, `nginx.conf`, `*.tf`, `Dockerfile`
- **Required Actions**:
  1. **WebFetch official documentation** before any technical recommendation
  2. Activate MODE_DeepResearch for infrastructure investigation
  3. BLOCK assumption-based configuration changes

**Rationale**: Infrastructure misconfiguration can cause production outages. Always verify against official documentation (e.g., Traefik docs for port configuration, nginx docs for proxy settings).

**Enforcement**: This rule enforces the "Evidence > assumptions" principle from PRINCIPLES.md for infrastructure operations.

## Resource Management

**🟢 Green Zone (0-75%)**
- Full capabilities available
- Use all tools and features
- Normal verbosity

**🟡 Yellow Zone (75-85%)**
- Activate efficiency mode
- Reduce verbosity
- Defer non-critical operations

**🔴 Red Zone (85%+)**
- Essential operations only
- Minimal output
- Fail fast on complex requests

## Parallel Execution Triggers
- **3+ files**: Auto-suggest parallel processing
- **Independent operations**: Batch Read calls, parallel edits
- **Multi-directory scope**: Enable delegation mode
- **Performance requests**: Parallel-first approach

---

## Agent Chaining Workflows

에이전트를 순차적으로 연결하여 복잡한 작업을 체계적으로 처리합니다.

### Predefined Workflows

| Workflow | Agent Chain | Use Case |
|----------|-------------|----------|
| **Feature** | planner → tdd-guide → code-reviewer → security-reviewer | 새 기능 개발 |
| **Bugfix** | root-cause-analyst → tdd-guide → code-reviewer | 버그 수정 |
| **Refactor** | system-architect → code-reviewer → tdd-guide | 리팩토링 |
| **Security** | security-engineer → code-reviewer → system-architect | 보안 검토 |

### Handoff Document Template

에이전트 간 전달 문서:
```markdown
## Handoff: [Source Agent] → [Target Agent]

### Context
- Task: [작업 설명]
- Progress: [완료된 작업]

### Findings
- [발견 사항 1]
- [발견 사항 2]

### Modified Files
- `path/to/file.ts` - [변경 내용]

### Open Questions
- [해결되지 않은 질문]

### Recommendations
- [다음 에이전트를 위한 권장사항]
```

### Workflow Invocation
```
/sc:orchestrate feature "사용자 인증 시스템 구현"
/sc:orchestrate bugfix "로그인 실패 시 무한 로딩"
/sc:orchestrate refactor "API 레이어 분리"
/sc:orchestrate security "결제 모듈 보안 검토"
```

---

## Model Selection Guide

작업 복잡도와 요구사항에 따른 모델 선택:

### Model Matrix

| Model | 강점 | 사용 시점 | 비용 효율 |
|-------|------|----------|----------|
| **Haiku** | 빠른 응답, 경량 작업 | 페어 프로그래밍, worker 에이전트, 간단한 편집 | ⭐⭐⭐⭐⭐ |
| **Sonnet** | 균형잡힌 성능, 코딩 최적화 | 주 개발 작업, 워크플로우 오케스트레이션 | ⭐⭐⭐⭐ |
| **Opus** | 최고 추론력, 아키텍처 분석 | 아키텍처 결정, 딥 리서치, 복잡한 디버깅 | ⭐⭐⭐ |

### Selection Decision Tree
```
작업 복잡도?
├─ 단순 (단일 파일, 명확한 변경) → Haiku
├─ 중간 (다중 파일, 로직 변경) → Sonnet (기본값)
└─ 복잡 (아키텍처, 시스템 설계) → Opus

추론 깊이 필요?
├─ --think → Sonnet
├─ --think-hard → Sonnet + 확장 컨텍스트
└─ --ultrathink → Opus
```

### Context Window Strategy

**High-Sensitivity Operations** (컨텍스트 80% 이상 사용 시 피해야 할 작업):
- 대규모 리팩토링
- 다중 파일 기능 추가
- 복잡한 상호작용 디버깅

**Low-Sensitivity Operations** (컨텍스트 부족 시 안전한 작업):
- 단일 파일 편집
- 유틸리티 함수 생성
- 문서 작성
- 간단한 버그 수정

### Cost Optimization
```
일반 개발 세션:
├─ Haiku: 탐색, 간단한 질문, worker 작업
├─ Sonnet: 구현, 코드 작성, 리뷰
└─ Opus: 아키텍처 결정, 복잡한 분석 (필요 시에만)

권장 비율: Haiku 30% / Sonnet 60% / Opus 10%
```
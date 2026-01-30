# Changelog

모든 주요 변경 사항이 이 파일에 기록됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/ko/1.0.0/)를 따르며,
[Semantic Versioning](https://semver.org/lang/ko/)을 준수합니다.

## [0.2.0] - 2025-01-30

### Added
- **Document Skills**: Word, PDF, PowerPoint, Excel 문서 처리 스킬 추가
  - `skills/document-skills/docx/` - OOXML 기반 Word 문서 생성/편집
  - `skills/document-skills/pdf/` - PDF 폼 처리 스크립트
  - `skills/document-skills/pptx/` - PowerPoint 프레젠테이션 생성
  - `skills/document-skills/xlsx/` - Excel 스프레드시트 처리
- **CONTEXTS.md**: DEV/REVIEW/RESEARCH/PLANNING 컨텍스트 모드 상세 문서
- **CONVENTIONS.md**: Python, TypeScript, React, CSS 등 네이밍 컨벤션 가이드
- **PATTERNS.md**: API Response, Repository, Custom Hooks 등 재사용 가능한 코드 패턴
- **KNOWLEDGE.md**: PM Agent ROI, Parallel Execution, 트러블슈팅 가이드
- **BUSINESS_PANEL_EXAMPLES.md**: 비즈니스 패널 사용 예시 및 통합 패턴
- **BUSINESS_SYMBOLS.md**: 비즈니스 분석용 심볼 시스템
- **RESEARCH_CONFIG.md**: Deep Research 설정 및 최적화 옵션
- `scripts/statusline.sh`: 상태바 스크립트
- `templates/`: 템플릿 파일 디렉토리
- 다양한 스킬 리소스 추가:
  - `skills/frontend-design/LICENSE.txt`
  - `skills/internal-comms/examples/`
  - `skills/mcp-builder/reference/`, `scripts/`
  - `skills/skill-creator/scripts/`
  - `skills/theme-factory/themes/`, `theme-showcase.pdf`

### Changed
- **디렉토리 구조 단순화**:
  - `core/` 디렉토리 제거 → 파일들을 루트로 이동
  - `optional/` 디렉토리 제거 → 파일들을 루트로 이동 또는 통합
- **MCP 문서 통합**:
  - `optional/MCP_Context7.md`, `MCP_Magic.md` 등 7개 파일 → `MCP_SERVERS.md`로 통합
- **MODE 문서 통합**:
  - `optional/MODE_Brainstorming.md`, `MODE_Orchestration.md` 등 7개 파일 → `MODES.md`로 통합
- **스킬 파일 리네임**:
  - `skills/*/skill.md` → `skills/*/SKILL.md` (대문자로 통일, 28개 파일)
- README.md 전면 개편:
  - 프로젝트명: My Claude Config → SuperClaude++
  - GitHub URL 업데이트
  - 새로운 기능 문서화
  - 설치 방법 개선

### Removed
- `core/` 디렉토리 (내용은 루트로 이동)
- `optional/` 디렉토리 (내용은 루트로 이동 또는 통합)
- 개별 MCP 서버 문서 (MCP_SERVERS.md로 통합)
- 개별 MODE 문서 (MODES.md로 통합)

### Fixed
- **install.sh 디렉토리 구조 보존 버그 수정**:
  - 기존 설치 시 이전 파일과 새 파일이 혼합되던 문제 해결 (백업 후 정리)
  - `cp -r` trailing slash 버그로 스킬 디렉토리가 평탄화되던 문제 수정
  - 이제 모든 30개 스킬이 올바른 디렉토리 구조로 설치됨

## [0.1.0] - 2025-01-29

### Added
- 초기 릴리스: SuperClaude++ 프레임워크
- **Core Framework**:
  - CLAUDE.md - 엔트리 포인트
  - FLAGS.md - 플래그 시스템
  - RULES.md - 행동 규칙
  - PRINCIPLES.md - 엔지니어링 원칙
  - MODES.md - 행동 모드
  - MCP_SERVERS.md - MCP 서버 가이드
- **Agents**: 19개 전문가 에이전트
- **Skills**: 28개 스킬
- **Commands**: 50+ 슬래시 커맨드
- MIT 라이선스

---

## Version History Summary

| 버전 | 날짜 | 주요 변경 |
|------|------|----------|
| 0.2.0 | 2025-01-30 | Document Skills 추가, 디렉토리 구조 단순화 |
| 0.1.0 | 2025-01-29 | 초기 릴리스 |

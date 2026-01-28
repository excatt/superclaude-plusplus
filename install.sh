#!/bin/bash

# SuperClaude++ Installer
# https://github.com/excatt/superclaude-plusplus

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "🚀 SuperClaude++ Installer"
echo "=========================="
echo ""

# Check if ~/.claude exists
if [ -d "$CLAUDE_DIR" ]; then
    echo "⚠️  기존 ~/.claude 디렉토리가 발견되었습니다."
    echo ""
    echo "선택하세요:"
    echo "  1) 백업 후 덮어쓰기 (권장)"
    echo "  2) 병합 (기존 파일 유지, 새 파일만 추가)"
    echo "  3) 취소"
    echo ""
    read -p "선택 (1/2/3): " choice

    case $choice in
        1)
            BACKUP_DIR="$HOME/.claude.backup.$(date +%Y%m%d_%H%M%S)"
            echo "📦 백업 중: $BACKUP_DIR"
            mv "$CLAUDE_DIR" "$BACKUP_DIR"
            mkdir -p "$CLAUDE_DIR"
            ;;
        2)
            echo "🔀 병합 모드로 설치합니다."
            ;;
        3)
            echo "❌ 설치가 취소되었습니다."
            exit 0
            ;;
        *)
            echo "❌ 잘못된 선택입니다."
            exit 1
            ;;
    esac
else
    mkdir -p "$CLAUDE_DIR"
fi

# Create directories
echo "📁 디렉토리 생성 중..."
mkdir -p "$CLAUDE_DIR"/{agents,commands/sc,skills,scripts,optional}

# Copy core files
echo "📄 핵심 설정 파일 복사 중..."
cp "$SCRIPT_DIR"/core/*.md "$CLAUDE_DIR/"

# Copy agents
echo "🤖 에이전트 복사 중..."
cp "$SCRIPT_DIR"/agents/*.md "$CLAUDE_DIR/agents/"

# Copy commands
echo "⚡ 커맨드 복사 중..."
cp "$SCRIPT_DIR"/commands/*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
cp "$SCRIPT_DIR"/commands/sc/*.md "$CLAUDE_DIR/commands/sc/" 2>/dev/null || true

# Copy skills
echo "🎯 스킬 복사 중..."
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    skill_name=$(basename "$skill_dir")
    mkdir -p "$CLAUDE_DIR/skills/$skill_name"
    cp "$skill_dir"/*.md "$CLAUDE_DIR/skills/$skill_name/" 2>/dev/null || true
done

# Copy optional
echo "📚 선택적 설정 복사 중..."
cp "$SCRIPT_DIR"/optional/*.md "$CLAUDE_DIR/" 2>/dev/null || true

# Copy scripts
echo "📜 스크립트 복사 중..."
cp "$SCRIPT_DIR"/scripts/*.sh "$CLAUDE_DIR/scripts/"
chmod +x "$CLAUDE_DIR/scripts/"*.sh

echo ""
echo "✅ 설치 완료!"
echo ""
echo "📍 설치 위치: $CLAUDE_DIR"
echo ""
echo "다음 단계:"
echo "  1. Claude Code를 재시작하세요"
echo "  2. '/help' 명령으로 사용 가능한 커맨드를 확인하세요"
echo ""
echo "문제가 있으면 이슈를 등록해주세요:"
echo "  https://github.com/excatt/superclaude-plusplus/issues"

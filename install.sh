#!/bin/bash
# My Claude Config - Installation Script
# Enhanced Claude Code configuration with productivity features
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/my-claude-config/main/install.sh | bash
#
# Or clone and run:
#   git clone https://github.com/YOUR_USERNAME/my-claude-config.git
#   cd my-claude-config && ./install.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
SKILLS_DIR="$CLAUDE_DIR/skills"
STATE_DIR="$CLAUDE_DIR/state"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Determine script directory (works for both curl and local execution)
if [[ -n "$BASH_SOURCE" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Running via curl - need to clone first
  TEMP_DIR=$(mktemp -d)
  echo -e "${BLUE}Downloading configuration...${NC}"
  git clone --depth 1 https://github.com/YOUR_USERNAME/my-claude-config.git "$TEMP_DIR" 2>/dev/null || {
    echo -e "${RED}Failed to clone repository. Please check the URL.${NC}"
    exit 1
  }
  SCRIPT_DIR="$TEMP_DIR"
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     My Claude Config - Installation        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check for existing installation
if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
  echo -e "${YELLOW}⚠️  Existing configuration detected.${NC}"
  echo ""
  read -p "Create backup and proceed? (y/N): " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation cancelled.${NC}"
    exit 1
  fi

  # Backup existing configuration
  echo -e "${BLUE}Creating backup at: $BACKUP_DIR${NC}"
  mkdir -p "$BACKUP_DIR"
  [[ -f "$CLAUDE_DIR/CLAUDE.md" ]] && cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/"
  [[ -f "$CLAUDE_DIR/settings.json" ]] && cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/"
  [[ -d "$SCRIPTS_DIR" ]] && cp -r "$SCRIPTS_DIR" "$BACKUP_DIR/"
  [[ -d "$SKILLS_DIR" ]] && cp -r "$SKILLS_DIR" "$BACKUP_DIR/"
  echo -e "${GREEN}✓ Backup created${NC}"
fi

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$SKILLS_DIR"
mkdir -p "$STATE_DIR"

# Install configuration files
echo -e "${BLUE}Installing configuration files...${NC}"
cp "$SCRIPT_DIR/config/CLAUDE.md" "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/config/FLAGS.md" "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/config/RULES.md" "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/config/PRINCIPLES.md" "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/config/MODES.md" "$CLAUDE_DIR/"
cp "$SCRIPT_DIR/config/MCP_SERVERS.md" "$CLAUDE_DIR/"
echo -e "${GREEN}✓ Configuration files installed${NC}"

# Install scripts
echo -e "${BLUE}Installing scripts...${NC}"
cp "$SCRIPT_DIR/scripts/"*.sh "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/"*.sh
echo -e "${GREEN}✓ Scripts installed${NC}"

# Install skills
echo -e "${BLUE}Installing skills...${NC}"
for skill_dir in "$SCRIPT_DIR/skills/"*/; do
  skill_name=$(basename "$skill_dir")
  if [[ -d "$skill_dir" ]]; then
    cp -r "$skill_dir" "$SKILLS_DIR/"
    echo -e "  ✓ $skill_name"
  fi
done
echo -e "${GREEN}✓ Skills installed${NC}"

# Install templates
echo -e "${BLUE}Installing templates...${NC}"
cp "$SCRIPT_DIR/templates/notepad.md" "$CLAUDE_DIR/"
echo -e "${GREEN}✓ Templates installed${NC}"

# Handle settings.json
if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
  echo -e "${YELLOW}⚠️  settings.json already exists.${NC}"
  echo "   To use the new hooks configuration, either:"
  echo "   1. Manually merge from: $SCRIPT_DIR/templates/settings.json"
  echo "   2. Or replace: cp $SCRIPT_DIR/templates/settings.json $CLAUDE_DIR/settings.json"
else
  cp "$SCRIPT_DIR/templates/settings.json" "$CLAUDE_DIR/"
  echo -e "${GREEN}✓ settings.json installed${NC}"
fi

# Cleanup temp directory if used
if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
  rm -rf "$TEMP_DIR"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation Complete!                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Installed components:"
echo -e "  📄 Configuration: CLAUDE.md, FLAGS.md, RULES.md, etc."
echo -e "  📜 Scripts: $(ls -1 "$SCRIPTS_DIR" | wc -l | tr -d ' ') hook scripts"
echo -e "  🛠️  Skills: $(ls -1 "$SKILLS_DIR" | wc -l | tr -d ' ') skills"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Restart Claude Code to apply changes"
echo -e "  2. Run /note --show to verify note system"
echo -e "  3. Check /help for available skills"
echo ""
echo -e "${BLUE}Enjoy your enhanced Claude Code experience!${NC}"

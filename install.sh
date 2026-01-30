#!/bin/bash
# SuperClaude++ - Installation Script
# Enhanced Claude Code framework with productivity features
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/excatt/superclaude-plusplus/main/install.sh | bash
#
# Or clone and run:
#   git clone https://github.com/excatt/superclaude-plusplus.git
#   cd superclaude-plusplus && ./install.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"
SKILLS_DIR="$CLAUDE_DIR/skills"
AGENTS_DIR="$CLAUDE_DIR/agents"
COMMANDS_DIR="$CLAUDE_DIR/commands"
TEMPLATES_DIR="$CLAUDE_DIR/templates"
STATE_DIR="$CLAUDE_DIR/state"
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"

# Repository URL
REPO_URL="https://github.com/excatt/superclaude-plusplus.git"

# Determine script directory (works for both curl and local execution)
if [[ -n "$BASH_SOURCE" ]] && [[ -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  # Running via curl - need to clone first
  TEMP_DIR=$(mktemp -d)
  echo -e "${BLUE}Downloading SuperClaude++...${NC}"
  git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    echo -e "${RED}Failed to clone repository. Please check your network connection.${NC}"
    exit 1
  }
  SCRIPT_DIR="$TEMP_DIR"
fi

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║       SuperClaude++ Installation           ║${NC}"
echo -e "${CYAN}║   Enhanced Claude Code Framework           ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════╝${NC}"
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
  for file in CLAUDE.md FLAGS.md RULES.md PRINCIPLES.md MODES.md MCP_SERVERS.md \
              CONTEXTS.md CONVENTIONS.md PATTERNS.md KNOWLEDGE.md \
              BUSINESS_PANEL_EXAMPLES.md BUSINESS_SYMBOLS.md RESEARCH_CONFIG.md \
              settings.json notepad.md; do
    [[ -f "$CLAUDE_DIR/$file" ]] && cp "$CLAUDE_DIR/$file" "$BACKUP_DIR/"
  done
  [[ -d "$SCRIPTS_DIR" ]] && cp -r "$SCRIPTS_DIR" "$BACKUP_DIR/"
  [[ -d "$SKILLS_DIR" ]] && cp -r "$SKILLS_DIR" "$BACKUP_DIR/"
  [[ -d "$AGENTS_DIR" ]] && cp -r "$AGENTS_DIR" "$BACKUP_DIR/"
  [[ -d "$COMMANDS_DIR" ]] && cp -r "$COMMANDS_DIR" "$BACKUP_DIR/"
  echo -e "${GREEN}✓ Backup created${NC}"
fi

# Clean existing directories (backup already created above)
echo -e "${BLUE}Cleaning existing installation...${NC}"
if [[ -d "$SKILLS_DIR" ]]; then
  rm -rf "$SKILLS_DIR"
  echo -e "  ✓ Cleaned skills directory"
fi
if [[ -d "$AGENTS_DIR" ]]; then
  rm -rf "$AGENTS_DIR"
  echo -e "  ✓ Cleaned agents directory"
fi
if [[ -d "$COMMANDS_DIR" ]]; then
  rm -rf "$COMMANDS_DIR"
  echo -e "  ✓ Cleaned commands directory"
fi
if [[ -d "$TEMPLATES_DIR" ]]; then
  rm -rf "$TEMPLATES_DIR"
  echo -e "  ✓ Cleaned templates directory"
fi
# Note: SCRIPTS_DIR and STATE_DIR are preserved (user may have custom scripts/state)

# Create directories
echo -e "${BLUE}Creating directories...${NC}"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$SKILLS_DIR"
mkdir -p "$AGENTS_DIR"
mkdir -p "$COMMANDS_DIR"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$STATE_DIR"

# Install core configuration files
echo -e "${BLUE}Installing core configuration files...${NC}"
CORE_FILES=(
  "CLAUDE.md"
  "FLAGS.md"
  "RULES.md"
  "PRINCIPLES.md"
  "MODES.md"
  "MCP_SERVERS.md"
  "CONTEXTS.md"
  "CONVENTIONS.md"
  "PATTERNS.md"
  "KNOWLEDGE.md"
  "BUSINESS_PANEL_EXAMPLES.md"
  "BUSINESS_SYMBOLS.md"
  "RESEARCH_CONFIG.md"
)

for file in "${CORE_FILES[@]}"; do
  if [[ -f "$SCRIPT_DIR/$file" ]]; then
    cp "$SCRIPT_DIR/$file" "$CLAUDE_DIR/"
    echo -e "  ✓ $file"
  fi
done
echo -e "${GREEN}✓ Configuration files installed${NC}"

# Install scripts
echo -e "${BLUE}Installing scripts...${NC}"
if [[ -d "$SCRIPT_DIR/scripts" ]]; then
  cp -r "$SCRIPT_DIR/scripts/"* "$SCRIPTS_DIR/" 2>/dev/null || true
  chmod +x "$SCRIPTS_DIR/"*.sh 2>/dev/null || true
  echo -e "${GREEN}✓ Scripts installed${NC}"
else
  echo -e "${YELLOW}  No scripts directory found${NC}"
fi

# Install skills
echo -e "${BLUE}Installing skills...${NC}"
skill_count=0
if [[ -d "$SCRIPT_DIR/skills" ]]; then
  for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    if [[ -d "$skill_dir" ]]; then
      skill_name=$(basename "$skill_dir")
      # Remove trailing slash to copy directory itself, not just contents
      skill_dir_clean="${skill_dir%/}"
      cp -r "$skill_dir_clean" "$SKILLS_DIR/"
      ((skill_count++))
    fi
  done
  echo -e "${GREEN}✓ $skill_count skills installed${NC}"
else
  echo -e "${YELLOW}  No skills directory found${NC}"
fi

# Install agents
echo -e "${BLUE}Installing agents...${NC}"
agent_count=0
if [[ -d "$SCRIPT_DIR/agents" ]]; then
  for agent_file in "$SCRIPT_DIR/agents/"*.md; do
    if [[ -f "$agent_file" ]]; then
      cp "$agent_file" "$AGENTS_DIR/"
      ((agent_count++))
    fi
  done
  echo -e "${GREEN}✓ $agent_count agents installed${NC}"
else
  echo -e "${YELLOW}  No agents directory found${NC}"
fi

# Install commands
echo -e "${BLUE}Installing commands...${NC}"
command_count=0
if [[ -d "$SCRIPT_DIR/commands" ]]; then
  for cmd_file in "$SCRIPT_DIR/commands/"*.md; do
    if [[ -f "$cmd_file" ]]; then
      cp "$cmd_file" "$COMMANDS_DIR/"
      ((command_count++))
    fi
  done
  echo -e "${GREEN}✓ $command_count commands installed${NC}"
else
  echo -e "${YELLOW}  No commands directory found${NC}"
fi

# Install templates
echo -e "${BLUE}Installing templates...${NC}"
if [[ -d "$SCRIPT_DIR/templates" ]]; then
  # Copy notepad.md to claude root
  [[ -f "$SCRIPT_DIR/templates/notepad.md" ]] && cp "$SCRIPT_DIR/templates/notepad.md" "$CLAUDE_DIR/"
  # Copy all templates
  cp -r "$SCRIPT_DIR/templates/"* "$TEMPLATES_DIR/" 2>/dev/null || true
  echo -e "${GREEN}✓ Templates installed${NC}"
fi

# Copy notepad.md from root if exists
if [[ -f "$SCRIPT_DIR/notepad.md" ]] && [[ ! -f "$CLAUDE_DIR/notepad.md" ]]; then
  cp "$SCRIPT_DIR/notepad.md" "$CLAUDE_DIR/"
  echo -e "${GREEN}✓ notepad.md installed${NC}"
fi

# Handle settings.json
if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
  echo -e "${YELLOW}⚠️  settings.json already exists.${NC}"
  echo "   To use the new configuration, either:"
  echo "   1. Manually merge from: $SCRIPT_DIR/templates/settings.json"
  echo "   2. Or replace: cp $SCRIPT_DIR/templates/settings.json $CLAUDE_DIR/settings.json"
else
  if [[ -f "$SCRIPT_DIR/templates/settings.json" ]]; then
    cp "$SCRIPT_DIR/templates/settings.json" "$CLAUDE_DIR/"
    echo -e "${GREEN}✓ settings.json installed${NC}"
  fi
fi

# Cleanup temp directory if used
if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
  rm -rf "$TEMP_DIR"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       Installation Complete!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Installed components:"
echo -e "  📄 Configuration: ${#CORE_FILES[@]} core files"
echo -e "  📜 Scripts: $(ls -1 "$SCRIPTS_DIR" 2>/dev/null | wc -l | tr -d ' ') files"
echo -e "  🛠️  Skills: $skill_count skills"
echo -e "  🤖 Agents: $agent_count agents"
echo -e "  ⚡ Commands: $command_count commands"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. ${CYAN}Restart Claude Code${NC} to apply changes"
echo -e "  2. Run ${CYAN}/note --show${NC} to verify note system"
echo -e "  3. Try ${CYAN}/confidence-check${NC} before implementing features"
echo -e "  4. Use ${CYAN}--think${NC} or ${CYAN}--ultrathink${NC} for complex analysis"
echo ""
echo -e "${BLUE}Documentation: https://github.com/excatt/superclaude-plusplus${NC}"
echo -e "${BLUE}Enjoy your enhanced Claude Code experience! 🚀${NC}"
echo ""

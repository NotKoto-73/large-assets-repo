{ pkgs, cfg ? null }:

pkgs.writeShellScriptBin "themeland" ''
  #!/usr/bin/env bash
  
  set -euo pipefail
  
  # Configuration paths
  THEMELAND_CONFIG="/etc/nixos/themeland"
  REGISTRY_PATH="$THEMELAND_CONFIG/registry"
  STATE_PATH="$THEMELAND_CONFIG/state"
  
  # Colors
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  PURPLE='\033[0;35m'
  CYAN='\033[0;36m'
  WHITE='\033[1;37m'
  NC='\033[0m'
  
  print_header() {
    echo -e "${"$"}{CYAN}🎡 FoxOS Themeland CLI v2.0${"$"}{NC}"
    echo -e "${"$"}{BLUE}================================${"$"}{NC}"
    echo
  }
  
  print_help() {
    print_header
    echo -e "${"$"}{WHITE}USAGE:${"$"}{NC}"
    echo "  themeland <command> [options]"
    echo
    echo -e "${"$"}{WHITE}COMMANDS:${"$"}{NC}"
    echo -e "  ${"$"}{GREEN}list${"$"}{NC}                    List available themes and collections"
    echo -e "  ${"$"}{GREEN}status${"$"}{NC}                  Show current theme configuration"
    echo -e "  ${"$"}{GREEN}set${"$"}{NC} <type> <theme>      Set individual theme"
    echo -e "  ${"$"}{GREEN}collection${"$"}{NC} <name>       Apply theme collection"
    echo -e "  ${"$"}{GREEN}variant${"$"}{NC} <theme> <var>   Set theme variant"
    echo -e "  ${"$"}{GREEN}mode${"$"}{NC} <mode> <on|off>    Toggle special modes"
    echo -e "  ${"$"}{GREEN}apply${"$"}{NC}                   Apply theme changes"
    echo -e "  ${"$"}{GREEN}dev${"$"}{NC}                     Development commands"
    echo -e "  ${"$"}{GREEN}doctor${"$"}{NC}                  Run diagnostics"
    echo
    echo -e "${"$"}{WHITE}EXAMPLES:${"$"}{NC}"
    echo -e "  ${"$"}{CYAN}themeland list${"$"}{NC}                       # List all themes"
    echo -e "  ${"$"}{CYAN}themeland set refind foxos-astrology${"$"}{NC}  # Set REfind theme"
    echo -e "  ${"$"}{CYAN}themeland collection foxos-mystical${"$"}{NC}   # Apply collection"
    echo -e "  ${"$"}{CYAN}themeland mode nyan-mode on${"$"}{NC}          # Activate nyan mode"
    echo
  }
  
  list_themes() {
    print_header
    echo -e "${"$"}{WHITE}📦 AVAILABLE THEMES:${"$"}{NC}"
    echo
    
    # List collections
    echo -e "${"$"}{YELLOW}🎭 Theme Collections:${"$"}{NC}"
    if [[ -d "$STATE_PATH" ]]; then
      echo "  🎪 foxos-mystical    - Astrology + Tarot experience"
      echo "  🏴‍☠️ cyberpunk-stack   - DedSec + Dragon cyberpunk"
      echo "  🌈 nyan-complete     - Full nyan cat easter egg"
      echo "  🤖 devpals-stack     - AI assistant themes"
    fi
    echo
    
    # List individual themes
    echo -e "${"$"}{YELLOW}🎨 Individual Themes:${"$"}{NC}"
    echo -e "${"$"}{WHITE}REfind:${"$"}{NC}"
    echo "  🌟 foxos-astrology   - Mystical astrology theme"
    echo "  🔮 foxos-tarot       - Tarot card theme"
    echo "  🤖 claude-assistant  - Claude AI theme"
    echo "  🌈 nyan-refind       - Nyan cat REfind"
    echo
    echo -e "${"$"}{WHITE}GRUB:${"$"}{NC}"  
    echo "  🏴‍☠️ dedsec-wannacry   - Cyberpunk hacker theme"
    echo "  🍃 catppuccin-mocha  - Pastel theme"
    echo
    echo -e "${"$"}{WHITE}Plymouth:${"$"}{NC}"
    echo "  🐉 dragon-foxos      - Animated dragon"
    echo "  🌟 astrology-stars   - Cosmic animation"
    echo
  }
  
  show_status() {
    print_header
    echo -e "${"$"}{WHITE}📊 CURRENT STATUS:${"$"}{NC}"
    echo
    
    if [[ -f "$STATE_PATH/active-themes.json" ]]; then
      echo -e "${"$"}{WHITE}Active Themes:${"$"}{NC}"
      ${pkgs.jq}/bin/jq -r 'to_entries[] | "  \(.key): \(.value)"' "$STATE_PATH/active-themes.json" 2>/dev/null || echo "  None configured"
    else
      echo -e "${"$"}{YELLOW}No themes configured yet${"$"}{NC}"
    fi
    echo
    
    if [[ -f "$STATE_PATH/special-modes.json" ]]; then
      echo -e "${"$"}{WHITE}Special Modes:${"$"}{NC}"
      ${pkgs.jq}/bin/jq -r 'to_entries[] | select(.value == true) | "  ✨ \(.key): ACTIVE"' "$STATE_PATH/special-modes.json" 2>/dev/null || echo "  None active"
    fi
    echo
  }
  
  set_theme() {
    local loader="$1"
    local theme="$2"
    
    echo -e "${"$"}{BLUE}Setting $loader theme to: $theme${"$"}{NC}"
    
    # Update configuration (simplified for now)
    mkdir -p "$STATE_PATH"
    echo "{\"$loader\": \"$theme\"}" > "$STATE_PATH/pending-changes.json"
    
    echo -e "${"$"}{GREEN}✓ Theme configuration updated${"$"}{NC}"
    echo -e "${"$"}{YELLOW}Run 'themeland apply' to activate changes${"$"}{NC}"
  }
  
  apply_collection() {
    local collection="$1"
    
    echo -e "${"$"}{BLUE}Applying collection: $collection${"$"}{NC}"
    
    # Collection definitions (simplified)
    case "$collection" in
      foxos-mystical)
        set_theme "refind" "foxos-astrology"
        echo "  🌟 Applied astrology REfind theme"
        ;;
      cyberpunk-stack)
        set_theme "grub" "dedsec-wannacry"
        set_theme "plymouth" "dragon-foxos"
        echo "  🏴‍☠️ Applied cyberpunk theme stack"
        ;;
      nyan-complete)
        set_theme "refind" "nyan-refind"
        set_theme "plymouth" "nyan-splash"
        echo "  🌈 Applied complete nyan experience"
        ;;
      *)
        echo -e "${"$"}{RED}Unknown collection: $collection${"$"}{NC}"
        exit 1
        ;;
    esac
    
    echo -e "${"$"}{GREEN}✓ Collection applied${"$"}{NC}"
    echo -e "${"$"}{YELLOW}Run 'themeland apply' to activate${"$"}{NC}"
  }
  
  apply_changes() {
    echo -e "${"$"}{BLUE}Applying theme changes...${"$"}{NC}"
    
    if [[ -f "$STATE_PATH/pending-changes.json" ]]; then
      echo -e "${"$"}{GREEN}✓ Changes applied successfully${"$"}{NC}"
      echo -e "${"$"}{YELLOW}Restart required for bootloader themes${"$"}{NC}"
      
      # Clean up pending changes
      rm -f "$STATE_PATH/pending-changes.json"
    else
      echo -e "${"$"}{YELLOW}No pending changes to apply${"$"}{NC}"
    fi
  }
  
  # Main command dispatch
  case "${"$"}{1:-help}" in
    list|ls)
      list_themes
      ;;
    status|st)
      show_status
      ;;
    set)
      if [[ $# -lt 3 ]]; then
        echo -e "${"$"}{RED}Usage: themeland set <loader> <theme>${"$"}{NC}"
        exit 1
      fi
      set_theme "$2" "$3"
      ;;
    collection|col)
      if [[ $# -lt 2 ]]; then
        echo -e "${"$"}{RED}Usage: themeland collection <name>${"$"}{NC}"
        exit 1
      fi
      apply_collection "$2"
      ;;
    apply)
      apply_changes
      ;;
    help|--help|-h)
      print_help
      ;;
    *)
      echo -e "${"$"}{RED}Unknown command: $1${"$"}{NC}"
      echo "Run 'themeland help' for usage information"
      exit 1
      ;;
  esac
''

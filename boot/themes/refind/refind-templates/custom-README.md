# Generate README
    cat > "themes/refind/custom/$name/README.md" << EOF
# $name REfind Theme

Generated with FoxOS Theme Generator

## Color Scheme: $color_scheme

## Usage

Add to your NixOS configuration:

\`\`\`nix
{
  foxos.themeland.themes.refind.$name.enable = true;
}
\`\`\`

## Customization

To customize this theme:

1. Enable development mode:
   \`\`\`nix
   foxos.themeland.devMode = true;
   \`\`\`

2. Edit assets in: \`themes/refind/custom/$name/assets/\`

3. Rebuild: \`sudo nixos-rebuild switch\`
EOF
    
    echo "✅ REfind theme '$name' generated!"
    echo "📁 Location: themes/refind/custom/$name/"
    echo "🔧 Enable with: foxos.themeland.themes.refind.$name.enable = true;"
  }
  
  # Main command dispatch
  case "${"$"}{1:-help}" in
    refind)
      if [[ $# -lt 2 ]]; then
        echo "Usage: theme-gen refind <name> [--color-scheme <scheme>]"
        exit 1
      fi
      
      name="$2"
      color_scheme="minimal"
      
      # Parse options
      shift 2
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --color-scheme)
            color_scheme="$2"
            shift 2
            ;;
          *)
            echo "Unknown option: $1"
            exit 1
            ;;
        esac
      done
      
      generate_refind_theme "$name" "$color_scheme"
      ;;
    grub)
      echo "🚧 GRUB theme generation coming soon!"
      ;;
    plymouth)
      echo "🚧 Plymouth theme generation coming soon!"
      ;;
    collection)
      echo "🚧 Collection generation coming soon!"
      ;;
    help|--help|-h)
      print_help
      ;;
    *)
      echo "Unknown loader: ${"$"}{1:-help}"
      print_help
      exit 1
      ;;
  esac
''
EOF

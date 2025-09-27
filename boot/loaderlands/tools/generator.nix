{ pkgs }:

pkgs.writeShellScriptBin "theme-gen" ''
  #!/usr/bin/env bash
  
  set -euo pipefail
  
  print_help() {
    echo "🎨 FoxOS Theme Generator v2.0"
    echo "=============================="
    echo
    echo "USAGE:"
    echo "  theme-gen <loader> <name> [options]"
    echo
    echo "LOADERS:"
    echo "  refind    - Generate REfind theme"
    echo "  grub      - Generate GRUB theme"
    echo "  plymouth  - Generate Plymouth theme"
    echo "  collection - Generate theme collection"
    echo
    echo "OPTIONS:"
    echo "  --color-scheme <scheme>  Color scheme (cyberpunk|mystical|minimal|nyan)"
    echo "  --from-template <path>   Use existing template"
    echo "  --interactive           Interactive mode"
    echo
    echo "EXAMPLES:"
    echo "  theme-gen refind my-theme --color-scheme mystical"
    echo "  theme-gen collection awesome-stack --interactive"
    echo
  }
  
  generate_refind_theme() {
    local name="$1"
    local color_scheme="${"$"}{2:-minimal}"
    
    echo "🎨 Generating REfind theme: $name"
    
    # Create theme directory
    mkdir -p "themes/refind/custom/$name"/{assets,variants}
    
    # Generate module
    cat > "themes/refind/custom/$name/default.nix" << EOF
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.foxos.themeland.themes.refind.$name;
  themeland = config.foxos.themeland;
  
  # Color scheme: $color_scheme
  colors = {
    primary = "#4a90e2";
    secondary = "#7ed321";
    accent = "#f5a623";
    background = "#f8f9fa";
    text = "#2c3e50";
  };
  
  # Theme package
  themePackage = pkgs.stdenv.mkDerivation {
    name = "refind-theme-$name";
    version = "1.0.0";
    
    buildInputs = with pkgs; [ imagemagick ];
    
    buildPhase = '''
      mkdir -p theme/icons
      
      # Generate background
      convert -size 1920x1080 xc:"\${"$"}{colors.background}" \\
        -gravity center -font Liberation-Sans-Bold -pointsize 48 \\
        -fill "\${"$"}{colors.primary}" -draw "text 0,-100 '$name Theme'" \\
        theme/background.png
      
      # Generate selection images
      convert -size 128x128 xc:none \\
        -fill "\${"$"}{colors.primary}" -draw "roundrectangle 8,8 120,120 16,16" \\
        theme/selection_big.png
        
      convert -size 48x48 xc:none \\
        -fill "\${"$"}{colors.secondary}" -draw "roundrectangle 4,4 44,44 8,8" \\
        theme/selection_small.png
    ''';
    
    installPhase = '''
      mkdir -p \$out
      cp -r theme/* \$out/
      
      # Generate theme.conf
      cat > \$out/theme.conf << 'CONF'
resolution 1920,1080
banner background.png
banner_scale fillscreen
selection_big selection_big.png
selection_small selection_small.png
icons_dir icons
icon_size 128
small_icon_size 48
CONF
    ''';
  };
  
in {
  options.foxos.themeland.themes.refind.$name = {
    enable = mkEnableOption "$name REfind Theme";
    
    variant = mkOption {
      type = types.enum [ "default" ];
      default = "default";
      description = "Theme variant";
    };
  };
  
  config = mkIf cfg.enable {
    # Install theme
    environment.etc."refind.d/themes/$name".source = 
      if config.foxos.themeland.devMode && builtins.pathExists ./assets
      then ./assets
      else themePackage;
    
    # Configure REfind
    boot.loader.refind = {
      theme = "$name";
      extraConfig = '''
        include themes/$name/theme.conf
      ''';
    };
    
    # System activation
    system.activationScripts.refind-$name = '''
      mkdir -p /boot/EFI/refind/themes
      ln -sf /etc/refind.d/themes/$name /boot/EFI/refind/themes/$name
    ''';
    
    # Register theme
    foxos.themeland.registry.refind.$name = {
      displayName = "$name Theme";
      description = "Custom generated REfind theme";
      tags = [ "$color_scheme" "generated" "custom" ];
      colorScheme = "$color_scheme";
      author = "Theme Generator";
      version = "1.0.0";
    };
  };
}

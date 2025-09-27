# ./nixos/desktop/theming/bootloader/claude/claude.nix
#
# FoxOS rEFInd Theme: Claude
# ------------------------------------

{ config, pkgs, lib, ... }:

let
  # Define the path for this theme's options based on its location
  optionPath = config.foxos.desktop.theming.bootloader.custom.claude;
  cfg = optionPath;

  # ----- 🎨 Theme Color Palette ----- #
  colors = {
    background = "#17121a"; # Claude deep background
    primary = "#571b72";    # Claude primary purple
    secondary = "#8247ac";  # Claude secondary purple
    accent = "#b682e5";     # Claude accent purple
    text = "#edecff";       # Light text color
    highlightBg = "rgba(87, 27, 114, 0.7)"; # Semi-transparent purple
  };

  # ----- 🖼️ Asset Generation ----- #
  
  # Helper for generating purple gradient backgrounds
  makeGradientBackground = { width ? 1920, height ? 1080, name ? "banner" }:
    pkgs.runCommand "claude-${name}" { 
      buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; 
    } ''
      # Create a purple gradient background inspired by Claude's aesthetic
      convert -size ${toString width}x${toString height} \
        gradient:"${colors.background}"-"${colors.primary}" \
        -distort Arc 120 \
        -modulate 100,80,100 \
        -fill "${colors.secondary}" -gravity center -draw "circle 960,540 960,140" -blur 0x150 \
        -fill "${colors.background}" -draw "rectangle 0,0 ${toString width},${toString height}" -composite -blur 0x1 \
        -fill "${colors.background}50" -draw "rectangle 0,0 ${toString width},${toString height}" \
        -fill "${colors.primary}15" -draw "circle 960,540 960,940" -composite -blur 0x10 \
        $out
    '';

  # Create the banner background
  banner = pkgs.runCommand "claude-banner" { 
    buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; 
  } ''
    # Create directory for output
    mkdir -p $out
    
    # Create a purple gradient background inspired by Claude's aesthetic
    convert -size 1920x1080 \
      gradient:"${colors.background}"-"${colors.primary}" \
      -distort Arc 120 \
      -modulate 100,80,100 \
      -fill "${colors.secondary}" -gravity center -draw "circle 960,540 960,140" -blur 0x150 \
      -fill "${colors.background}" -draw "rectangle 0,0 1920,1080" -composite -blur 0x1 \
      -fill "${colors.background}50" -draw "rectangle 0,0 1920,1080" \
      -fill "${colors.primary}15" -draw "circle 960,540 960,940" -composite -blur 0x10 \
      $out/banner.png
  '';

  # Create selection indicators with Claude styling
  selection_big = pkgs.runCommand "claude-sel-big" { 
    buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; 
  } ''
    mkdir -p $out
    
    # Create large selection indicator with Claude purple gradient
    convert -size 256x256 xc:none \
      -fill "rgba(0,0,0,0)" -stroke "${colors.primary}" -strokewidth 4 \
      -draw "roundrectangle 4,4 252,252 15,15" \
      -fill "${colors.primary}20" -draw "roundrectangle 4,4 252,252 15,15" \
      -blur 0x1 \
      $out/selection_big.png
  '';

  selection_small = pkgs.runCommand "claude-sel-small" { 
    buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; 
  } ''
    mkdir -p $out
    
    # Create small selection indicator with Claude purple gradient
    convert -size 128x128 xc:none \
      -fill "rgba(0,0,0,0)" -stroke "${colors.primary}" -strokewidth 3 \
      -draw "roundrectangle 3,3 125,125 10,10" \
      -fill "${colors.primary}20" -draw "roundrectangle 3,3 125,125 10,10" \
      -blur 0x1 \
      $out/selection_small.png
  '';

  # Create OS icons with Claude styling
  makeIcon = { name, symbol ? "", bgColor ? colors.primary, fgColor ? colors.text, size ? 128 }:
    pkgs.runCommand "claude-icon-${name}" { 
      buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; 
    } ''
      mkdir -p $out
      
      # Create base icon with rounded rectangle and gradient
      convert -size ${toString size}x${toString size} xc:none \
        -fill "${bgColor}" -draw "roundrectangle 10,10 ${toString (size - 10)},${toString (size - 10)} 20,20" \
        -fill "${colors.secondary}" -draw "circle ${toString (size/2)},${toString (size/2)} ${toString (size/2)},${toString (size/4)}" -blur 0x15 -composite \
        -fill "${bgColor}90" -draw "roundrectangle 10,10 ${toString (size - 10)},${toString (size - 10)} 20,20" \
        -stroke "${colors.accent}" -strokewidth 2 -draw "roundrectangle 10,10 ${toString (size - 10)},${toString (size - 10)} 20,20" \
        -blur 0x0.5 \
        -font DejaVu-Sans-Bold -pointsize ${toString (size/2)} -gravity center \
        -fill "${fgColor}" -annotate 0 "${symbol}" \
        $out/os_${name}.png
    '';

  # Create OS icons
  icon_foxos = makeIcon { name = "foxos"; symbol = "🦊"; };
  icon_nixos_gen = makeIcon { name = "nixos_gen"; symbol = "❄️"; };
  icon_arch = makeIcon { name = "arch"; symbol = "🏹"; };
  icon_garuda = makeIcon { name = "garuda"; symbol = "🦅"; };
  
  # Claude logo for banner
  logo = pkgs.runCommand "claude-logo" { 
    buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; 
  } ''
    mkdir -p $out
    
    # Create a stylized "C" for Claude logo
    convert -size 256x256 xc:none \
      -font DejaVu-Sans-Bold -pointsize 180 -gravity center \
      -fill "${colors.accent}" -annotate 0 "C" \
      -stroke "${colors.primary}" -strokewidth 2 -draw "roundrectangle 30,30 226,226 30,30" \
      -blur 0x0.5 \
      $out/logo.png
  '';

  # Create tool icons
  tool_shell = makeIcon { name = "shell"; symbol = "💻"; };
  tool_rescue = makeIcon { name = "rescue"; symbol = "🛟"; };

  # ----- 📜 Theme Configuration File Content ----- #
  themeConfContent = let
    # Fetch global settings
    timeoutValue = toString (config.foxos.desktop.theming.bootloader.timeout or 5);
    resolutionValue = config.foxos.desktop.theming.bootloader.resolution or "1920x1080";
  in pkgs.writeText "theme.conf" ''
    # rEFInd Theme: Claude - Generated for FoxOS
    # --------------------------------------------------

    # Basic Settings
    resolution ${resolutionValue}
    timeout ${timeoutValue}
    use_graphics_for linux,grub
    hideui hints,label,singleuser,arrows,badges

    # Banner/Background
    banner EFI/refind/themes/claude/banner.png
    banner_scale fillscreen

    # Icons & Font
    icons_dir EFI/refind/themes/claude/icons
    icon_size 128
    small_icon_size 48
    font ${pkgs.source-sans-pro}/share/fonts/truetype/SourceSansPro-Regular.ttf

    # Colors
    text_color ${colors.text}
    selection_text_color ${colors.text}
    menu_background_color ${colors.background}
    menu_foreground_color ${colors.text}
    selection_background_color none

    # Selection Highlight
    selection_big EFI/refind/themes/claude/selection_big.png
    selection_small EFI/refind/themes/claude/selection_small.png

    # Logo (optional)
    banner_logo EFI/refind/themes/claude/logo.png
    banner_logo_pos 50% 10%

    # Animation settings
    animate_icons 1
    anim_duration 300

    # ---- Menu Entries ----
    menuentry "🦊 FoxOS (Claude Theme)" {
        icon os_foxos.png
        loader /EFI/nixos/grubx64.efi
    }
    menuentry "❄️ NixOS Generations" {
        icon os_nixos_gen.png
        loader /EFI/boot/bootx64.efi
    }
    menuentry "📊 System Tools" {
        icon tool_shell.png
        loader /EFI/tools/shell.efi
    }
    menuentry "🛟 Recovery" {
        icon tool_rescue.png
        loader /EFI/tools/recovery.efi
    }
  '';

  # ----- 📦 Theme Package Derivation ----- #
  themePackage = pkgs.stdenv.mkDerivation {
    name = "refind-theme-claude";
    src = ./.; # Not really used when generating assets

    buildInputs = [ pkgs.imagemagick pkgs.makeWrapper pkgs.dejavu_fonts ];

    # Pass paths of generated assets to the builder script
    inherit banner selection_big selection_small themeConfContent logo;
    # Pass icon paths
    inherit icon_foxos icon_nixos_gen icon_arch icon_garuda;
    inherit tool_shell tool_rescue;

    installPhase = ''
      THEME_DIR=$out/EFI/refind/themes/claude
      ICON_DIR=$THEME_DIR/icons
      mkdir -p $ICON_DIR

      echo "Installing Claude theme assets..."

      # Copy main assets
      cp ${banner}/banner.png $THEME_DIR/banner.png
      cp ${selection_big}/selection_big.png $THEME_DIR/selection_big.png
      cp ${selection_small}/selection_small.png $THEME_DIR/selection_small.png
      cp ${logo}/logo.png $THEME_DIR/logo.png

      # Copy generated OS icons
      cp ${icon_foxos}/os_foxos.png $ICON_DIR/os_foxos.png
      cp ${icon_nixos_gen}/os_nixos_gen.png $ICON_DIR/os_nixos_gen.png
      cp ${icon_arch}/os_arch.png $ICON_DIR/os_arch.png
      cp ${icon_garuda}/os_garuda.png $ICON_DIR/os_garuda.png
      
      # Copy tool icons
      cp ${tool_shell}/os_shell.png $ICON_DIR/tool_shell.png
      cp ${tool_rescue}/os_rescue.png $ICON_DIR/tool_rescue.png

      # Write the configuration file
      cp ${themeConfContent} $THEME_DIR/theme.conf

      echo "Claude Theme installed to $out"
    '';

    meta = {
      description = "rEFInd Theme: Claude for FoxOS";
      longDescription = ''
        A sleek, purple-gradient theme for the rEFInd boot manager inspired by 
        Claude's visual aesthetic. Features elegant backgrounds, custom OS icons,
        and a clean, modern interface with subtle animations.
      '';
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
      maintainers = [ ];
    };
  };

in
{
  # ----- Options Definition ----- #
  options = {
    # Adjust the path here based on the final directory structure
    ${lib.strings.removeSuffix "." (lib.concatMapStringsSep "." (x: x) (lib.splitString "." "foxos.desktop.theming.bootloader.custom.claude"))} = {
      enable = lib.mkEnableOption "Enable the Claude rEFInd theme.";

      variant = lib.mkOption {
        type = lib.types.enum [ "standard" "minimal" ];
        default = "standard";
        description = "Claude theme variant (standard includes more visual effects).";
      };
    };
  };

  # ----- Configuration Activation ----- #
  config = lib.mkIf cfg.enable {
    # Register this theme so it can be selected
    foxos.desktop.theming.bootloader.availableThemes.claude = {
      name = "claude";  # Used by refind `include themes/claude/theme.conf`
      package = themePackage;
      description = "Claude: A sophisticated purple theme inspired by Claude's visual identity.";
    };

    # The actual theme activation should be handled by the main bootloader module
  };
}

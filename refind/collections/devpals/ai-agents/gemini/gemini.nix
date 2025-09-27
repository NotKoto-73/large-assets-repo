# ./modules/nixos/desktop/theming/bootloader/ai/gemini.nix
# (Or wherever themes end up in the final structure)

{ config, pkgs, lib, ... }:

let
  # Gemini-inspired Color Palette
  geminiColors = {
    deepSpace = "#0f052d";     # Dark purple/blue background
    primary = "#61affe";       # Bright sky blue
    secondary = "#c06bff";     # Vibrant magenta/purple
    accent = "#fce38a";       # Gold/Yellow star-like accent
    text = "#ececec";          # Light text
    highlightBg = "rgba(97,175,254,0.4)"; # Semi-transparent blue highlight
  };

  # Helper to generate simple icons with ImageMagick
  # Creates a rounded square icon with a central symbol/letter
  mkIcon = { name, symbol ? "", bgColor ? geminiColors.primary, fgColor ? geminiColors.text, size ? 128 }:
    pkgs.runCommand "gemini-icon-${name}" { buildInputs = [ pkgs.imagemagick ]; } ''
      convert -size ${toString size}x${toString size} xc:none \
        -fill "${bgColor}" -draw "roundrectangle 0,0 ${toString size},${toString size} 20,20" \
        ${lib.optionalString (symbol != "") ''-pointsize ${toString (size * 3 / 5)} -fill "${fgColor}" -gravity center -annotate +0+0 "${symbol}"''} \
        $out/icon.png
    '';

  # Generate Background - Abstract cosmic gradient/blend
  background = pkgs.runCommand "gemini-background.png" { buildInputs = [ pkgs.imagemagick ]; } ''
    convert -size 1920x1080 \
      canvas:'${geminiColors.deepSpace}' \
      \( -size 960x1080 gradient:'${geminiColors.primary}'-'${geminiColors.deepSpace}' -rotate -60 \) \
      -compose screen -composite \
      \( -size 960x1080 gradient:'${geminiColors.secondary}'-'${geminiColors.deepSpace}' -rotate 60 \) \
      -compose screen -composite \
      -spread 5 \
      -blur 0x3 \
      $out/background.png
  '';
   # Generate Selection Graphic - Simple translucent gradient bar
  selection = pkgs.runCommand "gemini-selection.png" { buildInputs = [ pkgs.imagemagick ]; } ''
    convert -size 512x128 gradient:'${geminiColors.highlightBg}'-'${lib.replaceStrings ["a("] [""] geminiColors.highlightBg}' \
      -alpha set \
      $out/selection_big.png
  '';

   # Gemini Logo (simple stylized 'G' or star)
  logo = mkIcon { name = "logo"; symbol = "♊"; bgColor = geminiColors.accent; fgColor = geminiColors.deepSpace; size = 128; };

  # OS Icons
  foxosIcon = mkIcon { name = "foxos"; symbol = "🦊"; bgColor = geminiColors.primary; size = 96; };
  nixosIcon = mkIcon { name = "nixos-gen"; symbol = "❄️"; bgColor = geminiColors.secondary; size = 96; };
  archIcon = mkIcon { name = "arch"; symbol = "A"; bgColor = "#1793d1"; size = 96; }; # Arch Blue
  garudaIcon = mkIcon { name = "garuda"; symbol = "🦅"; bgColor = "#e54b1e"; size = 96; }; # Garuda Orange

  # Theme Configuration File Content
  themeConfContent = ''
    # rEFInd Theme: Gemini - Refined for FoxOS
    # Style: Cosmic Blues, Purples, Energetic Highlights

    # General Appearance
    resolution max
    use_graphics_for linux,grub
    banner background.png
    banner_scale fillscreen
    icon_size 96
    font ${pkgs.ubuntu_font_family}/share/fonts/truetype/Ubuntu-Regular.ttf
    text_color ${geminiColors.text}
    # menu_color same as text_color unless specified

    # Selection Highlight
    selection_big selection_big.png
    selection_small selection_big.png # Use the same for small for simplicity
    selection_background none # Let the graphic handle background
    selection_indicator none # Don't need default indicator arrow

    # Hide unnecessary elements
    hideui hints,label,singleuser,arrows,badges

    # Boot Banner Logo (Optional)
    # If you have a nice theme logo - currently using text symbols
    # banner_logo logo.png
    # banner_logo_pos 50% 10%

    # Boot Timeout
    timeout 7 # A moment to appreciate the stars

    # Default Menu Entries (Customize loaders/paths as needed in final config)
    menuentry "🦊 FoxOS" {
        icon EFI/refind/themes/gemini/icons/os_foxos.png
        loader /EFI/nixos/grubx64.efi # Example path
        graphics on
    }
    menuentry "❄️ NixOS Generations" {
        icon EFI/refind/themes/gemini/icons/os_nixos_gen.png
        loader /EFI/boot/bootx64.efi # Example path
        # Use 'submenuentry' in real refind.conf for generations
        graphics on
    }
    menuentry "🐧 Arch Linux" {
        icon EFI/refind/themes/gemini/icons/os_arch.png
        loader /EFI/arch/grubx64.efi # Example path
        volume ARCH_ESP_UUID # Specify volume via UUID/PARTUUID/LABEL
    }
    menuentry "🦅 Garuda Linux" {
        icon EFI/refind/themes/gemini/icons/os_garuda.png
        loader /EFI/Garuda/grubx64.efi # Example path
        volume GARUDA_ESP_UUID # Specify volume
    }

    # Auto-detected EFI Boot Managers (Windows, macOS etc) will use default icons
    # You can override: os_windows icons/os_win.png, os_mac icons/os_mac.png
  '';

  # Theme Package Derivation using stdenv
  geminiThemePackage = pkgs.stdenv.mkDerivation {
    name = "refind-theme-gemini-refined";
    src = ./.; # Technically not needed as we generate everything
    buildInputs = [ pkgs.makeWrapper ]; # Not strictly needed here, but good practice

    # Pass generated assets' paths to the build script
    inherit background selection logo foxosIcon nixosIcon archIcon garudaIcon;

    installPhase = ''
      THEME_DIR=$out/EFI/refind/themes/gemini
      ICON_DIR=$THEME_DIR/icons
      mkdir -p $ICON_DIR

      # Copy generated assets
      cp ${background}/background.png $THEME_DIR/background.png
      cp ${selection}/selection_big.png $THEME_DIR/selection_big.png
      cp ${logo}/icon.png $THEME_DIR/logo.png

      cp ${foxosIcon}/icon.png $ICON_DIR/os_foxos.png
      cp ${nixosIcon}/icon.png $ICON_DIR/os_nixos_gen.png
      cp ${archIcon}/icon.png $ICON_DIR/os_arch.png
      cp ${garudaIcon}/icon.png $ICON_DIR/os_garuda.png

      # Write the theme configuration file
      echo "${themeConfContent}" > $THEME_DIR/theme.conf

      echo "Gemini rEFInd theme assets installed to $out"
    '';

    # Ensure generated assets are included as inputs implicitly
    # The direct references in installPhase handle this.

    # Meta information
    meta = {
      description = "A Gemini-inspired rEFInd theme for FoxOS with procedural assets";
      license = lib.licenses.mit; # Or your preferred license
      platforms = lib.platforms.all;
    };
  };

in
{
  # This defines the theme structure as used in your previous example
  # For standard NixOS, you might just return the package derivation
  boot.loader.refind.themes.available.gemini = {
    name = "gemini"; # The name rEFInd uses in refind.conf `include themes/gemini/theme.conf`
    package = geminiThemePackage;
  };
}

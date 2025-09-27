{ config, pkgs, lib, ... }:

let
  optionPath = config.foxos.desktop.theming.bootloader.custom."nyan-mode";
  cfg = optionPath;

  colors = {
    background = "#000000";
    primary = "#ff66cc";
    secondary = "#66ccff";
    accent = "#ffff66";
    text = "#ffffff";
    highlightBg = "rgba(255, 102, 204, 0.3)";
  };

  banner = pkgs.runCommand "nyan-mode-banner" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    convert -size 1920x1080 xc:black -gravity center \
      -font Liberation-Sans -pointsize 72 -fill "${colors.accent}" \
      -draw "text 0,0 'NYAN MODE INITIATED'" \
      $out/banner.png
  '';

  selection_big = pkgs.runCommand "nyan-mode-selection-big" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    convert -size 128x128 xc:none -fill "${colors.primary}" \
      -draw "circle 64,64 64,0" $out/selection_big.png
  '';

  selection_small = pkgs.runCommand "nyan-mode-selection-small" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    convert -size 48x48 xc:none -fill "${colors.secondary}" \
      -draw "circle 24,24 24,0" $out/selection_small.png
  '';

  icon_foxos = pkgs.runCommand "nyan-mode-icon-foxos" {} ''mkdir -p $out; echo '🐱' > $out/os_foxos.png'';
  icon_nixos_gen = pkgs.runCommand "nyan-mode-icon-nixos-gen" {} ''mkdir -p $out; echo '❄️' > $out/os_nixos_gen.png'';
  icon_arch = pkgs.runCommand "nyan-mode-icon-arch" {} ''mkdir -p $out; echo '🏹' > $out/os_arch.png'';
  icon_garuda = pkgs.runCommand "nyan-mode-icon-garuda" {} ''mkdir -p $out; echo '🦅' > $out/os_garuda.png'';
  logo = pkgs.runCommand "nyan-mode-logo" {} ''mkdir -p $out; echo '🌈' > $out/logo.png'';

  themeConfContent = let
    timeoutValue = toString (config.foxos.desktop.theming.bootloader.timeout or 5);
    resolutionValue = config.foxos.desktop.theming.bootloader.resolution or "1920x1080";
  in pkgs.writeText "theme.conf" ''
    resolution ${resolutionValue}
    timeout ${timeoutValue}
    use_graphics_for linux,grub
    banner EFI/refind/themes/nyan-mode/banner.png
    banner_scale fillscreen
    icons_dir EFI/refind/themes/nyan-mode/icons
    icon_size 128
    small_icon_size 48
    font ${pkgs.ubuntu_font_family}/share/fonts/truetype/Ubuntu-Regular.ttf
    text_color ${colors.text}
    selection_big EFI/refind/themes/nyan-mode/selection_big.png
    selection_small EFI/refind/themes/nyan-mode/selection_small.png
    selection_background none

    menuentry "🦊 FoxOS (Nyan Mode)" {
      icon os_foxos.png
      loader /EFI/nixos/grubx64.efi
    }
    menuentry "❄️ NixOS Generations (Nyan Mode)" {
      icon os_nixos_gen.png
      loader /EFI/boot/bootx64.efi
    }
  '';

  themePackage = pkgs.stdenv.mkDerivation {
    name = "refind-theme-nyan-mode";
    buildInputs = [ pkgs.makeWrapper ];
    inherit banner selection_big selection_small themeConfContent logo;
    inherit icon_foxos icon_nixos_gen icon_arch icon_garuda;
    installPhase = ''
      THEME_DIR=$out/EFI/refind/themes/nyan-mode
      ICON_DIR=$THEME_DIR/icons
      mkdir -p $ICON_DIR
      cp ${banner}/*.png $THEME_DIR/banner.png
      cp ${selection_big}/*.png $THEME_DIR/selection_big.png
      cp ${selection_small}/*.png $THEME_DIR/selection_small.png
      cp ${logo}/*.png $THEME_DIR/logo.png
      cp ${icon_foxos}/*.png $ICON_DIR/os_foxos.png
      cp ${icon_nixos_gen}/*.png $ICON_DIR/os_nixos_gen.png
      cp ${icon_arch}/*.png $ICON_DIR/os_arch.png
      cp ${icon_garuda}/*.png $ICON_DIR/os_garuda.png
      cp ${themeConfContent} $THEME_DIR/theme.conf
    '';
    dontStrip = true;
    dontPatchELF = true;
    dontFixup = true;
    meta = {
      description = "rEFInd Theme: Nyan Mode for FoxOS";
      license = lib.licenses.mit;
      platforms = lib.platforms.all;
    };
  };

in {
  options.foxos.desktop.theming.bootloader.custom."nyan-mode" = {
    enable = lib.mkEnableOption "Enable the Nyan Mode rEFInd theme.";
  };

  config = lib.mkIf cfg.enable {
    foxos.desktop.theming.bootloader.availableThemes."nyan-mode" = {
      name = "nyan-mode";
      package = themePackage;
      description = "Nyan Mode: A rainbow rEFInd theme for FoxOS.";
    };
  };
}


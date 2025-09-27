{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.foxos.themeland.themes.refind.foxos-astrology;
  themeland = config.foxos.themeland;
  
  # Resolve assets using smart resolution
  assetsPath = themeland.resolveAssets {
    loader = "refind";
    theme = "foxos-astrology";
    variant = cfg.variant;
    themeInputs = {}; # Will be passed by the module system
    config = config;
  };
  
in {
  options.foxos.themeland.themes.refind.foxos-astrology = {
    enable = mkEnableOption "FoxOS Astrology REfind Theme";
    
    variant = mkOption {
      type = types.enum [ "dark-moon" "full-moon" "solar" "cosmic" ];
      default = "dark-moon";
      description = "Astrology theme variant";
    };
  };
  
  config = mkIf cfg.enable {
    # Install theme assets
    environment.etc."refind.d/themes/foxos-astrology".source = assetsPath;
    
    # Configure REfind
    boot.loader.refind = {
      theme = "foxos-astrology";
      extraConfig = ''
        include themes/foxos-astrology/theme.conf
        
        # Custom astrology menu entries
        menuentry "🌟 FoxOS (Mystical Mode)" {
          icon themes/foxos-astrology/icons/os_foxos_${cfg.variant}.png
          loader /EFI/nixos/grubx64.efi
        }
        
        menuentry "🌙 NixOS Generations" {
          icon themes/foxos-astrology/icons/os_nixos_${cfg.variant}.png
          loader /EFI/systemd/systemd-bootx64.efi
        }
      '';
    };
    
    # System activation
    system.activationScripts.refind-foxos-astrology = ''
      mkdir -p /boot/EFI/refind/themes
      ln -sf /etc/refind.d/themes/foxos-astrology /boot/EFI/refind/themes/foxos-astrology
    '';
    
    # Register in themeland
    foxos.themeland.registry.refind.foxos-astrology = {
      displayName = "🌟 FoxOS Astrology";
      description = "Mystical astrology-themed REfind boot experience";
      tags = [ "mystical" "astrology" "foxos" "cosmic" "original" ];
      variants = [ "dark-moon" "full-moon" "solar" "cosmic" ];
      author = "FoxOS Labs";
      version = "2.0.0";
      collection = "foxos-mystical";
      loader = "refind";
    };
  };
}

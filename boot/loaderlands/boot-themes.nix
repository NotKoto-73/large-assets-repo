# modules/boot/themes.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.boot.themes;
in

{
  options.boot.themes = {
    plymouth = {
      enable = mkEnableOption "Plymouth boot splash";
      
      theme = mkOption {
        type = types.str;
        default = "dragon_btw";  # Updated to dragon theme
        description = "Plymouth theme name";
      };
    };

    grub = {
      dedsec = {
        enable = mkEnableOption "DedSec GRUB theme";
        
        style = mkOption {
          type = types.str;
          default = "wannacry";
          description = "DedSec style variant";
        };
        
        resolution = mkOption {
          type = types.str;
          default = "1440p";
          description = "Display resolution";
        };
        
        icon = mkOption {
          type = types.enum [ "color" "white" ];
          default = "color";
          description = "Icon style to use";
        };
      };
    };

    systemd = {
      nixos-boot = {
        enable = mkEnableOption "nixos-boot systemd-boot theming";
        
        theme = mkOption {
          type = types.str;
          default = "modern";
          description = "nixos-boot theme variant";
        };
      };
      
      dedsec = {
        enable = mkEnableOption "DedSec-style systemd-boot theme";
        
        style = mkOption {
          type = types.enum [ "wannacry" "sitedown" "hacker" ];
          default = "wannacry";
          description = "DedSec style variant";
        };
      };
    };
  };

  config = mkMerge [
    # Plymouth configuration
    (mkIf cfg.plymouth.enable {
      boot.plymouth = {
        enable = true;
        theme = cfg.plymouth.theme;
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = [ cfg.plymouth.theme ];
          })
        ];
      };
    })

    # GRUB theming (only when GRUB is already enabled)
    (mkIf (config.boot.bootloader.grub.enable && cfg.grub.dedsec.enable) {
      boot.loader.grub.dedsec-theme = {
        enable = true;
        style = cfg.grub.dedsec.style;
        resolution = cfg.grub.dedsec.resolution;
        icon = cfg.grub.dedsec.icon;
      };
    })

    # systemd-boot theming (only when systemd-boot is already enabled)
    (mkIf (config.boot.bootloader.systemd-boot.enable && cfg.systemd.nixos-boot.enable) {
      boot.loader.systemd-boot.theme = cfg.systemd.nixos-boot.theme;
      
      # Add nixos-boot package
      environment.systemPackages = [
        # Will need to add nixos-boot package here
      ];
    })
  ];
}

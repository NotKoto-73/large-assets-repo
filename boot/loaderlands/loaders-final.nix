# boot/loaderlands/loaders-final.nix
# Main bootloader coordination module - no more defaults!
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.boot.bootSelection;
  themeCfg = config.boot.themes;
  themelandCfg = config.foxos.themeland or {};
in

{
  # ═══════════════════════════════════════════════════════════════
  # BOOTLOADER SELECTION OPTIONS
  # ═══════════════════════════════════════════════════════════════
  options.boot.bootSelection = {
    bootloader = mkOption {
      type = types.enum [ "grub" "systemd-boot" "refind" ];
      default = "systemd-boot";
      description = "Primary bootloader to use";
    };
    
    enableThemes = mkOption {
      type = types.bool;
      default = true;
      description = "Enable visual theming for selected bootloader";
    };
    
    enablePlymouth = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Plymouth boot splash";
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # BOOTLOADER CONFIGURATION
  # ═══════════════════════════════════════════════════════════════
  config = mkMerge [
    # Base EFI configuration
    {
      boot.loader = {
        efi.canTouchEfiVariables = true;
        timeout = 10;
      };
    }
    
    # ─────────────────────── GRUB CONFIGURATION ───────────────────────
    (mkIf (cfg.bootloader == "grub") {
      boot.loader = {
        grub.enable = true;
        systemd-boot.enable = false;
        refind.enable = false;
      };
      
      # Apply GRUB themes if enabled
      boot.themes.grub = mkIf cfg.enableThemes {
        dedsec = mkIf (themeCfg.grub.dedsec.enable or false) {
          enable = true;
          inherit (themeCfg.grub.dedsec) style resolution icon;
        };
      };
      
      # Plymouth for GRUB systems
      boot.themes.plymouth = mkIf cfg.enablePlymouth {
        enable = true;
        theme = themeCfg.plymouth.theme or "dragon";
      };
    })
    
    # ─────────────────────── SYSTEMD-BOOT CONFIGURATION ───────────────────────
    (mkIf (cfg.bootloader == "systemd-boot") {
      boot.loader = {
        systemd-boot.enable = true;
        grub.enable = false;
        refind.enable = false;
      };
      
      # Apply systemd-boot themes if enabled
      boot.themes.systemd = mkIf cfg.enableThemes {
        nixos-boot = mkIf (themeCfg.systemd.nixos-boot.enable or false) {
          enable = true;
          inherit (themeCfg.systemd.nixos-boot) theme;
        };
        
        dedsec = mkIf (themeCfg.systemd.dedsec.enable or false) {
          enable = true;
          inherit (themeCfg.systemd.dedsec) style timeout showEditor;
        };
      };
      
      # Plymouth for systemd-boot systems
      boot.themes.plymouth = mkIf cfg.enablePlymouth {
        enable = true;
        theme = themeCfg.plymouth.theme or "evil-nix";
      };
    })
    
    # ─────────────────────── REFIND CONFIGURATION ───────────────────────
    (mkIf (cfg.bootloader == "refind") {
      boot.loader = {
        refind.enable = true;
        grub.enable = false;
        systemd-boot.enable = false;
      };
      
      # Apply REfind themes via themeland if available
      foxos.themeland = mkIf (themelandCfg.enable or false) {
        activeLoader = "refind";
        # Theme configuration handled by individual theme modules
      };
      
      # Plymouth for REfind systems
      boot.themes.plymouth = mkIf cfg.enablePlymouth {
        enable = true;
        theme = themeCfg.plymouth.theme or "dragon";
      };
    })
  ];
  
  # ═══════════════════════════════════════════════════════════════
  # AUTOMATIC LOADER OPTIMIZATION
  # ═══════════════════════════════════════════════════════════════
  config = {
    # Optimize systemd for faster boot times
    systemd.services."NetworkManager-wait-online".enable = mkDefault false;
    systemd.settings.Manager = mkIf (cfg.bootloader == "systemd-boot") {
      DefaultTimeoutStartSec = "10s";
      DefaultTimeoutStopSec = "5s";
    };
    
    # GRUB optimizations
    boot.loader.grub = mkIf (cfg.bootloader == "grub") {
      efiSupport = true;
      device = "nodev";
      gfxmodeBios = "1440x900";
      gfxpayloadBios = "keep";
      configurationLimit = 10;
    };
    
    # Journal optimizations for all loaders
    services.journald.extraConfig = ''
      Storage=persistent
      SystemMaxUse=200M
      RuntimeMaxUse=100M
      SystemMaxFileSize=50M
    '';
  };
}

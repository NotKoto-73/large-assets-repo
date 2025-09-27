{ themeInputs ? {} }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.foxos.themeland;
  refindThemes = config.foxos.themeland.themes.refind or {};
  
in {
  # Auto-import REfind theme modules
  imports = import ../../auto-import.nix { 
    inherit lib; 
    themesPath = ../../../themes/refind; 
  };
  
  config = mkIf (cfg.enable && cfg.activeLoader == "refind") {
    # Enable REfind bootloader
    boot.loader = {
      systemd-boot.enable = false;
      grub.enable = false;
      refind = {
        enable = true;
        # Theme configuration will be set by individual theme modules
      };
    };
    
    # Apply active REfind theme
    foxos.themeland.themes.refind = mkIf (cfg.activeThemes ? refind) {
      ${cfg.activeThemes.refind}.enable = true;
    };
  };
}

{ themeInputs ? {} }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.foxos.themeland;
  
in {
  imports = import ../../auto-import.nix { 
    inherit lib; 
    themesPath = ../../../themes/grub; 
  };
  
  config = mkIf (cfg.enable && cfg.activeLoader == "grub") {
    boot.loader = {
      systemd-boot.enable = false;
      refind.enable = false;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        gfxmodeBios = "1440x900";
        gfxpayloadBios = "keep";
      };
    };
    
    # Apply active GRUB theme
    foxos.themeland.themes.grub = mkIf (cfg.activeThemes ? grub) {
      ${cfg.activeThemes.grub}.enable = true;
    };
  };
}

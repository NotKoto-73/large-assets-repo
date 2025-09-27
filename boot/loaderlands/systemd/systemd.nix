# modules/boot/systemd-boot.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.boot.bootloader.systemd-boot = {
    enable = mkEnableOption "systemd-boot bootloader";
  };

  config = mkIf config.boot.bootloader.systemd-boot.enable {
    boot.loader = {
      systemd-boot = {
        enable = true;
        editor = true;
        configurationLimit = 10;
        extraEntries = {
          "recovery.conf" = ''
            title Recovery Mode
            linux /boot/nixos/kernel
            initrd /boot/nixos/initrd
            options init=/bin/sh
          '';
        };
      };
      grub.enable = false;
    };
    
    # systemd-boot specific optimizations
    systemd.services."NetworkManager-wait-online".enable = false;
    
    # Additional systemd optimizations for fast boot
    systemd.settings.Manager = {
      DefaultTimeoutStartSec = "10s";
      DefaultTimeoutStopSec = "5s";
    };
  };
}

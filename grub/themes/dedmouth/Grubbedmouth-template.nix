{ config, lib, pkgs, ... }:

let
  cfg = config.fox.personalization.grubTheme;
in {
  options.fox.personalization.grubTheme = {
    enable = lib.mkEnableOption "Enable GRUB theming with custom visuals";

    name = lib.mkOption {
      type = lib.types.str;
      default = "dedmouth";
      description = "Theme name used in /boot/grub/themes/";
    };

    source = lib.mkOption {
      type = lib.types.path;
      default = ./dedmouth;
      description = "Path to the Dedmouth GRUB theme directory.";
    };

    splash = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to also enable a matching splash screen (via Plymouth).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install theme
    boot.loader.grub = {
      enable = true;
      configurationLimit = 10;
      theme = "/boot/grub/themes/${cfg.name}";
    };

    environment.etc."grub/themes/${cfg.name}".source = cfg.source;

    system.activationScripts.grubTheme = ''
      mkdir -p /boot/grub/themes
      ln -sf /etc/grub/themes/${cfg.name} /boot/grub/themes/${cfg.name}
    '';

    # Optional: Dedmouth-style splash screen (if included in source)
    boot.plymouth = lib.mkIf cfg.splash {
      enable = true;
      theme = "dedmouth";
    };
  };
}


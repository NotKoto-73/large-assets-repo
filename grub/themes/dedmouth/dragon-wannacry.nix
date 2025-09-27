{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.fox.personalization.grubTheme;
in {
  options.fox.personalization.grubTheme = {
    enable = lib.mkEnableOption "Enable GRUB theming with optional Dragon splash";

    name = lib.mkOption {
      type = lib.types.str;
      default = "wannacry";
      description = "Name of the GRUB theme (from grub-themes folder)";
    };

    splash = lib.mkOption {
      type = lib.types.str;
      default = "dragon";
      description = "Plymouth splash name (from grub-themes folder)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Mount theme to GRUB
    boot.loader.grub.theme = "/boot/grub/themes/${cfg.name}";
    environment.etc."grub/themes/${cfg.name}".source =
      ./grub-themes/${cfg.name};

    system.activationScripts.grubTheme = ''
      mkdir -p /boot/grub/themes
      ln -sf /etc/grub/themes/${cfg.name} /boot/grub/themes/${cfg.name}
    '';

    # Optional Plymouth splash
    boot.plymouth.enable = true;
    boot.plymouth.theme = cfg.splash;
    environment.etc."plymouth/themes/${cfg.splash}".source =
      ./grub-themes/${cfg.splash};
  };
}


{ config, lib, ... }:

let
  cfg = config.fox.personalization.refindTheme;
in {
  options.fox.personalization.refindTheme = {
    enable = lib.mkEnableOption "Enable DedMouth rEFInd visuals";

    name = lib.mkOption {
      type = lib.types.str;
      default = "dedmouth";
      description = "Name of the rEFInd theme folder (inside /boot/efi/EFI/refind/themes/).";
    };

    source = lib.mkOption {
      type = lib.types.path;
      default = ./dedmouth; # Path to your local theme folder
      description = "Local directory containing rEFInd theme assets (theme.conf, icons, backgrounds)";
    };

    icons = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      description = "Extra icons to link in rEFInd's EFI/icons folder if needed.";
    };

    menuEntries = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra rEFInd entries or overrides to append to refind.conf.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."refind.d/themes/${cfg.name}".source = cfg.source;

    system.activationScripts.refindTheme = ''
      mkdir -p /boot/efi/EFI/refind/themes
      ln -sf /etc/refind.d/themes/${cfg.name} /boot/efi/EFI/refind/themes/${cfg.name}
    '';

    boot.loader.refind.extraFiles = cfg.icons;
    boot.loader.refind.extraConfig = cfg.menuEntries;
  };
}


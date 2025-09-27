{ config, lib, pkgs, ... }:

let
  themeName = "tarot";
in
{
  options.fox.personalization.refindThemes.${themeName} = {
    enable = lib.mkEnableOption "Enable the rEFInd Tarot theme.";

    source = lib.mkOption {
      type = lib.types.path;
      default = pkgs.fetchurl {
        url = "https://example.com/tarot-refind-theme.tar.gz";
        sha256 = "sha256-deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdead";
      };
      description = "Tarot rEFInd theme archive.";
    };

    icons = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "Optional icon overrides.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra rEFInd config lines (e.g. menu entries).";
    };
  };

  config = lib.mkIf config.fox.personalization.refindThemes.${themeName}.enable {
    environment.etc."refind.d/themes/${themeName}".source =
      config.fox.personalization.refindThemes.${themeName}.source;

    system.activationScripts.refindTarotTheme = ''
      mkdir -p /boot/efi/EFI/refind/themes
      ln -sf /etc/refind.d/themes/${themeName} /boot/efi/EFI/refind/themes/${themeName}
    '';

    boot.loader.refind.extraFiles =
      config.fox.personalization.refindThemes.${themeName}.icons;

    boot.loader.refind.extraConfig =
      config.fox.personalization.refindThemes.${themeName}.extraConfig;
  };
}


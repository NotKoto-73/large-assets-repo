{ config, lib, pkgs, ... }:

let
  themeName = "foxfire";
in
{
  options.fox.personalization.refindThemes.${themeName} = {
    enable = lib.mkEnableOption "Enable the official Foxfire rEFInd theme.";

    source = lib.mkOption {
      type = lib.types.path;
      default = pkgs.fetchFromGitHub {
        owner = "fox-os";
        repo = "refind-theme-foxfire";
        rev = "main"; # Replace with commit hash if pinned
        sha256 = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa="; # 🔧 insert correct hash later
      };
      description = "Official FoxOS rEFInd boot theme: frosty, fiery, and cunning.";
    };

    icons = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = "FoxOS-specific boot icons (e.g., fox-logo, alt-sigil).";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = ''
        # Welcome to FoxOS
        timeout 5
        default_selection FoxOS
        use_graphics_for osx, linux
      '';
      description = "Extra rEFInd config entries to apply the Foxfire vibe.";
    };
  };

  config = lib.mkIf config.fox.personalization.refindThemes.${themeName}.enable {
    environment.etc."refind.d/themes/${themeName}".source =
      config.fox.personalization.refindThemes.${themeName}.source;

    system.activationScripts.refindFoxfireTheme = ''
      mkdir -p /boot/efi/EFI/refind/themes
      ln -sf /etc/refind.d/themes/${themeName} /boot/efi/EFI/refind/themes/${themeName}
    '';

    boot.loader.refind.extraFiles =
      config.fox.personalization.refindThemes.${themeName}.icons;

    boot.loader.refind.extraConfig =
      config.fox.personalization.refindThemes.${themeName}.extraConfig;
  };
}


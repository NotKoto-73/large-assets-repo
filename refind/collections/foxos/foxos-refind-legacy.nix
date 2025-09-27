{ lib, config, pkgs, ... }:

let
  cfg = config.fox.personalization.refindTheme;

  defaultIcons = {
    "icons/os_nixos.png" = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/nixos/nixos-artwork/master/logo/nix-snowflake.svg";
      sha256 = "14mbpw8jv1w2c5wvfvj8clmjw0fi956bq5xf9s2q3my14far0as8";
    };
    "icons/os_arch.png" = pkgs.fetchurl {
      url = "https://archlinux.org/static/logos/archlinux-logo-dark-90dpi.ebdee92a15b3.png";
      sha256 = "1q7fk7jv26gvmbf6wm9f0p6bpqibskrl0jyhf93pv5pqqib7lya2";
    };
    "icons/os_garuda.png" = pkgs.fetchurl {
      url = "https://avatars.githubusercontent.com/u/73544069?s=200&v=4";
      sha256 = "0bpgsbkl3fsmzzjx95m70f0hsjqf0d9zs4xnvhvcvxgxl6xpqz9c";
    };
  };

  defaultMenu = ''
    timeout ${toString cfg.timeout or 10}
    scanfor manual,internal,external,optical,uefi
    scan_delay 1
    also_scan_dirs boot,EFI/boot,EFI/os
    dont_scan_volumes "Recovery|Windows"

    include themes/${cfg.name}/${cfg.configFile or "theme.conf"}
    default_selection "${cfg.defaultSelection or "FoxOS"}"

    enable_secure_boot

    menuentry "🦊 FoxOS (NixOS)" {
      icon /EFI/refind/icons/os_nixos.png
      loader /EFI/nixos/grubx64.efi
      submenuentry "Normal Boot" {
        loader /EFI/nixos/grubx64.efi
      }
      submenuentry "🧪 Configure Options" {
        options "init=/nix/store/current-system/init loglevel=4"
      }
      submenuentry "Recovery Mode" {
        options "init=/nix/store/current-system/init single nomodeset loglevel=7"
      }
    }

    menuentry "NixOS Generations" {
      icon /EFI/refind/icons/os_nixos.png
      loader /nix/var/nix/profiles/system-*-link/loader/grubx64.efi
      graphics on
    }

    menuentry "Arch Linux" {
      icon /EFI/refind/icons/os_arch.png
      volume ARCH_ROOT
      loader /boot/vmlinuz-linux
      initrd /boot/initramfs-linux.img
      options "root=PARTUUID=XXXX-XXXX rootfstype=btrfs rw add_efi_memmap"
    }

    menuentry "Garuda Linux" {
      icon /EFI/refind/icons/os_garuda.png
      volume GARUDA_ROOT
      loader /boot/vmlinuz-linux
      initrd /boot/initramfs-linux.img
      options "root=PARTUUID=XXXX-XXXX rootfstype=btrfs rw add_efi_memmap"
    }
  '';
in {
  options.fox.personalization.refindTheme = {
    enable = lib.mkEnableOption "Enable a themed rEFInd menu";

    name = lib.mkOption {
      type = lib.types.str;
      description = "Name of the theme folder inside refind.d/themes/";
    };

    source = lib.mkOption {
      type = lib.types.path;
      description = "Path or package source of the rEFInd theme";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Main theme config file, defaults to 'theme.conf'";
    };

    icons = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
      default = defaultIcons;
      description = "Custom icons for rEFInd menu entries";
    };

    menuEntries = lib.mkOption {
      type = lib.types.lines;
      default = defaultMenu;
      description = "Custom menu entries appended to rEFInd config";
    };

    timeout = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = 10;
      description = "Timeout for rEFInd menu (in seconds)";
    };

    defaultSelection = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "FoxOS";
      description = "Default boot entry to select in rEFInd";
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

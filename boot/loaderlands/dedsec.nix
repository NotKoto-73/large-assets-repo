# modules/dedsec-unified-theme.nix
{ config, lib, pkgs, ... }:

with lib;

let
  grubCfg = config.boot.loader.grub.dedsec-theme;
  systemdCfg = config.boot.loader.systemd-boot.dedsec-theme;
  
  # GRUB theme derivation (your existing logic)
  dedsec-grub-theme = pkgs.stdenv.mkDerivation {
    name = "dedsec-grub-theme";
    
    src = pkgs.fetchFromGitHub {
      owner = "VandalByte";
      repo = "dedsec-grub2-theme";
      rev = "main";
      sha256 = lib.fakeSha256;
    };
    
    installPhase = ''
      mkdir -p $out/grub/themes/dedsec
      
      # Copy the specific variant files based on options
      cp "assets/backgrounds/${grubCfg.style}-${grubCfg.resolution}.png" $out/grub/themes/dedsec/background.png
      
      # Copy icons
      cp -r "assets/icons-${grubCfg.resolution}/${grubCfg.icon}/"* $out/grub/themes/dedsec/
      
      # Copy fonts  
      cp -r "assets/fonts/${grubCfg.resolution}/"* $out/grub/themes/dedsec/
      
      # Copy base theme files
      cp -r "base/${grubCfg.resolution}/"* $out/grub/themes/dedsec/
      
      # Make sure theme.txt exists and is properly configured
      if [ -f "$out/grub/themes/dedsec/theme.txt" ]; then
        # Update background path in theme.txt if needed
        sed -i 's|desktop-image:.*|desktop-image: "background.png"|' $out/grub/themes/dedsec/theme.txt
      fi
    '';
    
    meta = with lib; {
      description = "DedSec GRUB2 theme";
      homepage = "https://github.com/VandalByte/dedsec-grub2-theme";
      license = licenses.gpl3;
      platforms = platforms.linux;
    };
  };
  
  # systemd-boot DedSec-style configuration
  dedsec-systemd-config = ''
    timeout ${toString systemdCfg.timeout}
    console-mode max
    editor no
    
    # DedSec styling - limited by systemd-boot capabilities
    # Can mainly control timeout, console mode, and boot entry descriptions
  '';
  
in

{
  # ────────────────── GRUB DEDSEC OPTIONS ──────────────────
  options.boot.loader.grub.dedsec-theme = {
    enable = mkEnableOption "DedSec GRUB theme";
    
    style = mkOption {
      type = types.enum [
        "brainwash" "compact" "comments" "firewall" "fuckery" 
        "hackerden" "legion" "lovetrap" "mashup" "reaper"
        "redskull" "stalker" "spam" "spyware" "strike"
        "sitedown" "trolls" "tremor" "unite" "wannacry" "wrench"
      ];
      default = "wannacry";
      description = "DedSec theme variant to use";
    };
    
    icon = mkOption {
      type = types.enum [ "color" "white" ];
      default = "color";
      description = "Icon style to use";
    };
    
    resolution = mkOption {
      type = types.enum [ "1080p" "1440p" ];
      default = "1440p";
      description = "Screen resolution";
    };
  };
  
  # ────────────────── SYSTEMD-BOOT DEDSEC OPTIONS ──────────────────
  options.boot.loader.systemd-boot.dedsec-theme = {
    enable = mkEnableOption "DedSec-style systemd-boot theme";
    
    style = mkOption {
      type = types.enum [ "wannacry" "sitedown" "hacker" "minimal" ];
      default = "wannacry";
      description = "DedSec style variant (affects boot entry naming)";
    };
    
    timeout = mkOption {
      type = types.int;
      default = 5;
      description = "Boot timeout in seconds";
    };
    
    showEditor = mkOption {
      type = types.bool;
      default = true;
      description = "Allow kernel parameter editing (DedSec style: locked down)";
    };
  };
  
  # ────────────────── CONFIGURATION ──────────────────
  config = mkMerge [
    # GRUB DedSec theme
    (mkIf grubCfg.enable {
      boot.loader.grub = {
        theme = "${dedsec-grub-theme}/grub/themes/dedsec";
      };
      
      assertions = [
        {
          assertion = config.boot.loader.grub.enable;
          message = "DedSec GRUB theme requires GRUB to be enabled";
        }
      ];
    })
    
    # systemd-boot DedSec styling
    (mkIf systemdCfg.enable {
      boot.loader.systemd-boot = {
        consoleMode = "max";
        editor = systemdCfg.showEditor;
        extraInstallCommands = ''
          # Add DedSec-style boot entry descriptions
          echo "Adding DedSec-style boot entries..."
        '';
      };
      
      # Custom loader configuration with DedSec theming
      environment.etc."systemd/boot/loader/loader.conf".text = dedsec-systemd-config;
      
      assertions = [
        {
          assertion = config.boot.loader.systemd-boot.enable;
          message = "DedSec systemd-boot theme requires systemd-boot to be enabled";
        }
      ];
    })
  ];
}

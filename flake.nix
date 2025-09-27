{
  description = "FoxOS Large Assets Repository";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          # Plymouth theme packages
          plymouth-evil-nix = pkgs.stdenv.mkDerivation {
            name = "plymouth-evil-nix";
            src = ./boot/plymouth/variants/evil-nix-plymouth;
            
            installPhase = ''
              mkdir -p $out/share/plymouth/themes/evil-nix
              cp -r ./* $out/share/plymouth/themes/evil-nix/
              chmod 644 $out/share/plymouth/themes/evil-nix/*
            '';
            
            meta = {
              description = "Evil Nix Plymouth theme with red animated logo";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          plymouth-rainbow-nix = pkgs.stdenv.mkDerivation {
            name = "plymouth-rainbow-nix";
            src = ./boot/plymouth/variants/rainbow-nix-plymouth;
            
            installPhase = ''
              mkdir -p $out/share/plymouth/themes/rainbow-nix
              cp -r ./* $out/share/plymouth/themes/rainbow-nix/
              chmod 644 $out/share/plymouth/themes/rainbow-nix/*
            '';
            
            meta = {
              description = "Rainbow Nix Plymouth theme with colorful animated logo";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          plymouth-pride-nix = pkgs.stdenv.mkDerivation {
            name = "plymouth-pride-nix";
            src = ./boot/plymouth/variants/pride-nix-plymouth;
            
            installPhase = ''
              mkdir -p $out/share/plymouth/themes/pride-nix
              cp -r ./* $out/share/plymouth/themes/pride-nix/
              chmod 644 $out/share/plymouth/themes/pride-nix/*
            '';
            
            meta = {
              description = "Pride Nix Plymouth theme with pride flag colors";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          # Combined package for all plymouth themes
          plymouth-foxos-themes = pkgs.symlinkJoin {
            name = "plymouth-foxos-themes";
            paths = [
              self.packages.${system}.plymouth-evil-nix
              self.packages.${system}.plymouth-rainbow-nix
              self.packages.${system}.plymouth-pride-nix
            ];
            
            meta = {
              description = "FoxOS Plymouth theme collection";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          # DedSec GRUB themes
          grub-dedsec-themes = pkgs.stdenv.mkDerivation {
            name = "grub-dedsec-themes";
            src = ./boot/vandalBytes/dedsec;
            
            installPhase = ''
              mkdir -p $out/share/grub/themes
              cp -r deadsec-1080p $out/share/grub/themes/
              cp -r deadsec-1440p $out/share/grub/themes/
            '';
            
            meta = {
              description = "DedSec GRUB themes collection";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          # Default package
          default = self.packages.${system}.plymouth-foxos-themes;
        };
      }
    ) // {
      # Export asset paths (updated for new structure)
      assets = {
        boot = self + "/boot";
        grub = self + "/boot/grub";
        plymouth = self + "/boot/plymouth";
        systemd = self + "/boot/systemd";
        vandalBytes = self + "/boot/vandalBytes";
        refind = self + "/refind";
        common = self + "/common";
        desktops = self + "/desktops";
      };
      
      # NixOS modules
      nixosModules = {
        foxos-themes = { config, lib, pkgs, ... }: {
          options.foxos.themes = {
            plymouth = {
              enable = lib.mkEnableOption "FoxOS Plymouth themes";
              theme = lib.mkOption {
                type = lib.types.enum [ "evil-nix" "rainbow-nix" "pride-nix" ];
                default = "evil-nix";
                description = "Which FoxOS Plymouth theme to use";
              };
            };
            
            grub = {
              dedsec = {
                enable = lib.mkEnableOption "DedSec GRUB themes";
                style = lib.mkOption {
                  type = lib.types.str;
                  default = "wannacry";
                  description = "DedSec style variant";
                };
                resolution = lib.mkOption {
                  type = lib.types.enum [ "1080p" "1440p" ];
                  default = "1440p";
                  description = "Screen resolution";
                };
              };
            };
          };
          
          config = lib.mkMerge [
            (lib.mkIf config.foxos.themes.plymouth.enable {
              boot.plymouth = {
                enable = true;
                themePackages = [ self.packages.${pkgs.system}.plymouth-foxos-themes ];
                theme = config.foxos.themes.plymouth.theme;
              };
            })
            
            (lib.mkIf config.foxos.themes.grub.dedsec.enable {
              boot.loader.grub = {
                theme = "${self.packages.${pkgs.system}.grub-dedsec-themes}/share/grub/themes/deadsec-${config.foxos.themes.grub.dedsec.resolution}/${config.foxos.themes.grub.dedsec.style}";
              };
            })
          ];
        };
      };
    };
}

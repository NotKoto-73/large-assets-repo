{
  description = "FoxOS Themeworld - Unified Boot Theme System with Integrated Assets";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    
    # Upstream theme repositories (for fallback/reference)
    plymouth-themes = {
      url = "github:adi1090x/plymouth-themes";
      flake = false;
    };
    
    dedsec-grub = {
      url = "github:VandalByte/dedsec-grub2-theme";
      flake = false;
    };
    
    catppuccin-grub = {
      url = "github:catppuccin/grub";
      flake = false;
    };
    
    nixos-boot = {
      url = "github:Melkor333/nixos-boot";
      flake = false;
    };
    
    refind-themes-community = {
      url = "github:bobafetthotmail/refind-theme-regular";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, plymouth-themes, dedsec-grub, catppuccin-grub, nixos-boot, refind-themes-community }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Theme inputs for modules (includes both local assets and upstream)
        themeInputs = {
          # Local integrated assets (this flake)
          themeworld-assets = self;
          
          # Upstream fallbacks
          inherit plymouth-themes dedsec-grub catppuccin-grub nixos-boot refind-themes-community;
        };
        
      in {
        # ═══════════════════════════════════════════════════════════════
        # INTEGRATED ASSET PACKAGES (merged from assets-flake.nix)
        # ═══════════════════════════════════════════════════════════════
        packages = {
          # Plymouth theme packages (from your assets)
          plymouth-evil-nix = pkgs.stdenv.mkDerivation {
            name = "plymouth-evil-nix";
            src = ./boot/themes/plymouth/variants/evil-nix-plymouth;
            
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
            src = ./boot/themes/plymouth/variants/rainbow-nix-plymouth;
            
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
            src = ./boot/themes/plymouth/variants/pride-nix-plymouth;
            
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
          
          # Combined Plymouth package
          plymouth-themeworld-collection = pkgs.symlinkJoin {
            name = "plymouth-themeworld-collection";
            paths = [
              self.packages.${system}.plymouth-evil-nix
              self.packages.${system}.plymouth-rainbow-nix
              self.packages.${system}.plymouth-pride-nix
            ];
            
            meta = {
              description = "FoxOS Themeworld Plymouth collection";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          # DedSec GRUB themes (from your vandalBytes assets)
          grub-dedsec-themeworld = pkgs.stdenv.mkDerivation {
            name = "grub-dedsec-themeworld";
            src = ./boot/themes/vandalBytes/dedsec;
            
            installPhase = ''
              mkdir -p $out/share/grub/themes
              
              # Copy both resolutions
              if [ -d deadsec-1080p ]; then
                cp -r deadsec-1080p $out/share/grub/themes/
              fi
              if [ -d deadsec-1440p ]; then
                cp -r deadsec-1440p $out/share/grub/themes/
              fi
            '';
            
            meta = {
              description = "DedSec GRUB themes - Themeworld integrated";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          # REfind theme collections
          refind-themeworld-collection = pkgs.stdenv.mkDerivation {
            name = "refind-themeworld-collection";
            src = ./boot/themes/refind;
            
            installPhase = ''
              mkdir -p $out/share/refind/themes
              
              # Copy all refind theme collections
              find collections -type d -name "*" -exec cp -r {} $out/share/refind/themes/ \; 2>/dev/null || true
            '';
            
            meta = {
              description = "FoxOS REfind theme collection";
              license = pkgs.lib.licenses.gpl3;
            };
          };
          
          # Development tools
          themeworld-cli = import ./boot/loaderlands/tools/themeworld-cli.nix { inherit pkgs; };
          theme-generator = import ./boot/loaderlands/tools/theme-generator.nix { inherit pkgs; };
          theme-doctor = import ./boot/loaderlands/tools/theme-doctor.nix { inherit pkgs; };
          
          # Default package
          default = self.packages.${system}.plymouth-themeworld-collection;
        };
        
        # ═══════════════════════════════════════════════════════════════
        # DEVELOPMENT SHELL
        # ═══════════════════════════════════════════════════════════════
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nixos-rebuild
            jq
            tree
            imagemagick  # For Plymouth theme creation
            fontconfig
          ] ++ [
            self.packages.${system}.themeworld-cli
            self.packages.${system}.theme-generator
            self.packages.${system}.theme-doctor
          ];
          
          shellHook = ''
            echo "🎡 FoxOS Themeworld Development Environment"
            echo "==========================================="
            echo "📁 Repository: $(pwd)"
            echo ""
            echo "🛠️ Available commands:"
            echo "   themeworld --help       # Main CLI"
            echo "   theme-gen --help        # Generate themes"
            echo "   theme-doctor            # Diagnostics"
            echo ""
            echo "🎨 Plymouth theme creation:"
            echo "   theme-gen plymouth dedsec-wannacry"
            echo ""
            echo "🚀 Get started with your themes!"
          '';
        };
        
        # ═══════════════════════════════════════════════════════════════
        # CLI APPLICATIONS
        # ═══════════════════════════════════════════════════════════════
        apps = {
          default = {
            type = "app";
            program = "${self.packages.${system}.themeworld-cli}/bin/themeworld";
          };
          
          cli = {
            type = "app";
            program = "${self.packages.${system}.themeworld-cli}/bin/themeworld";
          };
          
          generator = {
            type = "app";
            program = "${self.packages.${system}.theme-generator}/bin/theme-gen";
          };
          
          doctor = {
            type = "app";
            program = "${self.packages.${system}.theme-doctor}/bin/theme-doctor";
          };
        };
      }
    ) // {
      # ═══════════════════════════════════════════════════════════════
      # NIXOS MODULES (system-agnostic)
      # ═══════════════════════════════════════════════════════════════
      
      # Main themeworld module (aggregator - replaces default.nix)
      nixosModules.themeworld = { config, lib, pkgs, ... }: {
        imports = [
          # Core infrastructure
          (import ./boot/loaderlands/core/theme-system.nix { 
            themeInputs = {
              themeworld-assets = self;
              inherit plymouth-themes dedsec-grub catppuccin-grub nixos-boot refind-themes-community;
            };
          })
          
          # Visual theming system
          ./boot/loaderlands/boot-themes.nix
          
          # Unified DedSec module
          ./boot/loaderlands/dedsec.nix
          
          # Loader-specific modules
          (import ./boot/loaderlands/grub/grub-final.nix { 
            themeInputs = {
              themeworld-assets = self;
              inherit dedsec-grub catppuccin-grub;
            };
          })
          (import ./boot/loaderlands/refind/refind-final.nix { 
            themeInputs = {
              themeworld-assets = self;
              inherit refind-themes-community;
            };
          })
          (import ./boot/loaderlands/systemd/systemd-final.nix { 
            themeInputs = {
              themeworld-assets = self;
              inherit nixos-boot;
            };
          })
          
          # Aggregated loader configuration
          ./boot/loaderlands/loaders-final.nix
        ] 
        # Auto-import theme modules using specific names
        ++ (import ./boot/loaderlands/auto-import.nix { 
          inherit lib; 
          themesPath = ./boot/themes; 
        });
      };
      
      # Individual loader modules (for selective importing)
      nixosModules.grub = import ./boot/loaderlands/grub/grub-final.nix { 
        themeInputs = {
          themeworld-assets = self;
          inherit dedsec-grub catppuccin-grub;
        };
      };
      
      nixosModules.refind = import ./boot/loaderlands/refind/refind-final.nix { 
        themeInputs = {
          themeworld-assets = self;
          inherit refind-themes-community;
        };
      };
      
      nixosModules.systemd = import ./boot/loaderlands/systemd/systemd-final.nix { 
        themeInputs = {
          themeworld-assets = self;
          inherit nixos-boot;
        };
      };
      
      nixosModules.plymouth = import ./boot/loaderlands/plymouth/plymouth-final.nix { 
        themeInputs = {
          themeworld-assets = self;
          inherit plymouth-themes;
        };
      };
      
      # Unified DedSec theming (your improved module)
      nixosModules.dedsec = ./boot/loaderlands/dedsec.nix;
      
      # Boot themes (visual aspect handling)
      nixosModules.boot-themes = ./boot/loaderlands/boot-themes.nix;
      
      # ═══════════════════════════════════════════════════════════════
      # ASSET EXPORTS (for external consumption)
      # ═══════════════════════════════════════════════════════════════
      assets = {
        boot = self + "/boot";
        themes = self + "/boot/themes";
        grub = self + "/boot/themes/grub";
        plymouth = self + "/boot/themes/plymouth";
        refind = self + "/boot/themes/refind";
        systemd = self + "/boot/themes/systemd";
        vandalBytes = self + "/boot/themes/vandalBytes";
        collections = self + "/boot/themes/collections";
        common = self + "/common";
        desktop = self + "/desktop";
      };
      
      # ═══════════════════════════════════════════════════════════════
      # THEME REGISTRY (auto-populated from themes)
      # ═══════════════════════════════════════════════════════════════
      themeRegistry = {
        plymouth = {
          evil-nix = {
            path = self.assets.plymouth + "/variants/evil-nix-plymouth";
            package = "plymouth-evil-nix";
            description = "Evil Nix Plymouth theme with red animated logo";
            tags = [ "evil" "nix" "red" "animated" ];
          };
          rainbow-nix = {
            path = self.assets.plymouth + "/variants/rainbow-nix-plymouth";
            package = "plymouth-rainbow-nix";
            description = "Rainbow Nix Plymouth theme";
            tags = [ "rainbow" "nix" "colorful" "pride" ];
          };
          pride-nix = {
            path = self.assets.plymouth + "/variants/pride-nix-plymouth";
            package = "plymouth-pride-nix";
            description = "Pride Nix Plymouth theme";
            tags = [ "pride" "nix" "rainbow" "lgbtq" ];
          };
        };
        
        grub = {
          dedsec-collection = {
            path = self.assets.vandalBytes + "/dedsec";
            package = "grub-dedsec-themeworld";
            description = "DedSec GRUB themes collection";
            variants = [ "wannacry" "sitedown" "hacker" "minimal" ];
            resolutions = [ "1080p" "1440p" ];
            tags = [ "dedsec" "hacker" "cyberpunk" "grub" ];
          };
        };
        
        refind = {
          themeworld-collection = {
            path = self.assets.refind + "/collections";
            package = "refind-themeworld-collection";
            description = "FoxOS REfind theme collection";
            collections = [ "foxos" "devpals" "nyan-mode" "classic-ui" ];
            tags = [ "refind" "foxos" "collection" ];
          };
        };
      };
    };
}

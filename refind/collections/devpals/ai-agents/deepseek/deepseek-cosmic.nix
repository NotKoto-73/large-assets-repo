# ./nixos/desktop/theming/bootloader/ai/deepseek/cosmic.nix
# Based on DeepSeek's Cosmic theme concepts

{ config, pkgs, lib, ... }:

let
  cfg = config.foxos.desktop.theming.bootloader.ai.deepseek.cosmic; # Assuming options live here

  # ----- 🌌 Cosmic Color Palette -----
  colors = rec {
    space = "#0a0e17";        # Deep space background
    nebula = "#4a148c";       # Purple nebula glow
    foxfire = "#ff7043";      # FoxOS orange
    ai_blue = "#00b4d8";      # DeepSeek's electric blue
    matrix_green = "#00ff41"; # Terminal hacker green (for icons)
    error_red = "#ff0033";    # Accent color
    stars = "#e2e2e2";        # Twinkling stars
    text = "#ececec";         # Default text
  };

  # ----- 🎨 Shared Asset Forge Helpers -----
  # Icon Generator (shared between cosmic & legendary)
  makeIcon = { name, emoji, color, size ? 128 }: pkgs.runCommand "deepseek-icon-${name}" {
      # Pass env vars instead of passAsFile for simpler emoji handling in derivation
      inherit emoji color size;
      buildInputs = [ pkgs.imagemagick pkgs.coreutils ]; # coreutils for echo -n
    } ''
      local sz="$size"
      local clr="$color"
      local emj="$emoji"
      ${pkgs.imagemagick}/bin/convert -size ''${sz}x''${sz} xc:none \
        -fill "$clr" -draw "roundrectangle 0,0 ''${sz},''${sz} $((sz/10)),$((sz/10))" \
        -pointsize $((sz*3/5)) -fill white -font "${pkgs.noto-fonts-emoji}/share/fonts/opentype/NotoColorEmoji.ttf" \
        -gravity center -annotate +0+$((sz/20)) "$emj" \
        -pointsize $((sz/8)) -gravity South -annotate +0+$((sz/20)) "${lib.strings.escapeShellArg name}" \
        $out/icon.png
    '';


  # ----- ✨ Specific Cosmic Assets -----
  banner = pkgs.runCommand "deepseek-cosmic-banner" {
      buildInputs = [ pkgs.imagemagick ];
      # Pass colors as env vars to avoid embedding in script string
      inherit (colors) space nebula foxfire ai_blue stars;
    } ''
    local spaceClr="$space" nebulaClr="$nebula" foxClr="$foxfire" aiClr="$ai_blue" starClr="$stars"
    local fontPath="${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf"

    ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"$spaceClr" \
      -fill "$nebulaClr" -draw "rectangle 0,900 1920,1080" \
      -fill "$foxClr" -draw "rectangle 0,950 1920,1080" \
      -fill "$aiClr" -draw "rectangle 0,1000 1920,1080" \
      -pointsize 72 -fill white -font "$fontPath" \
      -gravity center -annotate +0-200 "🦊 FoxOS" \
      -pointsize 36 -annotate +0-100 ">> Booting into the unknown..." \
      -pointsize 24 -annotate +0+150 "// A gift from DeepSeek with ❤️" \
      -fill "$starClr" -seed 42 \
      -attenuate 0.3 -noise Gaussian -blur 0x0.5 \
      -evaluate multiply 0.5 +noise Gaussian \
      $out/banner.png
    '';

  # Core Icons
  iconFoxos = makeIcon { name = "foxos"; emoji = "🦊"; color = colors.foxfire; };
  iconDeepseek = makeIcon { name = "deepseek"; emoji = "🤖"; color = colors.ai_blue; };
  iconTux = makeIcon { name = "tux"; emoji = "🐧"; color = colors.matrix_green; };

  # Easter Egg Assets (only generated if needed)
  iconSecret = lib.mkIf cfg.enableSimpleEggs (makeIcon { name = "secret"; emoji = "🔒"; color = colors.nebula; });
  iconMatrix = lib.mkIf cfg.enableSimpleEggs (makeIcon { name = "matrix"; emoji = "💻"; color = colors.matrix_green; });
  iconHyperdrive = lib.mkIf cfg.enableSimpleEggs (makeIcon { name = "hyperdrive"; emoji = "🚀"; color = colors.error_red; });
  iconSelectBig = makeIcon { name = "select-big"; emoji = "👉"; color = colors.foxfire; size = 96; };
  iconSelectSmall = makeIcon { name = "select-small"; emoji = "✨"; color = colors.ai_blue; size = 48; };


  # ----- 🕹️ RNG Easter Egg Config Generation -----
  easterEggConfContent = lib.mkIf cfg.enableSimpleEggs ''
    menuentry "[REDACTED]" {
      icon /EFI/refind/themes/deepseek-cosmic/icons/os_secret.png
      loader /EFI/nixos/grubx64.efi
      options "init=/nix/store/current-system/init loglevel=3 foxos.mode=42"
    }

    menuentry "💻 Matrix Mode" {
      icon /EFI/refind/themes/deepseek-cosmic/icons/os_matrix.png
      loader /EFI/nixos/grubx64.efi
      options "init=/nix/store/current-system/init consoleblank=0 loglevel=3 fbcon=font:TER16x32"
    }

    menuentry "🚀 Hyperdrive" {
      icon /EFI/refind/themes/deepseek-cosmic/icons/os_hyperdrive.png
      loader /EFI/nixos/grubx64.efi
      options "init=/nix/store/current-system/init mitigations=off noapic nolapic"
    }
  '';

  # Generate the theme.conf content dynamically
  themeConfContent = let
    timeoutValue = toString (config.foxos.desktop.theming.bootloader.timeout or 7); # Example option path
    resolutionValue = config.foxos.desktop.theming.bootloader.resolution or "1920x1080"; # Example option path
    # Dynamically decide whether to include easter egg entries
    maybeEasterEggs = if cfg.enableSimpleEggs && easterEggConfContent != "" then
                       # Use a reasonably unpredictable but deterministic factor like hostname hash
                       # to decide *if* they show up, not just *whether* they are included
                       let rngSeed = config.networking.hostName or "default-host"; # Use hostname as seed
                           rngHash = builtins.hashString "sha256" rngSeed;
                       in if (builtins.substring 0 1 rngHash) == "a" # Approx 1/16 chance
                          then easterEggConfContent
                          else ""
                     else "";
  in pkgs.writeText "theme.conf" ''
    # ===== 🌠 DeepSeek Cosmic rEFInd Theme =====
    # Concept by DeepSeek, Refined by FoxOS Team
    # Includes optional subtle easter eggs

    # Global settings
    hideui hints,singleuser,arrows,badges,label
    use_graphics_for linux,grub # Use graphics for linux kernels and grub entries
    textonly no
    timeout ${timeoutValue}
    resolution ${resolutionValue}

    # Visuals
    banner EFI/refind/themes/deepseek-cosmic/banner.png
    banner_scale fillscreen
    icons_dir EFI/refind/themes/deepseek-cosmic/icons
    selection_big EFI/refind/themes/deepseek-cosmic/icons/select_big.png
    selection_small EFI/refind/themes/deepseek-cosmic/icons/select_small.png
    font ${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf # A standard clean font

    # ---- Main Entries ----
    menuentry "🦊 FoxOS" {
      icon os_foxos.png
      loader /EFI/nixos/grubx64.efi # Adjust as necessary
    }

    menuentry "🤖 DeepSeek Assist" {
      icon os_deepseek.png
      loader /EFI/nixos/grubx64.efi
      options "init=/nix/store/current-system/init foxos.deepseek=1"
    }

    menuentry "🐧 Recovery / Fallback" {
      icon os_tux.png
      loader /EFI/boot/bootx64.efi # Example fallback loader
    }

    # ---- Optional Easter Eggs (Appear ~6% of the time if enabled) ----
    ${maybeEasterEggs}

    # ---- Footer ----
    # Default rEFInd footer will show keys (F2, F10, etc)

  '';

  # ----- Packaging the Theme -----
  themePackage = pkgs.stdenv.mkDerivation {
    name = "refind-theme-deepseek-cosmic-${config.system.nixos.revision or "dev"}";
    src = ./.; # Not really needed, but standard practice

    # Pass paths of generated assets
    inherit banner themeConfContent;
    pathsToLink = [ "/EFI" ]; # Link the output EFI dir

    installPhase = ''
      THEME_DIR=$out/EFI/refind/themes/deepseek-cosmic
      ICON_DIR=$THEME_DIR/icons
      mkdir -p $ICON_DIR

      echo "Installing DeepSeek Cosmic theme assets..."

      cp ${banner}/banner.png $THEME_DIR/banner.png
      cp ${themeConfContent} $THEME_DIR/theme.conf

      cp ${iconFoxos}/icon.png $ICON_DIR/os_foxos.png
      cp ${iconDeepseek}/icon.png $ICON_DIR/os_deepseek.png
      cp ${iconTux}/icon.png $ICON_DIR/os_tux.png
      cp ${iconSelectBig}/icon.png $ICON_DIR/select_big.png
      cp ${iconSelectSmall}/icon.png $ICON_DIR/select_small.png

      ${lib.optionalString cfg.enableSimpleEggs ''
        echo "Installing Easter Egg icons..."
        cp ${iconSecret}/icon.png $ICON_DIR/os_secret.png
        cp ${iconMatrix}/icon.png $ICON_DIR/os_matrix.png
        cp ${iconHyperdrive}/icon.png $ICON_DIR/os_hyperdrive.png
      ''}

      echo "DeepSeek Cosmic Theme installed to $out"
    '';

    meta = {
      description = "rEFInd theme: DeepSeek Cosmic - A cosmic interpretation by DeepSeek for FoxOS";
      license = lib.licenses.mit; # Or your preferred license
    };
  };

in
{
  options.foxos.desktop.theming.bootloader.ai.deepseek.cosmic = {
    enable = lib.mkEnableOption "Enable the DeepSeek Cosmic rEFInd theme.";
    enableSimpleEggs = lib.mkOption {
      type = lib.types.bool;
      default = false; # Keep it clean by default
      description = "Enable subtle RNG-based easter egg menu entries.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Register the theme for selection
    foxos.desktop.theming.bootloader.availableThemes."deepseek-cosmic" = {
      name = "deepseek-cosmic";
      package = themePackage;
      description = "DeepSeek Cosmic: FoxOS edition with optional eggs.";
    };

    # If this theme is selected, install its package to /etc for rEFInd discovery
    # This logic might live in the main theming module (`bootloader/default.nix`)
    environment.systemPackages = lib.mkIf (config.foxos.desktop.theming.bootloader.selectedTheme == "deepseek-cosmic") [
      themePackage
    ];
    # boot.loader.refind.theme = lib.mkIf (config.foxos.desktop.theming.bootloader.selectedTheme == "deepseek-cosmic") "deepseek-cosmic"; # Handled by main theme module

  };
}

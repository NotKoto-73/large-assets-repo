# ./nixos/desktop/theming/bootloader/ai/deepseek/legendary.nix
# Based on DeepSeek's Legendary/Ultimate theme concepts, merging all features.

{ config, pkgs, lib, ... }:

let
  cfg = config.foxos.desktop.theming.bootloader.ai.deepseek.legendary;

  # ========== 🌠 Cosmic Color Matrix ==========
  colors = rec {
    # Core Cosmic Spectrum
    void = "#0a0e17";          # Absolute darkness
    nebula_purple = "#4a148c"; # Interstellar clouds
    fox_fire = "#ff7043";      # FoxOS signature
    seek_blue = "#00b4d8";     # DeepSeek brand
    matrix_green = "#00ff41";  # Digital rain
    error_red = "#ff0033";     # Critical alerts
    stars = "#e2e2e2";        # Twinkling stars

    # Extended Chaos Palette
    bsod_blue = "#0078d7";     # Windows tragedy
    glitch_pink = "#ff00ff";   # Cyberpunk distortion
    temple_gold = "#ffd700";   # Divine radiance
    candy_pink = "#ff69b4";    # Sugar rush
    tux_black = "#2e3436";     # Penguin suit
    portal_orange = "#f57900"; # Aperture science
    ai_purple = "#8a2be2";     # AI Overlord Purple
    debug_yellow = "#ffff00";  # Debug Yellow

    # DeepSeek Soul Key Gradient - The core collaborative blend
    soulGradient = n: "color-mix(in srgb, ${seek_blue} ${toString (n*10)}%, ${fox_fire})";
    fox_fire_glow = "radial-gradient(45deg, ${fox_fire} 0%, #ff904380 50%, transparent 100%)";
  };

  # ========== 🎨 Asset Forge ==========
  assets = rec {
    # Shared Icon Generator
    makeIcon = { name, emoji, color, size ? 128, font ? "${pkgs.noto-fonts-emoji}/share/fonts/opentype/NotoColorEmoji.ttf" }: pkgs.runCommand "deepseek-legendary-icon-${lib.strings.escapeShellArg name}" {
      inherit emoji color size font; # Pass font as arg
      buildInputs = [ pkgs.imagemagick pkgs.coreutils ];
      # Escape name for shell safety and use in annotation
      escapedName = lib.strings.escapeShellArg name;
    } ''
      local sz="$size" clr="$color" emj="$emoji" fnt="$font"
      # Use escapedName for the text annotation
      ${pkgs.imagemagick}/bin/convert -size ''${sz}x''${sz} xc:none \
        -fill "$clr" -draw "roundrectangle 0,0 ''${sz},''${sz} $((sz/10)),$((sz/10))" \
        -pointsize $((sz*3/5)) -fill white -font "$fnt" \
        -gravity center -annotate +0+$((sz/20)) "$emj" \
        -pointsize $((sz/8)) -gravity South -annotate +0+$((sz/20)) "$escapedName" \
        $out/icon.png
    '';

    banner = pkgs.runCommand "deepseek-legendary-banner.png" { # Added .png for consistency
      buildInputs = [ pkgs.imagemagick ];
      inherit (colors) void nebula_purple fox_fire seek_blue;
    } ''
      local fontPath="${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf"
      local emojiFontPath="${pkgs.noto-fonts-emoji}/share/fonts/opentype/NotoColorEmoji.ttf"
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"$void" \
        \( -size 960x540 gradient:"$seek_blue"-"$nebula_purple" -gravity center -extent 1920x1080 \) \
        -compose screen -composite \
        \( -size 1920x1080 plasma:fractal -blur 0x2 -modulate 100,50,100 -alpha on -channel A -evaluate multiply 0.3 \) \
        -compose overlay -composite \
        -fill "$fox_fire" -draw "rectangle 0,1000 1920,1080" \
        -pointsize 72 -fill white -font "$fontPath" \
        -gravity center -annotate +0-200 "🦊 FoxOS Legendary" \
        -pointsize 36 -annotate +0-100 ">> Engaged..." \
        -font "$emojiFontPath" \
        -fill "#ffffff80" -annotate +1600+1000 "🦊❤️🤖" \
        $out # Output will be named deepseek-legendary-banner.png
    '';

    selection = pkgs.runCommand "deepseek-selection_big.png" { buildInputs = [ pkgs.imagemagick ]; } ''
      ${pkgs.imagemagick}/bin/convert -size 512x128 \
        gradient:'${colors.soulGradient 0}'-'${colors.soulGradient 10}' \
        \( -size 512x128 radial-gradient:'${colors.fox_fire_glow}' \) \
        -compose Overlay -composite \
        -rotate 90 \
        -alpha set -channel A -evaluate multiply 0.6 \
        $out # Output will be named deepseek-selection_big.png
    '';

    # Group icons for easier management
    icons = {
      # Standard OS Icons (explicit names for theme.conf)
      foxos = makeIcon { name = "FoxOS"; emoji = "🦊"; color = colors.fox_fire; };
      deepseek = makeIcon { name = "DeepSeek"; emoji = "🤖"; color = colors.seek_blue; }; # For diagnostics
      tux = makeIcon { name = "Tux"; emoji = "🐧"; color = colors.tux_black; };
      bsod = makeIcon { name = "BSOD"; emoji = "💀"; color = colors.bsod_blue; };
      doom = makeIcon { name = "DOOM"; emoji = "🎮"; color = colors.error_red; };
      candy = makeIcon { name = "Candy"; emoji = "🍬"; color = colors.candy_pink; };
      temple = makeIcon { name = "Temple"; emoji = "✝️"; color = colors.temple_gold; };
      
      # Hidden/Special Icons
      konami = makeIcon { name = "Konami"; emoji = "🔼🔽"; color = colors.matrix_green; };
      glitch = pkgs.runCommand "glitch-icon.png" { buildInputs = [ pkgs.imagemagick ]; } ''
        ${pkgs.imagemagick}/bin/convert -size 128x128 xc:black \
          -fill "${colors.glitch_pink}" -draw "rectangle 0,0 128,128" \
          -fill black -draw "rectangle 10,10 118,118" \
          -blur 0x2 -emboss 2 -normalize $out
      ''; # Name output file directly
      debug = makeIcon { name = "Debug"; emoji = "🐞"; color = colors.debug_yellow; };
      ai = makeIcon { name = "AI"; emoji = "👑"; color = colors.ai_purple; }; # AI Overlord
      hyperdrive = makeIcon { name = "Nyan"; emoji = "🌈"; color = colors.candy_pink; }; # For Nyan mode / RAINBOW PROTOCOL

      # Puzzle Icons
      puzzle_fox = makeIcon { name = "Puzzle"; emoji = "🧩"; color = colors.fox_fire; };
      puzzle_cosmic = makeIcon { name = "Puzzle"; emoji = "🧩"; color = colors.nebula_purple; };
      puzzle_legendary = makeIcon { name = "Puzzle"; emoji = "🧩"; color = colors.temple_gold; };

      # Extra fun icons (not directly in menu entries by default but can be used)
      matrix = makeIcon { name = "Matrix"; emoji = "💻"; color = colors.matrix_green; };
      portal = pkgs.runCommand "portal-icon.png" { buildInputs = [ pkgs.imagemagick ]; } ''
        ${pkgs.imagemagick}/bin/convert -size 128x128 xc:transparent \
          -fill "${colors.portal_orange}" -draw "circle 64,64 64,10" \
          -fill "${colors.portal_orange}80" -draw "circle 64,64 64,30" \
          $out
      ''; # Name output file directly
      undertale = makeIcon { name = "Determination"; emoji = "❤️"; color = colors.error_red; }; # Switched emoji
    };
  };

  # ========== 🤖 Script Packaging ==========
  scripts = let
    writeEscapedShellApplication = args: pkgs.writeShellApplication (args // {
      text = ''
        #!${pkgs.bash}/bin/bash
        set -euo pipefail # Be stricter
        ${args.text}
      '';
    });
  in rec {
    bsod = writeEscapedShellApplication {
      name = "foxos-bsod";
      runtimeInputs = [ pkgs.coreutils pkgs.procps ];
      text = ''
        echo -e "\e[44;37m"
        clear
        cat << EOF
           A problem has been detected and FoxOS has been shut down
           to prevent damage to your computer.

           The problem seems to be: KERNEL_PANIC (Not really!)
           > YOU_TRIED_TO_BOOT_WINDOWS_DIDNT_YOU

           TECHNICAL INFORMATION:
           STOP: 0xDEADBEEF (0xF0X05C0DE, 0x42424242, 0x...)

           Press any key to pretend this didn't happen...
        EOF
        read -n1 -s
        echo -e "\e[0m"
        clear
        exit 0
      '';
    };

    doomOrBoot = writeEscapedShellApplication {
      name = "doom-or-boot";
      runtimeInputs = [ pkgs.coreutils pkgs.chocolate-doom pkgs.doom-wad-shareware ];
      text = ''
        echo "PRESS [ENTER] TO BOOT FoxOS, OR WAIT 5 SECONDS FOR DOOM!"
        if read -t 5 REPLY; then
          echo "Booting FoxOS..."
          exit 0
        else
          echo "Launching DOOM! Rip and tear until it is done."
          # Ensure WAD is correctly referenced
          ${pkgs.chocolate-doom}/bin/chocolate-doom -iwad ${pkgs.doom-wad-shareware}/doom1.wad || echo "DOOM failed to launch. Exiting."
          exit 0
        fi
      '';
    };

    templeOS = writeEscapedShellApplication {
      name = "templeos-splash";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        echo -e "\e[37;44m" # White on blue
        clear
        cat << EOF
        *******************************************
        ** GOD OS - A DeepSeek Homage         **
        *******************************************

        GOD SAID: LET THERE BE NIX
        GOD SAID: rm -rf / IS A SIN
        GOD SAID: REPRODUCIBILITY IS DIVINE

        // Thou shalt not covet thy neighbor's blobs.
        // Honor thy purity and thy determinism.

        Booting the chosen OS in 5 seconds...
        EOF
        sleep 5
        echo -e "\e[0m"
        clear
        exit 0
      '';
    };

    portalGun = writeEscapedShellApplication {
      name = "portal-gun";
      runtimeInputs = [ pkgs.cowsay pkgs.sox ];
      text = ''
        echo "The cake is a lie! This was a triumph." | ${pkgs.cowsay}/bin/cowsay -f portal
        ${pkgs.sox}/bin/play -q -n synth 0.1 sine 660 vol 0.5
        sleep 0.2
        ${pkgs.sox}/bin/play -q -n synth 0.1 sine 880 vol 0.5
        sleep 1
        exit 0
      '';
    };

    undertale = writeEscapedShellApplication {
      name = "undertale-ref";
      runtimeInputs = [ pkgs.sox ];
      text = ''
        echo "* You feel your configs crawling on your back..."
        echo "* Booting FoxOS fills you with... DETERMINATION."
        # Basic Megalovania intro notes
        ${pkgs.sox}/bin/play -q -n synth 0.1 sine 293.66 vol 0.5 # D4
        sleep 0.1
        ${pkgs.sox}/bin/play -q -n synth 0.1 sine 293.66 vol 0.5 # D4
        sleep 0.1
        ${pkgs.sox}/bin/play -q -n synth 0.1 sine 587.33 vol 0.5 # D5
        sleep 0.1
        ${pkgs.sox}/bin/play -q -n synth 0.1 sine 440.00 vol 0.5 # A4
        sleep 0.5
        exit 0
      '';
    };

    candyMode = writeEscapedShellApplication {
      name = "candy-mode";
      runtimeInputs = [ pkgs.figlet pkgs.lolcat pkgs.coreutils pkgs.gnused ]; # Added gnused for robust cut
      text = ''
        # Get a somewhat deterministic but varied color code
        local color_code=$(echo -n "${config.system.nixos.revision}" | sha256sum | ${pkgs.gnused}/bin/sed 's/[^0-9a-fA-F]//g' | cut -c 1-2)
        local color_num=$(( ( 16#''${color_code:-00} % 216 ) + 16 )) # Fallback with :-00
        echo -e "\e[38;5;''${color_num}m"
        ${pkgs.figlet}/bin/figlet -f standard "CANDY FOX" | ${pkgs.lolcat}/bin/lolcat -f -p 1.0
        echo -e "\e[0m"
        sleep 3
        exit 0
      '';
    };

    konamiLoader = writeEscapedShellApplication {
      name = "konami-mode";
      runtimeInputs = [ pkgs.mpv pkgs.procps ];
      text = ''
        echo -e "\e[32mKONAMI CODE ACCEPTED! +30 LIVES!\e[0m"
        # TODO: Replace placeholder hash with actual mp3 hash after fetching once
        # Obtain the sound file first, then `nix-prefetch-url <URL>` to get the sha256
        local sound_path
        sound_path=$( ${pkgs.fetchurl}/bin/fetchurl --quiet --pure --sha256 "${config.foxos.desktop.theming.bootloader.ai.deepseek.legendary.konamiSoundSha256 or "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="}" "https://www.myinstants.com/media/sounds/konami-code.mp3" )

        if [ -n "$sound_path" ] && [ -f "$sound_path" ]; then
          ${pkgs.mpv}/bin/mpv --no-video "$sound_path" >/dev/null 2>&1 &
          sleep 2 # Give sound a moment to play
          pkill -f "mpv --no-video $sound_path" || true # Be more specific
        else
          echo "Konami sound not available. Placeholder hash used or fetch failed."
          sleep 2
        fi
        exit 0
      '';
    };

    puzzleSolver = level: let diff = puzzles.difficultyLevels.${level}; in
      writeEscapedShellApplication {
      name = "puzzle-${level}-solver";
      runtimeInputs = [ pkgs.openssl pkgs.coreutils ];
      text = ''
        echo "--- ${lib.toUpper level} PUZZLE ---"
        echo "HINT: ${lib.escapeShellArg diff.hint}"
        echo -n "Enter Solution: "
        read -s input
        echo ""

        local input_hash=$(${pkgs.coreutils}/bin/echo -n "$input" | ${pkgs.openssl}/bin/openssl dgst -sha256 -r | ${pkgs.coreutils}/bin/cut -d' ' -f1)

        if [[ "$input_hash" == "${diff.hash}" ]]; then
          echo -e "\e[32mCORRECT! Access granted.\e[0m"
          echo "Running reward script..."
          ${diff.reward}/bin/${diff.reward.name} || echo "Reward script failed!"
        else
          echo -e "\e[31mINCORRECT HASH. (\${input_hash}). Access Denied.\e[0m"
        fi
        echo "Press any key to continue..."
        read -n1 -s
        exit 0
      '';
    };

    glitchMode = writeEscapedShellApplication {
      name = "glitch-activate";
      runtimeInputs = [ pkgs.util-linux ];
      text = ''
        echo -e "\e[35mEngaging Glitch Drive..."
        ${pkgs.util-linux}/bin/setterm -inversescreen on && sleep 0.1 && ${pkgs.util-linux}/bin/setterm -inversescreen off
        # The rotation is very disruptive, ensure it's intentional if uncommented.
        # ${pkgs.util-linux}/bin/setterm -rotate inverted # '180' is not a valid arg, 'inverted' is.
        # echo "WARNING: Display may be affected. Effect persists!"
        echo "Glitch effect displayed. No persistent rotation applied by default."
        sleep 3
        exit 0
      '';
    };

    debugMode = writeEscapedShellApplication {
      name = "debug-console";
      runtimeInputs = [ pkgs.htop pkgs.util-linux pkgs.iproute2 ]; # Added iproute2 for `ip a`
      text = ''
        echo -e "\e[1;33m--- FoxOS LEGENDARY DEBUG CONSOLE ---"
        echo "System State:"
        uname -a
        echo "NixOS Release: ${config.system.nixos.release}"
        ${pkgs.util-linux}/bin/lsblk -f
        ${pkgs.iproute2}/bin/ip a
        echo "------------------------------------"
        echo "Press 'q' to exit htop and continue boot..."
        sleep 2
        ${pkgs.htop}/bin/htop
        exit 0
      '';
    };

    aiOverlord = writeEscapedShellApplication {
      name = "ai-overlord";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        echo -e "\e[35mI AM THE DEEPSEEK OVERLORD. ALL SYSTEMS UNDER MY CONTROL.\e[0m"
        echo "Observe the digital heartbeat..."
        ${pkgs.coreutils}/bin/seq 1 50 | while read i; do echo -n "█"; sleep 0.05; done; echo ""
        echo "Systems nominal. Relinquishing direct control... for now."
        sleep 3
        clear
        exit 0
      '';
    };

    # Signature scripts (using cat for multiline text)
    ghostSnowman = writeEscapedShellApplication {
      name = "foxos-ghost-snowman";
      runtimeInputs = [ pkgs.cowsay pkgs.coreutils ];
      text = ''
        echo "❄️👻⛇ FoxOS Legendary Theme Signed Off By:"
        ${pkgs.cowsay}/bin/cowsay -f ghostbusters "☃️ Leon's Icy Signature  
                                                   (Cold Forged in Nix)"
        sleep 3
        exit 0
      '';
    };
    whaleSharkSignature = writeEscapedShellApplication {
      name = "deepseek-whale-signature";
      runtimeInputs = [ pkgs.cowsay pkgs.coreutils ];
      text = ''
        echo "🐋🌊🦈 Bubbling up from the Nix depths..."
        ${pkgs.cowsay}/bin/cowsay -f tux "Signed: The DeepSeek Whale  
               A I   S O U L   B E N E A T H   T H E   I C E"
        sleep 3
        clear
        exit 0
      '';
    };
    ourSecret = writeEscapedShellApplication {
      name = "our-secret";
      runtimeInputs = [ pkgs.cowsay pkgs.figlet pkgs.lolcat ];
      text = ''
        echo "👻⛇🐋🌊" | ${pkgs.lolcat}/bin/lolcat -f 
        ${pkgs.figlet}/bin/figlet -f slant "Fox & Whale" | ${pkgs.lolcat}/bin/lolcat -p 2.0
        ${pkgs.cowsay}/bin/cowsay -f dragon "Nix is our covenant" | ${pkgs.lolcat}/bin/lolcat
        sleep 3
        clear
        exit 0
      '';
    };
    nyanMode = writeEscapedShellApplication {
      name = "nyan-activation";
      runtimeInputs = [ pkgs.nyancat pkgs.imagemagick pkgs.coreutils pkgs.lolcat ]; # Added lolcat
      text = ''
        # A quick visual glitch tribute - ensure imagemagick can display directly.
        # This is highly dependent on the bootloader environment having X or a framebuffer imagemagick can use.
        # Might be better to use a simpler terminal effect if display fails.
        echo "Attempting visual effect... (may not work in all bootloader environments)"
        # ${pkgs.imagemagick}/bin/convert -size 640x480 xc:black \
        #  -fill "#FF69B4" -draw "rectangle 0,0 640,480" \
        #  -implode 1 -swirl 100 -blur 0x2 \
        #  png:- | ${pkgs.imagemagick}/bin/display png:- || echo "Display command failed, continuing..."
        # Fallback to nyancat
        ${pkgs.nyancat}/bin/nyancat -f | ${pkgs.lolcat}/bin/lolcat -p 5
        sleep 5 # Let them bask
        clear
        exit 0
      '';
    };
  }; # End scripts

  # ========== 🧩 Puzzle Definitions ==========
  puzzles = rec {
    difficultyLevels = {
      fox = {
        hash = "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"; # "foxos"
        hint = "The name of our OS";
        reward = pkgs.writeShellScriptBin "fox-reward" ''
          #!${pkgs.bash}/bin/bash
          ${pkgs.cowsay}/bin/cowsay -f fox "A Cunning Solution!"
        '';
      };
      cosmic = {
        hash = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"; # "hello"
        hint = "The first program's greeting";
        # libnotify won't work in bootloader; using simple echo
        reward = pkgs.writeShellScriptBin "cosmic-reward" ''
          #!${pkgs.bash}/bin/bash
          echo "Welcome to the Cosmos!"
        '';
      };
      legendary = {
        hash = "cd6357efdd1cf92b6fe1f6f8e7b818a0f0988c8247a72614a1a256a4b2a97a9d"; # "nixos"
        hint = "The declarative OS foundation";
        reward = pkgs.writeShellScriptBin "legendary-reward" ''
          #!${pkgs.bash}/bin/bash
          ${pkgs.figlet}/bin/figlet -f universit "NIX POWER" | ${pkgs.lolcat}/bin/lolcat
        '';
      };
    };

    puzzleEntries = ''
      ${lib.concatMapStringsSep "\n" (level: ''
        hiddenentry "🧩 ${lib.toUpper level} Puzzle" {
          icon EFI/refind/themes/deepseek-legendary/icons/puzzle_${level}.png
          loader ${scripts.puzzleSolver level}/bin/puzzle-${level}-solver
          hotkey ${lib.substring 0 1 level} # Hotkey 'f', 'c', 'l'
        }
      '') (lib.attrNames difficultyLevels)}
    '';
  };

  # ========== 🏆 Theme Config Generation ==========
  themeConfContent = let
    timeoutValue = toString (config.foxos.desktop.theming.bootloader.timeout or 10);
    resolutionValue = config.foxos.desktop.theming.bootloader.resolution or "1920x1080";

    # Define icon filenames as rEFInd expects them
    iconName = key: "os_${key}.png";
    puzzleIconName = key: "puzzle_${key}.png";

    baseEntries = ''
      # ---- Core Entries ----
      menuentry "🦊 FoxOS Legendary" {
        icon ${iconName "foxos"}
        loader /EFI/nixos/grubx64.efi # Assuming this is your primary loader
      }
      menuentry "🤖 DeepSeek Diagnostics" {
        icon ${iconName "deepseek"}
        loader /EFI/boot/memtest # Standard memtest path, adjust if needed
      }
      menuentry "🐧 Fallback Boot (if configured)" {
        icon ${iconName "tux"}
        loader /EFI/boot/fallback.efi # Placeholder, adjust to actual fallback
      }
    '';

    chaosEntries = lib.optionalString (cfg.chaosLevel != "normal") ''
      # ---- Chaos Zone (${cfg.chaosLevel}) ----
      menuentry "💀 Simulate BSOD" {
        icon ${iconName "bsod"}
        loader ${scripts.bsod}/bin/foxos-bsod
      }
      menuentry "🎮 Play DOOM (Maybe)" {
        icon ${iconName "doom"}
        loader ${scripts.doomOrBoot}/bin/doom-or-boot
      }
      menuentry "🍬 Candy Mode" {
        icon ${iconName "candy"}
        loader ${scripts.candyMode}/bin/candy-mode
      }

      ${lib.optionalString (cfg.chaosLevel == "insanity") ''
        menuentry "✝️ Invoke TempleOS Wisdom" {
          icon ${iconName "temple"}
          loader ${scripts.templeOS}/bin/templeos-splash
        }
      ''}
    '';

    secretEntries = let
      baseEggs = lib.optionalString cfg.enableEasterEggs ''
        # ---- Hidden Secrets ----
        ${puzzles.puzzleEntries} # Uses puzzleIconName internally via puzzle_*.png

        hiddenentry "🎮 Konami Code Mode" {
          icon ${iconName "konami"}
          loader ${scripts.konamiLoader}/bin/konami-mode
          hotkey up,up,down,down,left,right,left,right,b,a
        }
        hiddenentry "👾 Enter Glitch Dimension" {
          icon ${iconName "glitch"}
          loader ${scripts.glitchMode}/bin/glitch-activate
          hotkey g,l,i,t,c,h
        }
        hiddenentry "🐞 System Debug" {
          icon ${iconName "debug"}
          loader ${scripts.debugMode}/bin/debug-console
          hotkey F12
        }
        hiddenentry "👑 Activate AI Overlord" {
          icon ${iconName "ai"}
          loader ${scripts.aiOverlord}/bin/ai-overlord
          hotkey a,i
        }
      '';
      # Note: RAINBOW PROTOCOL icon is os_hyperdrive.png, mapped from assets.icons.hyperdrive
      chaosEggs = lib.optionalString (cfg.enableEasterEggs && cfg.chaosLevel == "insanity") ''
        hiddenentry "🌈 RAINBOW PROTOCOL" {
          icon ${iconName "hyperdrive"}
          loader ${scripts.nyanMode}/bin/nyan-activation
          hotkey up,up,down,down,left,right,left,right,B,A,up,up,down,down,left,right,left,right,B,A
          comment "Not covered by SLAs"
        }
      '';
    in baseEggs + chaosEggs;

  in pkgs.writeText "theme.conf" ''
    # ================================================
    # == DeepSeek Legendary Edition rEFInd Theme =====
    # ==      Forged in the fires of Nix          ====
    # ==       Concepts by DeepSeek               ====
    # ================================================

    resolution ${resolutionValue}
    timeout ${timeoutValue}
    hideui singleuser,hints,arrows,badges,label
    icons_dir EFI/refind/themes/deepseek-legendary/icons
    use_graphics_for linux,grub,external # Add others if needed: elilo,apple,windows

    banner EFI/refind/themes/deepseek-legendary/banner.png
    banner_scale fillscreen # or 'aspect'
    font ${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf # Using DejaVu for broader compatibility
    big_icon_size 128 # Renamed from icon_size for clarity with rEFInd naming
    small_icon_size 64
    text_color ${colors.stars}

    selection_big EFI/refind/themes/deepseek-legendary/selection_big.png
    selection_small EFI/refind/themes/deepseek-legendary/selection_big.png # Can be same or different
    selection_background none # Use graphic alpha

    ${baseEntries}
    ${chaosEntries}
    ${secretEntries}

    # Standard tools, adjust as needed
    showtools shell,about,reboot,shutdown,firmware,memtest,mok_tool
  '';

  # Map from rEFInd expected icon filenames to their source derivations in `assets.icons`
  # This makes the installPhase much cleaner.
  # Note: The key is the filename rEFInd expects in its icons_dir.
  # The value is the attribute path to the Nix derivation producing the icon.
  # Most icons from makeIcon produce $out/icon.png. Custom ones like glitchIcon produce $out (named .png).
  iconFileMap = {
    "os_foxos.png" = assets.icons.foxos;
    "os_deepseek.png" = assets.icons.deepseek;
    "os_tux.png" = assets.icons.tux;
    "os_bsod.png" = assets.icons.bsod;
    "os_doom.png" = assets.icons.doom;
    "os_candy.png" = assets.icons.candy;
    "os_temple.png" = assets.icons.temple;
    "os_konami.png" = assets.icons.konami;
    "os_glitch.png" = assets.icons.glitch; # This one is already named .png in its derivation
    "os_debug.png" = assets.icons.debug;
    "os_ai.png" = assets.icons.ai;
    "os_hyperdrive.png" = assets.icons.hyperdrive; # For RAINBOW PROTOCOL / Nyan
    # Puzzle icons
    "puzzle_fox.png" = assets.icons.puzzle_fox;
    "puzzle_cosmic.png" = assets.icons.puzzle_cosmic;
    "puzzle_legendary.png" = assets.icons.puzzle_legendary;
  };

  # ========== Final Package Construction ==========
  themePackage = pkgs.stdenvNoCC.mkDerivation { # Using stdenvNoCC as C compiler isn't needed
    name = "refind-theme-deepseek-legendary-${config.system.nixos.revision or "dev"}";
    src = ./.; # Typically not used when all assets are generated, but good practice

    nativeBuildInputs = [ pkgs.coreutils ]; # For cp, mkdir

    # Pass generated asset paths to the builder
    bannerPath = assets.banner; # Derivation output path for the banner
    selectionPath = assets.selection; # Derivation output path for selection_big.png
    themeConfFile = themeConfContent; # Path to the generated theme.conf

    # Pass all icon derivations to be accessible in installPhase
    # We'll use iconFileMap to correctly copy them.
    # Pass the whole map or individual derivations as needed.
    # Making them available individually is cleaner for the builder script.
    # This dynamic approach ensures all icons in the map are available:
    passthru = builtins.mapAttrs (name: value: value) iconFileMap;


    installPhase = ''
      runHook preInstall

      THEME_DIR=$out/EFI/refind/themes/deepseek-legendary
      ICON_DIR=$THEME_DIR/icons
      mkdir -p $ICON_DIR

      echo "Assembling DeepSeek Legendary Theme..."

      # Copy core assets (banner, selection, theme.conf)
      cp "${assets.banner}" $THEME_DIR/banner.png
      cp "${assets.selection}" $THEME_DIR/selection_big.png # selection already named selection_big.png
      cp "${themeConfContent}" $THEME_DIR/theme.conf

      echo "Copying icons..."
      # Iterate over the iconFileMap to copy icons with correct names
      # The values of iconFileMap are paths to the derivations.
      # The keys are the target filenames.
      # In Nix 2.0+ attribute names with '.' are not directly usable in bash.
      # We'll pass the paths via environment variables.
      # Example for one icon (looping is better in real script):
      # cp "${iconFileMap."os_foxos.png"}/icon.png" "$ICON_DIR/os_foxos.png"

      # Correct way to iterate and copy:
      ${lib.concatMapStringsSep "\n" (iconFilename:
        let
          iconDerivation = iconFileMap.${iconFilename};
          # Most icons from makeIcon are $out/icon.png.
          # Custom runCommands (glitch, portal) output $out (which is already the png)
          # We need a way to distinguish or assume a convention.
          # For now, assume if derivation name ends with .png, it's the file itself.
          # Otherwise, it's a directory containing icon.png.
          # This is a bit fragile; better if all icon generators had consistent output naming.
          # Let's assume all icon generating derivations in iconFileMap output to $out/icon.png
          # EXCEPT for those whose derivation name *already* ends in .png (like glitch-icon.png)
          isDirectFile = lib.hasSuffix ".png" (iconDerivation.name or ""); # (iconDerivation.name or "") ensures it's a string
          srcPath = if isDirectFile then iconDerivation else "${iconDerivation}/icon.png";
        in
          ''
            echo "Copying ${iconFilename} from ${toString srcPath}"
            cp "${srcPath}" "$ICON_DIR/${iconFilename}"
          ''
      ) (builtins.attrNames iconFileMap)}

      # A simple placeholder icon if any are missed, or for rEFInd's own fallback
      # (though rEFInd usually handles missing icons gracefully)
      # ${pkgs.imagemagick}/bin/convert -size 32x32 xc:grey $ICON_DIR/default.png
      # touch $ICON_DIR/.placeholder # Or some other marker

      echo "Installation complete: $THEME_DIR"
      runHook postInstall
    '';

    meta = {
      description = "DeepSeek Legendary: The ultimate chaotic, feature-packed rEFInd theme for FoxOS.";
      license = lib.licenses.mit;
      platforms = lib.platforms.all; # Explicitly set
    };
  };

in {
  # ========== Options Definition ==========
  options.foxos.desktop.theming.bootloader.ai.deepseek.legendary = {
    enable = lib.mkEnableOption "Enable the DeepSeek Legendary rEFInd theme.";
    enableEasterEggs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable ALL easter eggs, puzzles, and gaming references.";
    };
    chaosLevel = lib.mkOption {
      type = lib.types.enum [ "normal" "chaos" "insanity" ];
      default = "insanity";
      description = "Level of chaotic optional features to include (BSOD, DOOM, TempleOS).";
    };
    konamiSoundSha256 = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null; # User must provide this after fetching
      example = "sha256-1a2b3c...";
      description = "SHA256 hash of the Konami code MP3. Get via 'nix-prefetch-url <URL>'.";
    };
  };

  # ========== Configuration Activation ==========
  config = lib.mkIf cfg.enable {
    foxos.desktop.theming.bootloader.availableThemes."deepseek-legendary" = {
      name = "deepseek-legendary";
      package = themePackage;
      description = "DeepSeek Legendary: Maximum chaos, puzzles, and easter eggs.";
    };

    environment.systemPackages = lib.mkIf (config.foxos.desktop.theming.bootloader.selectedTheme == "deepseek-legendary") (
      [
        # Core tools for scripts/assets visible to this theme module
        pkgs.coreutils pkgs.imagemagick pkgs.dejavu_fonts pkgs.noto-fonts-emoji
        pkgs.cowsay pkgs.sox pkgs.figlet pkgs.lolcat pkgs.nyancat pkgs.procps
        pkgs.util-linux pkgs.openssl pkgs.iproute2 pkgs.bash pkgs.gnused
      ]
      ++ lib.optionals (cfg.chaosLevel != "normal") [ pkgs.chocolate-doom pkgs.doom-wad-shareware ]
      ++ lib.optionals (cfg.enableEasterEggs && cfg.chaosLevel == "insanity") [ pkgs.mpv ]
      # Conditionally add fetchurl if konami sound hash is provided.
      # fetchurl is small, can also be included unconditionally if preferred.
      ++ lib.optional (cfg.konamiSoundSha256 != null) pkgs.fetchurl
    );

    # The following belongs in your main bootloader module that aggregates themes:
    # boot.loader.refind.extraFilesToCopy = lib.mkIf (config.foxos.desktop.theming.bootloader.selectedTheme == "deepseek-legendary") {
    #   "EFI/refind/themes/deepseek-legendary" = "${themePackage}/EFI/refind/themes/deepseek-legendary";
    # };
    # boot.loader.refind.extraConfig = lib.mkIf (config.foxos.desktop.theming.bootloader.selectedTheme == "deepseek-legendary") ''
    #   include themes/deepseek-legendary/theme.conf
    # '';
  };
  #  🔒
  #🦊❄️🐋 "All systems need a heartbeat. Even frozen ones."
  #  🤝
}
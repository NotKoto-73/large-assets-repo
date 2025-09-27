# ./nixos/desktop/theming/bootloader/template/theme_template.nix
#
# FoxOS rEFInd Theme Module Template
# ------------------------------------
# INSTRUCTIONS:
# 1. Copy this file to a new directory: .../bootloader/themes/mytheme/default.nix (or mytheme.nix)
# 2. Replace `<ThemeName>` with your theme's PascalCase name (e.g., `CyberFox`).
# 3. Replace `<themename>` with your theme's unique kebab-case (e.g., `cyber-fox`). This is crucial for option paths and file paths.
# 4. Update `optionPathPrefix` to reflect your theme's location in the NixOS option tree.
# 5. Define `colors` and implement actual asset generation for `banner`, `selection_graphics`, and `icons`.
# 6. Customize `themeConfContent` using rEFInd's theme.conf syntax.
# 7. Ensure `iconFileMap` correctly maps rEFInd icon names to your Nix asset derivations.
# 8. Update `meta` information.
# 9. Register your theme in your main bootloader theme aggregation module.

{ config, pkgs, lib, ... }:

let
  # !! IMPORTANT: UPDATE this path prefix for your theme's options !!
  # It should be unique for your theme.
  optionPathPrefix = "foxos.desktop.theming.bootloader.custom"; # Standard prefix for custom themes
  themeIdentifier = "<themename>"; # E.g., "my-cool-theme"
  fullOptionPath = "${optionPathPrefix}.${themeIdentifier}";

  cfg = lib.getAttrFromPath (lib.splitString "." fullOptionPath) config;

  # ----- 🎨 Theme Color Palette ----- #
  # TODO: Define your theme's color palette
  colors = {
    background = "#222222";
    text = "#eeeeee";
    primary = "#007bff"; # A vibrant blue
    accent = "#ffc107";  # A warm yellow
    selection_bg_color = "rgba(0, 123, 255, 0.3)"; # Semi-transparent primary
    error = "#dc3545";   # Red for errors or critical actions
  };

  # ----- 🖼️ Asset Generation ----- #

  # Helper to create very basic placeholder images (replace with real generation)
  makePlaceholderImage = { name, text ? name, width ? 512, height ? 128, bgColor ? colors.background, fgColor ? colors.text }:
    pkgs.runCommand "${themeIdentifier}-placeholder-${name}.png" {
      nativeBuildInputs = [ pkgs.imagemagick ];
    } ''
      ${pkgs.imagemagick}/bin/convert -size ${toString width}x${toString height} \
        xc:"${bgColor}" -fill "${fgColor}" -gravity center \
        -pointsize $((height / 5)) -annotate +0+0 "${lib.escapeShellArg text}" \
        $out # Output will be the derivation name, e.g., <themename>-placeholder-banner.png
    '';

  # Basic Icon Generator (customize or replace entirely)
  makeThemeIcon = { name, emojiOrChar, bgColor ? colors.primary, fgColor ? colors.text, size ? 128 }:
    pkgs.runCommand "${themeIdentifier}-icon-${name}.png" {
      nativeBuildInputs = [ pkgs.imagemagick ];
      font = "${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans-Bold.ttf"; # Choose a font
    } ''
      ${pkgs.imagemagick}/bin/convert -size ${toString size}x${toString size} xc:none \
        -fill "${bgColor}" -draw "roundrectangle 0,0 ${toString size},${toString size} $((size/8)),$((size/8))" \
        -fill "${fgColor}" -pointsize $((size*3/5)) -font "${font}" \
        -gravity center -annotate +0+0 "${lib.escapeShellArg emojiOrChar}" \
        $out # Output will be <themename>-icon-os_linux.png etc.
    '';

  assets = {
    banner = makePlaceholderImage { name = "banner"; text = "<ThemeName> Banner"; width = 1920; height = 200; };
    selection_big = makePlaceholderImage { name = "selection_big"; text = "Selection"; bgColor = colors.selection_bg_color; height = 160; }; # Wider for text
    selection_small = makePlaceholderImage { name = "selection_small"; text = "Sel"; bgColor = colors.selection_bg_color; height = 64; width = 64; };

    # Define your icons here
    # The keys in `icons` should match what you use in `iconFileMap` below.
    icons = {
      os_foxos = makeThemeIcon { name = "os_foxos"; emojiOrChar = "🦊"; bgColor = colors.primary; };
      os_nixos = makeThemeIcon { name = "os_nixos"; emojiOrChar = "❄️"; bgColor = colors.accent; };
      # Add more icons as needed: os_windows, tool_shell, etc.
      tool_reboot = makeThemeIcon { name = "tool_reboot"; emojiOrChar = "🔄"; bgColor = colors.text; fgColor = colors.background; };
      tool_shutdown = makeThemeIcon { name = "tool_shutdown"; emojiOrChar = "🅾️"; bgColor = colors.error; };
    };
  };

  # This map defines how your generated icons are named in the theme's 'icons' directory.
  # Keys are the final filenames rEFInd expects (e.g., "os_linux.png").
  # Values are the Nix derivations that produce these icons (e.g., assets.icons.os_linux).
  iconFileMap = {
    "os_foxos.png" = assets.icons.os_foxos;
    "os_nixos.png" = assets.icons.os_nixos;
    # "os_windows.png" = assets.icons.os_windows; # Example
    "tool_reboot.png" = assets.icons.tool_reboot;
    "tool_shutdown.png" = assets.icons.tool_shutdown;
    # TODO: Add all icons your theme uses and generates to this map.
  };


  # ----- 📜 Theme Configuration File Content (theme.conf) ----- #
  themeConfContent = let
    timeoutValue = toString (config.foxos.desktop.theming.bootloader.timeout or 5);
    # Use a specific resolution or make it configurable via `cfg.resolution`
    resolutionValue = cfg.resolution or (config.foxos.desktop.theming.bootloader.resolution or "1024x768");
  in pkgs.writeText "${themeIdentifier}-theme.conf" ''
    # rEFInd Theme: <ThemeName> - Generated for FoxOS (<themename>)
    # File and icon paths are relative to this theme's directory on the ESP:
    # EFI/refind/themes/<themename>/

    # Basic Settings
    resolution ${resolutionValue}
    timeout ${timeoutValue}
    use_graphics_for linux,grub,elilo,windows,apple # OS types to use graphical icons for
    hideui singleuser,hints,arrows,badges,label     # UI elements to hide

    # Banner/Background
    banner banner.png # Path relative to this theme's directory
    banner_scale fillscreen # or 'aspect'

    # Icons & Font
    icons_dir icons    # Subdirectory for icons, relative to this theme dir
    big_icon_size 128  # For main entries
    small_icon_size 48 # For tools or smaller entries
    font ${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf # TODO: Choose your font

    # Text Colors
    text_color ${colors.text}
    # menu_color ${colors.primary} # Color for menu item text when not selected
    # menu_active_color ${colors.accent} # Color for selected menu item text (if not using selection graphic)

    # Selection Highlight Graphics
    selection_big selection_big.png
    selection_small selection_small.png
    selection_background none # Recommended: Use transparency in your selection graphics

    # Optional: Banner Logo (place logo.png in your assets)
    # banner_logo icons/logo.png # Example path
    # banner_logo_pos 5% 5%      # Position from top-left (X% Y%) or use keywords

    # ---- Default Menu Entries ----
    # It's generally better to define most boot entries in the main rEFInd config.
    # Only include entries here if they are extremely specific to this theme's visual style
    # or if this theme provides special loader scripts.

    menuentry "🦊 FoxOS (<ThemeName>)" {
        icon icons/os_foxos.png # Path relative to ESP root OR relative to theme dir if icons_dir is used
        loader /EFI/nixos/grubx64.efi # TODO: Adjust loader path as needed
        # ostype "Linux" # Helps rEFInd pick graphics if use_graphics_for is general
    }

    menuentry "❄️ NixOS Generations" {
        icon icons/os_nixos.png
        disabled # Example: Keep defined but disabled by default
        # loader \EFI\systemd\systemd-bootx64.efi # If you use systemd-boot for generations
    }

    # TODO: Add any other theme-specific settings or entries below.
    # For example, `showtools` to control which tools appear at the bottom.
    showtools reboot,shutdown,shell,about # Add firmware, memtest, mok_tool as desired
  '';

  # ----- 📦 Theme Package Derivation ----- #
  themePackage = pkgs.stdenvNoCC.mkDerivation {
    name = "refind-theme-${themeIdentifier}";
    version = "0.1.0"; # TODO: Set your theme version
    src = ./.; # Not strictly used if all assets are generated, but conventional

    nativeBuildInputs = [ pkgs.coreutils ]; # For cp, mkdir in installPhase

    # Pass generated asset paths to the installPhase
    # These are the output paths of the Nix derivations defined above.
    bannerFile = assets.banner;
    selectionBigFile = assets.selection_big;
    selectionSmallFile = assets.selection_small;
    generatedThemeConf = themeConfContent;

    # Make icon derivations accessible (not strictly needed if using iconFileMap and string interpolation for paths)
    # iconDerivations = assets.icons;

    installPhase = ''
      runHook preInstall

      # Path on the ESP will be: EFI/refind/themes/<themename>
      local theme_esp_name="${themeIdentifier}"
      DEST_DIR=$out/EFI/refind/themes/$theme_esp_name
      ICON_DEST_DIR=$DEST_DIR/icons
      mkdir -p $ICON_DEST_DIR

      echo "Installing <ThemeName> theme assets to $DEST_DIR..."

      # Copy main assets
      cp "${bannerFile}" $DEST_DIR/banner.png
      cp "${selectionBigFile}" $DEST_DIR/selection_big.png
      cp "${selectionSmallFile}" $DEST_DIR/selection_small.png
      # cp "${assets.logo}" $ICON_DEST_DIR/logo.png # If you have a logo

      # Copy the generated theme.conf
      cp "${generatedThemeConf}" $DEST_DIR/theme.conf

      # Copy all icons defined in iconFileMap
      echo "Copying icons to $ICON_DEST_DIR..."
      ${lib.concatMapStringsSep "\n" (finalIconName:
        let iconDerivation = iconFileMap.${finalIconName};
        in ''
          echo "  Copying ${finalIconName} from ${iconDerivation}..."
          cp "${iconDerivation}" "$ICON_DEST_DIR/${finalIconName}"
        '') (builtins.attrNames iconFileMap)
      }

      echo "<ThemeName> Theme installed to $out"
      runHook postInstall
    '';

    meta = {
      description = "rEFInd Theme: <ThemeName> for FoxOS. (Template: ${themeIdentifier})";
      longDescription = ''
        A custom rEFInd bootloader theme.
        TODO: Write a proper description for <ThemeName>.
      '';
      license = lib.licenses.mit; # TODO: Choose your license
      platforms = lib.platforms.all;
      maintainers = [ lib.maintainers.yourGithubHandle ]; # TODO: Add your handle
    };
  };

in
{
  # ----- Options Definition ----- #
  options.${fullOptionPath} = {
    enable = lib.mkEnableOption "Enable the <ThemeName> (<themename>) rEFInd theme.";

    resolution = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null; # Uses global default if null
      example = "1920x1080";
      description = "Screen resolution for this theme. Overrides global if set.";
    };

    # TODO: Add any other theme-specific options here. For example:
    # showLogo = lib.mkOption {
    #   type = lib.types.bool;
    #   default = false;
    #   description = "Whether to display the theme's logo on the banner.";
    # };
  };

  # ----- Configuration Activation ----- #
  config = lib.mkIf cfg.enable {
    # Register this theme so it can be selected in your main bootloader configuration
    foxos.desktop.theming.bootloader.availableThemes.${themeIdentifier} = {
      name = themeIdentifier; # This is the name used in rEFInd's `include themes/<themename>/theme.conf`
      package = themePackage; # The Nix package that builds and installs the theme files
      description = meta.description or "<ThemeName>: A custom theme for FoxOS.";
    };

    # == IMPORTANT: Centralized Configuration ==
    # The following logic (systemPackages, extraFilesToCopy, extraConfig)
    # should ideally live in your *main* bootloader module that handles theme selection.
    # This avoids conflicts if multiple themes try to set these.
    # They are commented out here for reference.

    # environment.systemPackages = lib.mkIf (config.foxos.desktop.theming.bootloader.selectedTheme == themeIdentifier) [
    #   # Add any *runtime* dependencies needed by the theme *if they aren't already system-wide*
    #   # For most themes, only the themePackage itself is needed here if fonts are handled globally.
    #   # pkgs.dejavu_fonts # If your theme relies on a specific font not pulled in by themePackage
    # ];

    # In your main rEFInd module (e.g., /nixos/config/bootloader.nix):
    # boot.loader.refind = {
    #   enable = true;
    #   extraFilesToCopy = let
    #     selectedThemeName = config.foxos.desktop.theming.bootloader.selectedTheme;
    #     selectedThemeDef = config.foxos.desktop.theming.bootloader.availableThemes.${selectedThemeName} or null;
    #   in lib.mkIf (selectedThemeDef != null && selectedThemeName == themeIdentifier) {
    #     "EFI/refind/themes/${themeIdentifier}" = "${selectedThemeDef.package}/EFI/refind/themes/${themeIdentifier}";
    #   };
    #   extraConfig = let
    #     selectedThemeName = config.foxos.desktop.theming.bootloader.selectedTheme;
    #   in lib.mkIf (selectedThemeName == themeIdentifier) ''
    #     include themes/${themeIdentifier}/theme.conf
    #   '';
    # };
  };
}
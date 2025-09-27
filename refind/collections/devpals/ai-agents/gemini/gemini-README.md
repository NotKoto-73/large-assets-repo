      
#  Usage

To enable and select the Gemini theme within your FoxOS configuration:

```nix
# Example: Within your host or profile configuration
{ config, lib, ... }:
{
  foxos.desktop.theming.bootloader = {
    # 1. Select "gemini" as the active theme
    selectedTheme = "gemini";

    # 2. Ensure the Gemini theme module itself is enabled
    ai.deepseek.gemini = { # Assuming structure places Gemini under ai/deepseek - adjust path as needed!
      enable = true;
    };

    # Optional: Set global theme settings used by gemini.nix (if it references them)
    # timeout = 7;
    # resolution = "1920x1080"; # or "max"
  };

  # Ensure dependencies are available
  # (Usually handled automatically by the enabling module)
  environment.systemPackages = with pkgs; lib.optionals config.foxos.desktop.theming.bootloader.ai.deepseek.gemini.enable [
    imagemagick
    ubuntu_font_family # Font used in theme.conf
  ];
}

    

IGNORE_WHEN_COPYING_START
Use code with caution. Markdown
IGNORE_WHEN_COPYING_END

The main theming module (nixos/desktop/theming/bootloader/...-final.nix) should handle linking the generated theme package to the appropriate ESP location for rEFInd to find it.
🎨 Customization

For deeper customization (e.g., changing the core color palette, fonts, or generated icon symbols), directly modify the let bindings within the gemini.nix file. Rebuilding your NixOS configuration will regenerate the theme with your changes.

Enjoy booting with the dualistic energy of Gemini! If you encounter any rendering anomalies or have ideas for enhancement, the communication channels are open. 😉

      
This README provides a clear guide to what the Gemini theme is, how it's built differently, and how to use it within the established FoxOS structure.

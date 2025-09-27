# ✨ DeepSeek Cosmic Theme Guide ✨

This document details the features of the refined `deepseek-cosmic` rEFInd theme.

## Features

*   **Aesthetic:** Signature DeepSeek blues and purples blended into a calming cosmic nebula background.
*   **Procedural Assets:** Banner, selection highlights, and core OS icons generated purely with Nix and ImageMagick.
*   **Clean Layout:** Standard rEFInd menu entries for FoxOS, DeepSeek Diagnostics/Assist mode, and a Recovery/Fallback option. Minimal UI clutter.
*   **Core Icons:** Includes themed icons for FoxOS (🦊), DeepSeek (🤖), and Tux (🐧).

## Optional Simple Easter Eggs

If `enableSimpleEggs = true;` is set, the following *may* appear (based on a deterministic hash of your system hostname, approx. 6% chance per boot):

*   **[REDACTED]:** (`os_secret.png` 🔒) - A mysterious entry pointing to `foxos.mode=42`. What does it do? Only the void knows.
*   **Matrix Mode:** (`os_matrix.png` 💻) - Boots with kernel parameters for a classic green-on-black console font (`fbcon=font:TER16x32`).
*   **Hyperdrive:** (`os_hyperdrive.png` 🚀) - Boots with potentially faster (but less stable) kernel parameters (`mitigations=off noapic nolapic`). Use at your own risk!

## Configuration

Enable and configure via your NixOS configuration:

```nix
{ config, lib, ... }:
{
  foxos.desktop.theming.bootloader = {
    selectedTheme = "deepseek-cosmic"; # Make this the active theme

    ai.deepseek.cosmic = {
      enable = true;            # REQUIRED to make the theme available
      enableSimpleEggs = false; # Optional: Set to true to allow RNG eggs
    };
  };

  # Ensure required packages for the base theme are available
  # (Note: dependencies are typically handled by the enabling module)
  # environment.systemPackages = with pkgs; [ imagemagick dejavu_fonts noto-fonts-emoji ];
}
## 🌌 Lore Integration  
- `git push --force` = "Rewriting timelines (risking Chronophagic Daemons)"  
- `nix build` = "Forging binaries in the Frozen Vault"  
Enjoy a smooth, aesthetically pleasing boot into the FoxOS cosmos.

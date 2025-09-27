# Claude rEFInd Theme

A sleek, purple-gradient theme for the rEFInd boot manager inspired by Claude's visual aesthetic.

![Claude Theme Preview](preview.png)

## Overview

The Claude rEFInd theme brings a sophisticated, modern look to your boot experience with:

- Elegant purple gradient background
- Clean, minimalist selection icons
- Custom OS and tool icons with a cohesive Claude-inspired design
- Source Sans Pro font for excellent readability
- Subtle animations for a polished user experience

## Installation

### Using NixOS

1. Add the theme to your NixOS configuration:

```nix
# configuration.nix or boot-configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    # Path to where you stored claudeTheme.nix
    ./path/to/nixos/init/personalization/themes/ai/claude.nix
  ];
  
  # Enable rEFInd with Claude theme
  boot.loader.refind = {
    enable = true;
    theme = "claudeTheme";
  };
}
```

2. Rebuild your NixOS configuration:

```bash
sudo nixos-rebuild switch
```

### Manual Installation

1. Create a theme directory in your rEFInd themes folder:

```bash
sudo mkdir -p /boot/efi/EFI/refind/themes/claude
```

2. Copy all theme files to the directory:

```bash
sudo cp -r background.png icons/ fonts/ theme.conf /boot/efi/EFI/refind/themes/claude/
```

3. Edit your rEFInd configuration (`refind.conf`):

```bash
sudo nano /boot/efi/EFI/refind/refind.conf
```

4. Add or modify the following line:

```
include themes/claude/theme.conf
```

## Customization

The theme is designed to be easily customizable:

### Colors

The Claude theme uses a carefully selected color palette:
- Background: Deep purple (`17,12,22`)
- Accent: Rich purple (`87,27,114`)
- Highlight: Violet (`130,71,172`)
- Text: Light lavender (`237,220,255`)

You can modify these colors in the `theme.conf` file to match your preferences while maintaining the Claude aesthetic.

### Icons

The theme includes custom icons for:
- OS selections (Linux, Windows, macOS)
- Tools (shell, rescue)
- Selection indicators

To replace any icon, simply provide your own PNG file with the same name in the `icons/` directory.

## Theme Structure

```
claudeTheme/
├── background.png             # Purple gradient background
├── fonts/
│   └── source_sans_pro.ttf    # Primary font
├── icons/
│   ├── os_linux.png           # Linux OS icon
│   ├── os_windows.png         # Windows OS icon  
│   ├── os_mac.png             # macOS icon
│   ├── selection_big.png      # Large selection indicator
│   ├── selection_small.png    # Small selection indicator
│   ├── tool_shell.png         # Shell tool icon
│   └── tool_rescue.png        # Rescue mode icon
└── theme.conf                 # Theme configuration
```

## Configuration Options

The `theme.conf` file includes the following key settings:

```
# Background and layout
banner background.png
banner_scale fillscreen

# UI elements
selection_big icons/selection_big.png
selection_small icons/selection_small.png

# Text appearance
font fonts/source_sans_pro.ttf

# Claude color scheme
menu_background_color 17,12,22
menu_foreground_color 255,255,255
selection_background_color 87,27,114
selection_foreground_color 237,220,255

# Animation settings
animate_icons 1
anim_duration 300
```

## Troubleshooting

**Theme not loading:**
- Ensure your theme path in `refind.conf` is correct
- Check that all theme files have appropriate permissions

**Icons missing:**
- Verify that all icon files exist in the icons directory
- Make sure the icon paths in `theme.conf` match your actual file structure

**Font issues:**
- Confirm the font file is present in the fonts directory
- Try a different font if text appears unreadable

## Credits

- Theme design inspired by Claude's visual identity
- Source Sans Pro font by Adobe (SIL Open Font License)
- Background gradient inspired by Claude's color scheme
- Icons designed to complement the Claude aesthetic

## License

This theme is released under the MIT License.

---

Enjoy your sleek Claude-inspired boot experience!

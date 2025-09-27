{ pkgs, lib, ... }:

let
  # Asset fetchers
  backgroundImage = pkgs.fetchurl {
    url = "https://example.com/path/to/chatgpt-theme-background.png";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # <-- TODO: fix hash
  };

  iconSet = pkgs.fetchurl {
    url = "https://example.com/path/to/chatgpt-theme-icons.zip";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # <-- TODO: fix hash
  };

  fontFile = pkgs.fetchurl {
    url = "https://example.com/path/to/chatgpt-theme-font.ttf";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # <-- TODO: fix hash
  };

in {
  # Main installation logic
  refind-theme = pkgs.stdenv.mkDerivation {
    pname = "refind-theme-ai-chatgpt";
    version = "1.0.0";

    src = null; # Not using a local src, manual installPhase instead.

    nativeBuildInputs = [ pkgs.unzip ];

    installPhase = ''
      mkdir -p $out
      mkdir -p $out/icons
      mkdir -p $out/backgrounds
      mkdir -p $out/fonts

      # Install background image
      cp ${backgroundImage} $out/backgrounds/chatgpt-background.png

      # Install icons
      unzip ${iconSet} -d $out/icons/

      # Install font
      cp ${fontFile} $out/fonts/chatgpt-font.ttf

      # Write silly easter egg footer
      cat > $out/README.md << EOF
# 🦊🍬 AI Refind Theme

A lovingly ridiculous GPT-themed bootloader experience.

**Easter Eggs:**  
- Hidden fox in the icon pile.
- Candy mode activated! (emotionally, if not literally.)

Enjoy responsibly: Fox💩head🧡
EOF
    '';

    meta = with lib; {
      description = "FoxOS AI-inspired GPT Bootloader Theme";
      homepage = "https://your-foxos-project-link.example.com";
      license = licenses.mit;
      maintainers = with maintainers; [ your-name-here ];
      platforms = platforms.all;
    };
  };
}


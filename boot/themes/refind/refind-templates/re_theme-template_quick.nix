{ pkgs, lib, ... }:

let
  backgroundImage = pkgs.fetchurl { ... };
  iconSet         = pkgs.fetchurl { ... };
  fontFile        = pkgs.fetchurl { ... };
in {
  refind-theme = pkgs.stdenv.mkDerivation {
    pname = "...";
    version = "1.0.0";
    src = null;
    nativeBuildInputs = [ pkgs.unzip ];

    installPhase = ''
      mkdir -p $out/{icons,backgrounds,fonts}
      cp ${backgroundImage} $out/backgrounds/...
      unzip ${iconSet} -d $out/icons/
      cp ${fontFile} $out/fonts/...
      echo "You found the hidden fox." > $out/README.md
    '';

    meta = { ... };
  };
}


{ lib, pkgs }:

with lib;

{
  # Smart asset resolution function
  resolveAssets = { loader, theme, variant ? "default", themeInputs, config }:
    let
      localPath = config.foxos.themeland.localAssetsPath + "/${loader}/${theme}";
      largeAssetsPath = if config.foxos.themeland.largeAssetsFlake != null
        then "${config.foxos.themeland.largeAssetsFlake}/${loader}/themes/${theme}"
        else null;
      upstreamPath = getUpstreamPath loader theme themeInputs;
    in
      # Priority: local -> large-assets -> upstream
      if config.foxos.themeland.devMode && pathExists localPath then localPath
      else if largeAssetsPath != null && pathExists largeAssetsPath then largeAssetsPath
      else if upstreamPath != null then upstreamPath
      else throw "Theme assets not found: ${loader}/${theme}";
  
  # Get upstream repository path for standard themes
  getUpstreamPath = loader: theme: themeInputs:
    if loader == "grub" && hasPrefix "dedsec" theme then
      themeInputs.dedsec-grub or null
    else if loader == "grub" && hasPrefix "catppuccin" theme then
      themeInputs.catppuccin-grub + "/src/${theme}" or null
    else if loader == "plymouth" && elem theme ["dragon" "matrix" "nyan"] then
      themeInputs.plymouth-themes + "/pack_4/${theme}" or null
    else if loader == "systemd" then
      themeInputs.nixos-boot or null
    else null;
  
  # Create theme package from assets
  createThemePackage = { name, version ? "1.0.0", src, loader, buildInputs ? [], installPhase }:
    pkgs.stdenv.mkDerivation {
      pname = "${loader}-theme-${name}";
      inherit version src buildInputs installPhase;
      
      meta = with lib; {
        description = "${name} theme for ${loader}";
        platforms = platforms.linux;
        license = licenses.mit;
      };
    };
  
  # Validate theme structure
  validateTheme = themePath: loader:
    let
      requiredFiles = {
        grub = ["theme.txt"];
        refind = ["theme.conf"];
        systemd = ["loader.conf"];
        plymouth = ["*.plymouth"];
      };
      required = requiredFiles.${loader} or [];
    in
      all (file: pathExists (themePath + "/${file}")) required;
}

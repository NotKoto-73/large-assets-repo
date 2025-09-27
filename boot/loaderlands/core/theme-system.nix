# boot/loaderlands/core/theme-system.nix
# Core theme system that works with unified flake
{ themeInputs ? {} }:
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.foxos.themeland;
  helpers = import ../../common/functions/asset-helpers.nix { inherit lib pkgs; };
  
  # Enhanced asset resolution with unified flake support
  resolveThemeAssets = loader: theme: variant:
    let
      # Local development path
      localPath = cfg.localAssetsPath + "/${loader}/${theme}";
      
      # Integrated themeworld assets (from unified flake)
      themeworldPath = if themeInputs ? themeworld-assets then
        "${themeInputs.themeworld-assets}/boot/themes/${loader}/themes/${theme}"
      else null;
      
      # Upstream fallback path
      upstreamPath = getUpstreamAssets loader theme;
      
    in
      # Priority: local dev -> themeworld assets -> upstream -> error
      if cfg.devMode && pathExists localPath then localPath
      else if themeworldPath != null && pathExists themeworldPath then themeworldPath
      else if upstreamPath != null then upstreamPath
      else throw "Theme assets not found: ${loader}/${theme} (checked: local, themeworld, upstream)";
      
  # Get upstream assets based on theme patterns
  getUpstreamAssets = loader: theme:
    if loader == "grub" && hasPrefix "dedsec" theme then
      themeInputs.dedsec-grub or null
    else if loader == "grub" && hasPrefix "catppuccin" theme then
      (themeInputs.catppuccin-grub or null) + "/src/${theme}"
    else if loader == "plymouth" && elem theme ["dragon" "matrix" "nyan"] then
      (themeInputs.plymouth-themes or null) + "/pack_4/${theme}"
    else if loader == "systemd" then
      themeInputs.nixos-boot or null
    else null;

in {
  options.foxos.themeland = {
    enable = mkEnableOption "FoxOS Themeland System";
    
    # Asset resolution configuration
    devMode = mkOption {
      type = types.bool;
      default = false;
      description = "Enable development mode (prefer local assets)";
    };
    
    localAssetsPath = mkOption {
      type = types.path;
      default = ../../dev;
      description = "Path to local development assets";
    };
    
    # Unified flake integration
    useIntegratedAssets = mkOption {
      type = types.bool;
      default = true;
      description = "Use assets integrated in the themeworld flake";
    };
    
    # Loader configuration
    activeLoader = mkOption {
      type = types.enum [ "grub" "refind" "systemd" ];
      default = "refind";
      description = "Active bootloader";
    };
    
    # Theme configuration
    activeThemes = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        grub = "dedsec-wannacry";
        refind = "foxos-astrology";
        plymouth = "evil-nix";
      };
      description = "Active themes per loader type";
    };
    
    # Theme collections
    activeCollection = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "cyberpunk-stack";
      description = "Active theme collection";
    };
    
    # Theme variants and customization
    themeVariants = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = {
        "dedsec-wannacry" = "apocalypse";
        "foxos-astrology" = "dark-moon";
      };
      description = "Selected variants for themes";
    };
    
    # Special modes and easter eggs
    specialModes = mkOption {
      type = types.attrsOf types.bool;
      default = {};
      example = {
        "nyan-mode" = false;
        "mystical-mode" = false;
        "dedsec-mode" = false;
      };
      description = "Special modes and easter eggs";
    };
    
    # Tools configuration
    tools = {
      enableCLI = mkOption {
        type = types.bool;
        default = true;
        description = "Enable themeworld CLI tools";
      };
      
      enableDoctor = mkOption {
        type = types.bool;
        default = true;
        description = "Enable theme diagnostics";
      };
      
      enableGenerator = mkOption {
        type = types.bool;
        default = cfg.devMode;
        description = "Enable theme generator";
      };
      
      enablePlymouthCreator = mkOption {
        type = types.bool;
        default = cfg.devMode;
        description = "Enable Plymouth theme creation tools";
      };
    };
    
    # Internal state
    registry = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      readOnly = true;
      description = "Auto-generated theme registry";
    };
    
    resolveAssets = mkOption {
      type = types.functionTo (types.functionTo (types.functionTo types.path));
      default = resolveThemeAssets;
      readOnly = true;
      description = "Asset resolution function";
    };
  };
  
  config = mkIf cfg.enable {
    # System activation
    system.activationScripts.themeland-init = ''
      # Create themeland directories
      mkdir -p /etc/nixos/themeland/{registry,cache,state,logs}
      
      # Log initialization with more detail
      echo "[$(date)] Themeland initialized" >> /etc/nixos/themeland/logs/init.log
      echo "  Active loader: ${cfg.activeLoader}" >> /etc/nixos/themeland/logs/init.log
      echo "  Dev mode: ${if cfg.devMode then "enabled" else "disabled"}" >> /etc/nixos/themeland/logs/init.log
      echo "  Integrated assets: ${if cfg.useIntegratedAssets then "enabled" else "disabled"}" >> /etc/nixos/themeland/logs/init.log
      
      # Save current configuration state
      echo '${toJSON cfg.activeThemes}' > /etc/nixos/themeland/state/active-themes.json
      echo '${toJSON cfg.themeVariants}' > /etc/nixos/themeland/state/theme-variants.json
      echo '${toJSON cfg.specialModes}' > /etc/nixos/themeland/state/special-modes.json
      
      # Create asset resolution cache
      echo '${toJSON themeInputs}' > /etc/nixos/themeland/cache/theme-inputs.json
    '';
    
    # Environment variables for tools and debugging
    environment.sessionVariables = {
      FOXOS_THEMELAND_ENABLED = "true";
      FOXOS_THEMELAND_LOADER = cfg.activeLoader;
      FOXOS_THEMELAND_DEV_MODE = if cfg.devMode then "true" else "false";
      FOXOS_THEMELAND_REGISTRY = "/etc/nixos/themeland/registry";
      FOXOS_THEMELAND_INTEGRATED_ASSETS = if cfg.useIntegratedAssets then "true" else "false";
    };
    
    # Install CLI tools based on configuration
    environment.systemPackages = mkIf cfg.tools.enableCLI [
      (import ../tools/themeworld-cli.nix { inherit pkgs cfg; })
    ] ++ optional cfg.tools.enableDoctor (import ../tools/theme-doctor.nix { inherit pkgs cfg; })
      ++ optional cfg.tools.enableGenerator (import ../tools/theme-generator.nix { inherit pkgs cfg; })
      ++ optional cfg.tools.enablePlymouthCreator (pkgs.writeShellScriptBin "create-plymouth-theme" 
        (builtins.readFile ../tools/create-plymouth-dedsec.sh));
    
    # Auto-populate registry from available themes
    foxos.themeland.registry = let
      # Get theme registry from themeworld flake if available
      upstreamRegistry = themeInputs.themeworld-assets.themeRegistry or {};
      
      # Merge with local registry
      localRegistry = {
        system = {
          activeLoader = cfg.activeLoader;
          devMode = cfg.devMode;
          integratedAssets = cfg.useIntegratedAssets;
          availableInputs = builtins.attrNames themeInputs;
        };
      };
      
    in recursiveUpdate upstreamRegistry localRegistry;
    
    # Integration with boot.themes system
    boot.themes = {
      # Plymouth integration
      plymouth = mkIf (cfg.activeThemes ? plymouth) {
        enable = true;
        theme = cfg.activeThemes.plymouth;
      };
    };
    
    # Assertions for configuration validation
    assertions = [
      {
        assertion = cfg.useIntegratedAssets -> (themeInputs ? themeworld-assets);
        message = "Integrated assets enabled but themeworld-assets not available in themeInputs";
      }
      {
        assertion = cfg.activeCollection != null -> (cfg.activeThemes == {});
        message = "Cannot have both activeCollection and individual activeThemes set";
      }
    ];
    
    # Warnings for development
    warnings = optional (cfg.devMode && cfg.activeThemes != {}) 
      "Development mode enabled with active themes - local assets will override configured themes";
  };
}

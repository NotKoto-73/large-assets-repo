{ config, pkgs, ... }:

{
  imports = [
    # Import your themeland flake
    # This will be replaced with the actual flake reference
  ];
  
  # Basic themeland configuration
  foxos.themeland = {
    enable = true;
    devMode = true;  # Use local assets for testing
    
    activeLoader = "refind";
    activeThemes = {
      refind = "foxos-astrology";
    };
  };
  
  # Minimal system configuration for testing
  boot.loader.systemd-boot.enable = false;
  system.stateVersion = "24.05";
  
  # Add some basic packages for testing
  environment.systemPackages = with pkgs; [
    git
    tree
    htop
  ];
}

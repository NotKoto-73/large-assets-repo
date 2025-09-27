NixOS
1️⃣ Add dedsec-grub-theme to your flake as nixos module

{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    dedsec-grub-theme = {
      url = gitlab:VandalByte/dedsec-grub-theme;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, dedsec-grub-theme }: {
    nixosConfigurations.mysystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        dedsec-grub-theme.nixosModule
        ./path/to/your/configuration.nix
      ];
    };
  };
}

2️⃣ Enable and configure grub theme

boot = {
  # Use the GRUB 2 boot loader.
  loader.grub = {
    enable = true;
    version = 2;

    dedsec-theme = {
      enable = true;
      style = "sitedown";
      icon = "color";
      resolution = "1080p";
    };
  };
};

3️⃣ Save changes and rebuild your nixos

sudo nixos-rebuild boot --flake .#mysystem

Now the theme should be installed successfully, enjoy !!

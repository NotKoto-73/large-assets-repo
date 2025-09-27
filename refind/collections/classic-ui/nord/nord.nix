# modules/boot/themes/nord.nix
{ pkgs }:
{
  name = "nord";
  repo = pkgs.fetchFromGitHub {
    owner = "EmpressNoodle";
    repo = "refind-theme-nord";
    rev = "6749549f4845fde2f9321192246ca44309731493";
    sha256 = "13q0xdq9fjvwgcjpvfv1bx0fca9y91a6818dq93h24csdcrf6cnn";
  };
  configFile = "theme.conf";
  icons = {
    "os_nixos.png" = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/nixos/nixos-artwork/master/logo/nix-snowflake.svg";
      sha256 = "14mbpw8jv1w2c5wvfvj8clmjw0fi956bq5xf9s2q3my14far0as8";
    };
    "os_arch.png" = pkgs.fetchurl {
      url = "https://archlinux.org/static/logos/archlinux-logo-dark-90dpi.ebdee92a15b3.png";
      sha256 = "1q7fk7jv26gvmbf6wm9f0p6bpqibskrl0jyhf93pv5pqqib7lya2";
    };
    "os_garuda.png" = pkgs.fetchurl {
      url = "https://avatars.githubusercontent.com/u/73544069?s=200&v=4";
      sha256 = "0bpgsbkl3fsmzzjx95m70f0hsjqf0d9zs4xnvhvcvxgxl6xpqz9c";
    };
  };
}

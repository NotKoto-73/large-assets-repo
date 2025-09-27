# modules/boot/themes/dracula.nix
{ pkgs }:
{
  name = "dracula";
  repo = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "refind";
    rev = "v1.0";
    sha256 = "1q7fk7jv26gvmbf6wm9f0p6bpqibskrl0jyhf93pv5pqqib7lya2";
  };
  configFile = "dracula/theme.conf";
  icons = {
    "os_nixos.png" = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/nixos/nixos-artwork/master/logo/nix-snowflake.svg";
      sha256 = "14mbpw8jv1w2c5wvfvj8clmjw0fi956bq5xf9s2q3my14far0as8";
    };
  };
}

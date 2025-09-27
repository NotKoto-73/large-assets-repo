# modules/boot/themes/catppuccin.nix
{ pkgs, lib, ... }:
let
  mkVariant = name: bg: {
    name = name;
    background = bg;
    repo = "https://github.com/catppuccin/refind";
  };
  variants = {
    latte     = mkVariant "latte"     "latte.png";
    frappe    = mkVariant "frappe"    "frappe.png";
    macchiato = mkVariant "macchiato" "macchiato.png";
    mocha     = mkVariant "mocha"     "mocha.png";
  };
in
variants

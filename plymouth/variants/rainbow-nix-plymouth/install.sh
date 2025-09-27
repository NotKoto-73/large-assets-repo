#!/bin/bash
sudo cp -r . /usr/share/plymouth/themes/rainbow-nix/
sudo plymouth-set-default-theme rainbow-nix
sudo update-initramfs -u
echo "Rainbow-nix Plymouth theme installed!"

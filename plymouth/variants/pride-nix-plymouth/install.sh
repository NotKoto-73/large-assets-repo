#!/bin/bash
sudo cp -r . /usr/share/plymouth/themes/pride-nix/
sudo plymouth-set-default-theme pride-nix
sudo update-initramfs -u
echo "Pride-nix Plymouth theme installed!"

{ lib, themesPath }:

let
  # Recursively find all default.nix files in themes directory
  findThemeModules = dir:
    let
      contents = builtins.readDir dir;
      subdirs = lib.filterAttrs (name: type: type == "directory") contents;
      modules = lib.filterAttrs (name: type: type == "regular" && name == "default.nix") contents;
    in
      # If this directory has a default.nix, include it
      (lib.optional (modules ? "default.nix") (dir + "/default.nix"))
      # Recursively search subdirectories
      ++ (lib.concatLists (lib.mapAttrsToList (name: type: findThemeModules (dir + "/${name}")) subdirs));

in findThemeModules themesPath

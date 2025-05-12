let
  pkgs = import <nixpkgs> {};
in
  pkgs.callPackage ./virtual-machines.nix {}

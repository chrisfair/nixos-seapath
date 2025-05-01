{ pkgs, ... }:

{
  virtual-machines = pkgs.callPackage ./virtual-machines.nix { };
}


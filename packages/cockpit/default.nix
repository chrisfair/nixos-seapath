{ pkgs, ... }:

{
  machines = pkgs.callPackage ./machines.nix { };
}


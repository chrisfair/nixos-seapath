{ config, lib, pkgs, ... }:

let
maybeLocalUsers = if builtins.pathExists ./local-users.nix then [ ./local-users.nix ] else [];
maybeRootUser = if builtins.pathExists ./root-user.nix then [ ./root-user.nix ] else [];
in

{
  
  boot.kernelPackages = pkgs.linuxPackages-rt_latest;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./hypervisor.nix
      ./localization.nix
      ./base-users.nix
    ] ++ maybeLocalUsers ++ maybeRootUser;


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  services.openssh.enable = true;

  networking.hostName = "hypervisor"; # Define your hostname.
    networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    networking.firewall.allowedTCPPorts = [ 9090 ]; 

  security.polkit.enable = true;
  services.dbus.enable = true;

  environment.systemPackages = with pkgs; [
   vim 
   wget
   qemu
  ];

  system.stateVersion = "24.11"; # Did you read the comment?

}

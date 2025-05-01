{ config, pkgs, lib, ... }:

let
  enableCluster = builtins.pathExists /etc/seapath-enable-cluster;
in
lib.mkIf enableCluster {
  services.corosync.enable = true;
  services.pacemaker.enable = true;
  services.drbd.enable = true;

  services.cockpit.modules = [
    "cockpit-machines"
    "cockpit-packagekit"
    "cockpit-system"
    "cockpit-cluster"
  ];

  environment.systemPackages = with pkgs; [
    fence-agents
    ipmitool
    watchdog
    drbd-utils
  ];
}

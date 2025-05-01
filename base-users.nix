{ config, lib, pkgs, ... }:

{

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "admin" "wheel" "networkmanager" "libvirt" ];
# Default password is adminPassword! please change to something secure by
# using mkpasswd -m sha-512 to generate s password hash and replace this one with that one
    hashedPassword = "$6$TeyyDEuz0P7JdDqL$DKAFShaZi9lMrVTSWGWrbEWPsFNHmeTPjVPuNiUklvKDh/KGtulKeXzH4PCtVJ1z7ceQa/v1kcCe5Vl0aYoU7/";
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
          subject.isInGroup("libvirt")) ||
          subject.isInGroup("wheel") ||
          subject.user == "admin" ){
        return polkit.Result.YES;
      }
    });
  '';

  users.users.ansible = {
    isNormalUser = true;
    extraGroups = [ "admin" "wheel" "networkmanager" "libvirt" ];
# Default password is adminPassword! please change to something secure by
# using mkpasswd -m sha-512 to generate s password hash and replace this one with that one
    hashedPassword = "$6$TeyyDEuz0P7JdDqL$DKAFShaZi9lMrVTSWGWrbEWPsFNHmeTPjVPuNiUklvKDh/KGtulKeXzH4PCtVJ1z7ceQa/v1kcCe5Vl0aYoU7/";
  };

}

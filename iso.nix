{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
    ./configuration.nix
    ./seapath-cluster.nix
  ];

  isoImage.edition = "seapath";

  # Optional: auto-login as root
  services.getty.autoLogin.enable = true;
  services.getty.autoLogin.user = "root";

  # Include banner script in the live environment
  environment.etc."banner.sh".source = ./banner.sh;
}

{ config, lib, pkgs, ... }:

let 
  cockpitPackages = import ./packages/cockpit { inherit pkgs; };
in

{

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  services.cockpit = {
    enable = true;
    port = 9090;
    openFirewall = true;
  };

  security.pam.services.cockpit = {
    text = ''
      auth     include login
      account  include login
      password include login
      session  include login
    '';
  };

  services.cockpit.settings = {
    "WebService" = {
      "CertificateFile" = "/etc/cockpit/ws-certs.d/0-selfsigned.pem";
    };
  };

  environment.systemPackages = with pkgs; [
    qemu
    libvirt
    cockpit
    cockpitPackages.virtual-machines
    glib-networking
    virt-manager
    virt-viewer
    spice 
    spice-gtk
    spice-protocol
  ];

  system.activationScripts.cockpitSelfSignedCert = {
    text = ''
      echo "Generating self-signed Cockpit cert..."
      mkdir -p /etc/cockpit/ws-certs.d

      OPENSSL=${pkgs.openssl}/bin/openssl

      $OPENSSL req -new -newkey rsa:2048 -days 3650 -nodes \
      -x509 -subj "/C=US/ST=Illinois/L=Chicago/O=My Company/CN=localhost" \
      -keyout /etc/cockpit/ws-certs.d/0-self-signed.key \
      -out /etc/cockpit/ws-certs.d/0-self-signed.cert

      cat /etc/cockpit/ws-certs.d/0-self-signed.cert /etc/cockpit/ws-certs.d/0-self-signed.key \
      > /etc/cockpit/ws-certs.d/0-self-signed.pem

      chmod 600 /etc/cockpit/ws-certs.d/0-self-signed.pem

      echo "Self-signed Cockpit cert generated."
      '';
  };

}

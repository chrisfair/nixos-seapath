{ config, lib, pkgs, ... }:

let
  cockpit-machines = pkgs.nurPackages.cockpit-machines;  # Pulling from NUR
in

{
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = "qemu:///system";
  environment.etc."libvirt/libvirt.conf".text = ''
    uri_default = "qemu:///system"
    uri_default_rw = 1
    auth_unix_rw = 1
    auth_unix_ro = 0
    auth_tcp_rw = 0
    auth_tcp_ro = 0
    auth_tls_rw = 0
    auth_tls_ro = 0
    auth_kerberos_rw = 0
    auth_kerberos_ro = 0
    auth_gssapi_rw = 0
    auth_gssapi_ro = 0
    auth_sasl_rw = 0
    auth_sasl_ro = 0
  '';
  users.groups.libvirt = { };

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

  environment.sessionVariables.XDG_DATA_DIRS =
    "${cockpit-machines}/share:${pkgs.glib}/share:/usr/local/share:/usr/share";

  environment.systemPackages = with pkgs; [
    qemu
    libvirt
    cockpit
    cockpit-machines  # Directly using the NUR package here
    glib-networking
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
  ];

  systemd.services.cockpit.environment = {
    XDG_DATA_DIRS = "${cockpit-machines}/share:${pkgs.glib}/share:/usr/local/share:/usr/share";
  };

  system.activationScripts.cockpitSelfSignedCert = {
    text = ''
      echo "Generating self-signed Cockpit cert..."
      mkdir -p /etc/cockpit/ws-certs.d

      OPENSSL=${pkgs.openssl}/bin/openssl

      $OPENSSL req -new -newkey rsa:2048 -days 3650 -nodes \
      -x509 -subj "/C=US/ST=Illinois/L=Chicago/O=My Company/CN=192.168.1.161" \
      -keyout /etc/cockpit/ws-certs.d/0-self-signed.key \
      -out /etc/cockpit/ws-certs.d/0-self-signed.cert

      cat /etc/cockpit/ws-certs.d/0-self-signed.cert /etc/cockpit/ws-certs.d/0-self-signed.key \
      > /etc/cockpit/ws-certs.d/0-self-signed.pem

      chmod 600 /etc/cockpit/ws-certs.d/0-self-signed.pem

      echo "Self-signed Cockpit cert generated."
    '';
  };
}

{ config, lib, pkgs, ... }:

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


  environment.systemPackages = with pkgs; [
    qemu
    libvirt
    cockpit
    glib-networking
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
  ];

}

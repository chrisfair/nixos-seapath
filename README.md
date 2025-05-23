# Seapath-NixOS

A NixOS configuration designed to replicate the features of SEAPATH while allowing both standalone and clustered operation via Corosync, Pacemaker, and DRBD.

## Features

- Real-time Linux kernel (PREEMPT_RT)
- Cockpit web console with optional clustering module
- Libvirt + QEMU for virtualization
- Docker and containerd
- DRBD support for shared storage
- Optional high availability clustering via Pacemaker + Corosync
- SSH key authentication
- Dynamic login banner showing system version and IP address

---

## Getting Started

### 1. Install NixOS

Install NixOS on your system with a GPT/UEFI layout. 
Use the [minimal ISO installer] (https://channels.nixos.org/nixos-24.11/latest-nixos-minimal-x86_64-linux.iso) since this will be a server.


### 2. Setup Configuration

Place the following files into `/etc/nixos/`:

- `configuration.nix` – your main system definition
- `hardware-configuration.nix` – generated by the installer
- `seapath-cluster.nix` – the optional cluster overlay
- `banner.sh` – dynamic login banner script

Then make the banner script executable:

```bash
chmod +x /etc/nixos/banner.sh
```

### 3. Rebuild System

```bash
sudo nixos-rebuild switch
```

---

## Enabling Clustering

To activate Corosync, Pacemaker, DRBD, and related services:

```bash
sudo touch /etc/seapath-enable-cluster
sudo nixos-rebuild switch
```

To disable clustering:

```bash
sudo rm /etc/seapath-enable-cluster
sudo nixos-rebuild switch
```

Cluster services enabled:

- `services.corosync.enable`
- `services.pacemaker.enable`
- `services.drbd.enable`
- Cockpit modules for cluster management

---

## Dynamic SSH/Login Banner

The banner script (`banner.sh`) automatically updates `/etc/issue` at boot with:

- Hostname
- Kernel version
- OS version
- First global IPv4 address

It is triggered by a `systemd` service and used for local login + SSH banner.

---

## SSH Key Authentication

To enable SSH key access for users like `admin` or `ansible`, add their public SSH keys in `configuration.nix`:

```nix
users.users.admin.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3Nz... user@host"
];
```

After that:

```bash
sudo nixos-rebuild switch
```

---

## Configuring with Ansible

This setup is Ansible-friendly:

### Example Playbook (YAML)

```yaml
- name: Configure SEAPATH-style NixOS node
  hosts: seapath
  become: true
  tasks:
    - name: Copy configuration files
      copy:
        src: files/configuration.nix
        dest: /etc/nixos/configuration.nix

    - name: Copy cluster overlay
      copy:
        src: files/seapath-cluster.nix
        dest: /etc/nixos/seapath-cluster.nix

    - name: Copy banner script
      copy:
        src: files/banner.sh
        dest: /etc/nixos/banner.sh
        mode: '0755'

    - name: Enable clustering (optional)
      file:
        path: /etc/seapath-enable-cluster
        state: touch

    - name: Apply configuration
      command: nixos-rebuild switch
```

---

## Customizing Passwords

To change a user's password:

```bash
mkpasswd -m sha-512
```

Replace the hashed password in `configuration.nix` for that user and run:

```bash
sudo nixos-rebuild switch
```

---

## Access Cockpit

After installation:

```
https://<hostname>:9090/
```

Login with `admin` (default password: `seapath`) and change it immediately.


---

## Building a Custom Installer ISO

You can create a custom NixOS ISO that includes your configuration and boots into a live environment with everything ready to go.

### Files Required

Ensure the following files are in the same directory:

- `configuration.nix`
- `seapath-cluster.nix`
- `banner.sh`
- `iso.nix` (see below)

### Example `iso.nix`

```nix
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-base.nix>
    ./configuration.nix
    ./seapath-cluster.nix
  ];

  isoImage.edition = "seapath";

  services.getty.autoLogin.enable = true;
  services.getty.autoLogin.user = "root";

  environment.etc."banner.sh".source = ./banner.sh;
}
```

### Build the ISO

Run the following command in the same directory:

```bash
nix-build '<nixpkgs/nixos>' \
  -A config.system.build.isoImage \
  -I nixos-config=iso.nix
```

After building, your ISO will be located at:

```
./result/iso/nixos-*-seapath-x86_64-linux.iso
```

You can write it to a USB drive:

```bash
sudo dd if=./result/iso/your-iso-name.iso of=/dev/sdX bs=4M status=progress && sync
```

Then boot and run:

```bash
nixos-install
```

Your configuration will be automatically used to install a real-time, SEAPATH-style NixOS system.


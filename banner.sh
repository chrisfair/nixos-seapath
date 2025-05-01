#!/bin/sh
HOSTNAME=$(hostname)
KERNEL=$(uname -sr)
OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
IP=$(ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n 1)

cat <<EOF
$KERNEL ($OS) on $HOSTNAME
 ____  _____    _    ____   _  _____ _   _
/ ___|| ____|  / \  |  _ \ / \|_   _| | | |
\___ \|  _|   / _ \ | |_) / _ \ | | | |_| |
 ___) | |___ / ___ \|  __/ ___ \| | |  _  |
|____/|_____/_/   \_\_| /_/   \_\_| |_| |_|

Web console: https://$HOSTNAME:9090/ or https://$IP:9090/
EOF

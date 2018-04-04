#!/usr/bin/bash -x

set -eu -o pipefail

# Time

echo "==> Configuring time"

sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# SSH

echo "==> Configuring ssh"

rm /etc/ssh/*

cat <<-EOF > /etc/ssh/ssh_config
Host *
Protocol 2
ForwardAgent no
ForwardX11 no
HostbasedAuthentication no
StrictHostKeyChecking no
Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
Tunnel no

# Google Compute Engine times out connections after 10 minutes of inactivity.
# Keep alive ssh connections by sending a packet every 7 minutes.
ServerAliveInterval 420
EOF


cat <<-EOF > /etc/ssh/sshd_config
# Disable PasswordAuthentication as ssh keys are more secure.
PasswordAuthentication no

# Disable root login, using sudo provides better auditing.
PermitRootLogin no

PermitTunnel no
AllowTcpForwarding yes
X11Forwarding no

# Compute times out connections after 10 minutes of inactivity.  Keep alive
# ssh connections by sending a packet every 7 minutes.
ClientAliveInterval 420
EOF

# GRUB

echo "==> Configuring grub"

pacman -S --noconfirm grub os-prober
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=*/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,38400n8d"/g' /etc/default/grub
grub-install --recheck --debug /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

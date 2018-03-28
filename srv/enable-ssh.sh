#!/usr/bin/env bash

PASSWORD=$(/usr/bin/openssl passwd -crypt 'arch')

echo "==> Enabling SSH"
/usr/bin/useradd --password ${PASSWORD} --create-home --user-group arch
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_arch
echo 'arch ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_arch
/usr/bin/chmod 0440 /etc/sudoers.d/10_arch
/usr/bin/systemctl start sshd.service

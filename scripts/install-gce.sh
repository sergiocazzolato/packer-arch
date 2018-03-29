#!/usr/bin/bash -x

set -eu -o pipefail

GCE_SNAPSHOT=${GCE_SNAPSHOT:-}

if [ "$GCE_SNAPSHOT" == "" ]; then
    echo "GCE_SNAPSHOT url not set"
    exit 1
fi

mkdir /tmp/gce-build
cd /tmp/gce-build

/usr/bin/curl -s "${GCE_SNAPSHOT}" | tar -zxvf -
fname=$(basename "${GCE_SNAPSHOT}")
dirname="${fname%.tar*}"

cd $dirname
chown -R arch:arch .
/usr/bin/su arch -c '/usr/bin/makepkg -s -i --noconfirm'
# TODO: PKGBUILD is missing a dependency on python-distro
/usr/bin/pacman -S --noconfirm python-distro

services="google-accounts-daemon.service
        google-ip-forwarding-daemon.service
        google-clock-skew-daemon.service
        google-instance-setup.service
        google-shutdown-scripts.service
        google-startup-scripts.service
        google-network-setup.service"

echo "$services" | while read s ; do
    /usr/bin/systemctl enable $s
done

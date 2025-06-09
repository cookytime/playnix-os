#!/bin/bash
set -e

mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev
mount -t tmpfs tmp /tmp


archinstall --config /root/user_configuration.json --creds  /root/user_credentials.json


exec /usr/lib/systemd/systemd
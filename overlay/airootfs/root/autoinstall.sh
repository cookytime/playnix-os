#!/bin/bash
archinstall --config /root/user_configuration.json --creds  /root/user_credentials.json --no-block --yes

cp /root/extra-configs/*.service /mnt/etc/systemd/system/

#!/bin/bash

# Must run this with sudo

SCRIPT=$(readlink -f "$0")
BASEDIRECTORY=$(dirname "$SCRIPT")

# Read the contents of the file, replace <PATH> with the base directory and write to the new file
sed "s|<PATH>|$BASEDIRECTORY|g" ./node-runner.service > /etc/systemd/system/node-runner.service
#chmod 644 /etc/systemd/system/node-runner.service

systemctl daemon-reload
systemctl enable node-runner.service
systemctl start node-runner.service
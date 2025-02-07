#!/bin/bash

set -ex

# Install consul
bin=/usr/bin/
system=/etc/systemd/system/

mkdir -p "${bin}"
chown root:root consul
cp consul "${bin}"

# Create user
id -u consul &>/dev/null || useradd --system --home /etc/consul.d --shell /bin/false consul

cp consul.service "${system}"
systemctl enable consul.service

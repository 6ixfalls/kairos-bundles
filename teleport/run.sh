#!/bin/bash
set -ex

if [ -z "$BASH_VERSION" ]
then
    exec /bin/bash "$0" "$@"
    exit
fi

# Install teleport
bin=/usr/local/bin/
system=/etc/systemd/system/

mkdir -p "${bin}"
cp teleport tctl tsh tbot "${bin}"
cp teleport.service "${system}"
systemctl enable teleport.service

# Template files

TELEPORT_CONFIG_DIR=${TELEPORT_CONFIG_DIR:-/var/lib/teleport/}

getConfig() {
    local key=$1
    _value=$(kairos-agent config get "${key} | @json" | tr -d '\n')
    # Remove the quotes wrapping the value.
    _value=${_value:1:-1}
    if [ "${_value}" != "null" ]; then
     echo "${_value}"
    fi 
    echo   
}

VALUES="{}"

readConfig() {
    _values=$(getConfig "teleport")
    if [ "$_values" != "" ]; then
        VALUES=$_values
    fi
}

mkdir -p "${TELEPORT_CONFIG_DIR}"

readConfig

echo "${VALUES}" > "/etc/teleport.yaml"
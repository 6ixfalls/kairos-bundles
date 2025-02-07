#!/bin/bash

set -ex

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
    _value=${_value:1:${#_value}-2}
    if [ "${_value}" != "null" ]; then
     echo "$($_value)"
    fi 
    echo   
}

VALUES="{}"

templ() {
    local file="$3"
    local value=$2
    local sentinel=$1
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _values=$(getConfig teleport)
    if [ "$_values" != "" ]; then
        VALUES=$_values
    fi
}

mkdir -p "${TELEPORT_CONFIG_DIR}"

readConfig
templ "VALUES" "${VALUES}" "assets/teleport.yaml"

cp -rf assets/teleport.yaml "/etc/teleport.yaml"
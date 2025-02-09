#!/bin/bash
set -ex

if [ -z "$BASH_VERSION" ]
then
    exec /bin/bash "$0" "$@"
    exit
fi

# Install consul
bin=/usr/local/bin/
system=/etc/systemd/system/

mkdir -p "${bin}"
chown root:root consul
cp consul "${bin}"

# Create user
id -u consul &>/dev/null || useradd --system --home /etc/consul.d --shell /bin/false consul

cp consul.service "${system}"
systemctl enable consul.service

# Template files

CONSUL_CONFIG_DIR=${CONSUL_CONFIG_DIR:-/etc/consul.d/}

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

MAIN="{}"
SERVER="{}"
CLIENT="{}"

readConfig() {
    _main=$(getConfig consul)
    if [ "$_main" != "" ]; then
        MAIN=$_main
    fi
    _server=$(getConfig consul-server)
    if [ "$_server" != "" ]; then
        SERVER=$_server
    fi
    _client=$(getConfig consul-agent)
    if [ "$_client" != "" ]; then
        CLIENT=$_client
    fi
}

mkdir -p "${CONSUL_CONFIG_DIR}"
chown --recursive consul:consul /etc/consul.d

readConfig

if [ "$MAIN" != "{}" ]; then
    echo "${MAIN}" > "/etc/consul.d/consul.hcl"
    chmod 640 /etc/consul.d/consul.hcl
fi
if [ "$SERVER" != "{}" ]; then
    echo "${SERVER}" > "/etc/consul.d/server.hcl"
    chmod 640 /etc/consul.d/server.hcl
fi
if [ "$CLIENT" != "{}" ]; then
    echo "${CLIENT}" > "/etc/consul.d/agent.hcl"
    chmod 640 /etc/consul.d/agent.hcl
fi
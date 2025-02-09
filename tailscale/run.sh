#!/bin/bash
set -ex

if [ -z "$BASH_VERSION" ]
then
    exec /bin/bash "$0" "$@"
    exit
fi

# Install tailscale
bin=/usr/local/sbin/
system=/etc/systemd/system/

mkdir -p "${bin}"
cp tailscale tailscaled "${bin}"
cp tailscaled.service "${system}"
systemctl enable tailscaled.service

# Template files

templ() {
    local file="$3"
    local value=$2
    local sentinel=$1
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

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

PORT="41641"
DAEMON_FLAGS=""
UP_ARGS=""

readConfig() {
    _port=$(getConfig "tailscale.port")
    if [ "$_port" != "" ]; then
        PORT=$_port
    fi
    _flags=$(getConfig "tailscale.daemon_flags")
    if [ "$_flags" != "" ]; then
        DAEMON_FLAGS=$_flags
    fi
    _accept_dns=$(getConfig "tailscale.accept_dns")
    if [ "$_accept_dns" != "" ]; then
        UP_ARGS="${UP_ARGS} --accept-dns=${_accept_dns}"
    fi
    _auth_key=$(getConfig "tailscale.auth_key")
    if [ "$_auth_key" != "" ]; then
        UP_ARGS="${UP_ARGS} --authkey=${_auth_key}"
    fi
    _routes=$(getConfig "tailscale.routes")
    if [ "$_routes" != "" ]; then
        UP_ARGS="${UP_ARGS} --advertise-routes=${_routes}"
    fi
    _hostname=$(getConfig "tailscale.hostname")
    if [ "$_hostname" != "" ]; then
        UP_ARGS="${UP_ARGS} --hostname=${_hostname}"
    fi
    _extra_flags=$(getConfig "tailscale.extra_flags")
    if [ "$_extra_flags" != "" ]; then
        UP_ARGS="${UP_ARGS} ${_extra_flags:-}"
    fi
}

readConfig

mkdir -p /etc/default

templ "PORT" "${PORT}" "assets/tailscaled.env"
templ "DAEMON_FLAGS" "${DAEMON_FLAGS}" "assets/tailscaled.env"
cp -f "assets/tailscaled.env" "/etc/default/tailscaled"

echo "Waiting for tailscale to be Running"
while :; do
  sleep 2
  TAILSCALE_BACKEND_STATE="$(tailscale status -json | grep -o '"BackendState": "[^"]*"' | cut -d '"' -f 4)"
  if [ "${TAILSCALE_BACKEND_STATE}" == "Running" ]; then
    echo "Tailscale is up"
    break
  elif [ "${TAILSCALE_BACKEND_STATE}" == "Stopped" ] || [ "${TAILSCALE_BACKEND_STATE}" == "NoState" ]; then
    echo "Starting tailscale"
    /usr/local/sbin/tailscale up "${UP_ARGS}" || true
  fi
done

echo "Tailscale is up and configured"

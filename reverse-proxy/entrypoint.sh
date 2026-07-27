#!/bin/sh
set -eu

: "${ACME_EMAIL:?ACME_EMAIL is required}"
: "${WEBHOOK_HOST:?WEBHOOK_HOST is required}"
: "${BACKEND_URL:?BACKEND_URL is required}"

chmod 600 /acme.json

RUNTIME=/tmp/traefik-runtime
mkdir -p "${RUNTIME}/dynamic"

sed -e "s|\${ACME_EMAIL}|${ACME_EMAIL}|g" \
  /etc/traefik/traefik.yml.template > "${RUNTIME}/traefik.yml"

# Point file provider at runtime dynamic dir
sed -i 's|/etc/traefik/dynamic|/tmp/traefik-runtime/dynamic|g' "${RUNTIME}/traefik.yml"

cp /etc/traefik/dynamic/tls.yml "${RUNTIME}/dynamic/tls.yml"

sed \
  -e "s|{{WEBHOOK_HOST}}|${WEBHOOK_HOST}|g" \
  -e "s|{{BACKEND_URL}}|${BACKEND_URL}|g" \
  /etc/traefik/dynamic/http.yml.template \
  > "${RUNTIME}/dynamic/http.yml"

exec traefik --configFile="${RUNTIME}/traefik.yml"

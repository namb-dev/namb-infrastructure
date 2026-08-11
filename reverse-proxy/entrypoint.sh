#!/bin/sh
set -eu

: "${ACME_EMAIL:?ACME_EMAIL is required}"
: "${WEBHOOK_HOST_PROD:?WEBHOOK_HOST_PROD is required}"
: "${WEBHOOK_HOST_DEV:?WEBHOOK_HOST_DEV is required}"
: "${BACKEND_URL_PROD:?BACKEND_URL_PROD is required}"
: "${BACKEND_URL_DEV:?BACKEND_URL_DEV is required}"
: "${BACKEND_HOST_PROD:?BACKEND_HOST_PROD is required}"
: "${BACKEND_HOST_DEV:?BACKEND_HOST_DEV is required}"

# RF public :443 is typically Xray (Google cert) — EE must not use that as backend.
warn_backend() {
  case "$1" in
    https://*:443|https://*[^0-9/]|https://*[a-zA-Z]/*)
      # https without an explicit non-443 port → almost certainly public Xray
      case "$1" in
        https://*:8443|https://*:8443/*) ;;
        https://*)
          echo "WARNING: $2=$1 looks like public HTTPS. RF :443 is often Xray→Google and will 500. Prefer http://<RF_IP>:8000." >&2
          ;;
      esac
      ;;
  esac
}
warn_backend "${BACKEND_URL_PROD}" BACKEND_URL_PROD
warn_backend "${BACKEND_URL_DEV}" BACKEND_URL_DEV

chmod 600 /acme.json

RUNTIME=/tmp/traefik-runtime
mkdir -p "${RUNTIME}/dynamic"

sed -e "s|\${ACME_EMAIL}|${ACME_EMAIL}|g" \
  /etc/traefik/traefik.yml.template > "${RUNTIME}/traefik.yml"

# Point file provider at runtime dynamic dir
sed -i 's|/etc/traefik/dynamic|/tmp/traefik-runtime/dynamic|g' "${RUNTIME}/traefik.yml"

cp /etc/traefik/dynamic/tls.yml "${RUNTIME}/dynamic/tls.yml"

sed \
  -e "s|{{WEBHOOK_HOST_PROD}}|${WEBHOOK_HOST_PROD}|g" \
  -e "s|{{WEBHOOK_HOST_DEV}}|${WEBHOOK_HOST_DEV}|g" \
  -e "s|{{BACKEND_URL_PROD}}|${BACKEND_URL_PROD}|g" \
  -e "s|{{BACKEND_URL_DEV}}|${BACKEND_URL_DEV}|g" \
  -e "s|{{BACKEND_HOST_PROD}}|${BACKEND_HOST_PROD}|g" \
  -e "s|{{BACKEND_HOST_DEV}}|${BACKEND_HOST_DEV}|g" \
  /etc/traefik/dynamic/http.yml.template \
  > "${RUNTIME}/dynamic/http.yml"

exec traefik --configFile="${RUNTIME}/traefik.yml"

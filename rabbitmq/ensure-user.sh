#!/usr/bin/env bash
# Keep AMQP user password in sync with env on every start.
# RABBITMQ_DEFAULT_* only apply on first boot of an empty volume otherwise.
set -euo pipefail

sync_user() {
	local user="${RABBITMQ_DEFAULT_USER:-}"
	local pass="${RABBITMQ_DEFAULT_PASS:-}"
	if [[ -z "$user" || -z "$pass" ]]; then
		return 0
	fi

	rabbitmqctl await_startup
	if rabbitmqctl list_users | awk '{print $1}' | grep -qx "$user"; then
		rabbitmqctl change_password "$user" "$pass"
	else
		rabbitmqctl add_user "$user" "$pass"
		rabbitmqctl set_user_tags "$user" administrator
		rabbitmqctl set_permissions -p / "$user" ".*" ".*" ".*"
	fi
}

sync_user &
exec docker-entrypoint.sh "$@"

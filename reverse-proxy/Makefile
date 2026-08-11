.PHONY: init up down logs deploy sync check

DEST ?= ~/tg-reverse-proxy
# Set RESTART=0 to only rsync (keep running container as-is).
RESTART ?= 1

init:
	@test -f .env || cp .env.example .env
	@touch acme.json && chmod 600 acme.json
	@chmod +x entrypoint.sh
	@echo "Edit .env, then: make up"

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f --tail=200

deploy:
	docker compose up -d --force-recreate

# Local health on the EE box (run inside ~/tg-reverse-proxy).
check:
	@set -euo pipefail; \
	echo "== compose ps =="; docker compose ps; \
	echo; echo "== container =="; docker inspect tg-reverse-proxy --format 'status={{.State.Status}} exit={{.State.ExitCode}} OOM={{.State.OOMKilled}} error={{.State.Error}}' 2>/dev/null || echo 'container missing'; \
	echo; echo "== runtime http.yml =="; docker exec tg-reverse-proxy cat /tmp/traefik-runtime/dynamic/http.yml 2>/dev/null || echo 'cannot exec (container down?)'; \
	. ./.env; \
	echo; echo "== backend urls =="; \
	echo "BACKEND_URL_PROD=$$BACKEND_URL_PROD"; \
	echo "BACKEND_HOST_PROD=$${BACKEND_HOST_PROD:-<unset>}"; \
	case "$$BACKEND_URL_PROD" in https://*|https://*:443*) echo "NOTE: if this is RF :443, expect Google cert / 500 — use http://RF_IP:8000"; esac; \
	echo; echo "== local curl :8443 (Host $$WEBHOOK_HOST_PROD) =="; \
	curl -sS -k -o /tmp/tg-proxy-check.body -w 'HTTP %{http_code}\n' --connect-timeout 5 \
		-H "Host: $$WEBHOOK_HOST_PROD" \
		"https://127.0.0.1:8443/api/webhook/telegram/0" || true; \
	head -c 300 /tmp/tg-proxy-check.body 2>/dev/null; echo; \
	echo; echo "== backend health (prod) =="; \
	curl -sS -o /dev/null -w 'BACKEND_URL_PROD %{http_code}\n' --connect-timeout 5 \
		"$${BACKEND_URL_PROD%/}/api/healthcheck" || echo "BACKEND_URL_PROD unreachable"; \
	echo; echo "== recent logs =="; docker compose logs --tail=50

# Full sync to EE VPS even if the proxy dir/container already exists:
#   make sync HOST=user@ee-vps
#   make sync HOST=user@ee-vps DEST=~/tg-reverse-proxy
# Preserves remote .env and acme.json; overwrites everything else; recreates Traefik.
sync:
	@test -n "$(HOST)" || (echo "Usage: make sync HOST=user@ee-vps [DEST=~/tg-reverse-proxy] [RESTART=1]" >&2; exit 1)
	rsync -avz --delete \
		--exclude '.env' \
		--exclude 'acme.json' \
		--exclude 'dynamic/http.yml' \
		--exclude '.git/' \
		./ "$(HOST):$(DEST)/"
	@echo "Files synced to $(HOST):$(DEST)"
	ssh "$(HOST)" 'set -euo pipefail; \
		cd $(DEST); \
		chmod +x entrypoint.sh; \
		touch acme.json && chmod 600 acme.json; \
		if [ ! -f .env ]; then \
			cp .env.example .env; \
			echo "Created .env from example — edit hosts/backends, then re-run: make sync HOST=$(HOST) DEST=$(DEST)" >&2; \
			exit 2; \
		fi; \
		if [ "$(RESTART)" = "1" ]; then \
			docker compose up -d --force-recreate; \
			docker compose ps; \
			echo "Traefik recreated; http.yml regenerated from template on start."; \
		else \
			echo "RESTART=0: container left as-is. Run on VPS: cd $(DEST) && make deploy"; \
		fi'

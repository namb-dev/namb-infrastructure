.PHONY: init up down logs deploy sync

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
	docker compose logs -f --tail=100

deploy:
	docker compose up -d --force-recreate

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

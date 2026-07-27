.PHONY: init up down logs deploy sync-help

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

# Deploy only this folder to EE VPS (does not need the rest of namb-infrastructure):
#   make sync HOST=user@ee-vps DEST=~/tg-reverse-proxy
sync:
	@test -n "$(HOST)" || (echo "Usage: make sync HOST=user@ee-vps DEST=~/tg-reverse-proxy" >&2; exit 1)
	rsync -av --delete \
		--exclude '.env' \
		--exclude 'acme.json' \
		--exclude 'dynamic/http.yml' \
		./ "$(HOST):$(or $(DEST),~/tg-reverse-proxy)/"
	@echo "Synced. On VPS: cd $(or $(DEST),~/tg-reverse-proxy) && make init && edit .env && make up"

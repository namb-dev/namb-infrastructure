# Makefile

ENV_FILE=.env
BASE_ENV_FILE=.env.base

# Default environment (can be overridden by specifying ENV=local|development|production)
ENV ?= development

env:
	@echo "Creating $(ENV_FILE) for environment: $(ENV)"
	@if [ -f $(BASE_ENV_FILE) ]; then \
		rm -f $(ENV_FILE); \
		cat $(BASE_ENV_FILE) >> $(ENV_FILE); \
		echo ".env.base content added."; \
	else \
		echo "Error: $(BASE_ENV_FILE) not found!" >&2; \
		exit 1; \
	fi
	@if [ -f .env.$(ENV) ]; then \
		cat .env.$(ENV) >> $(ENV_FILE); \
		echo ".env.$(ENV) content added."; \
	else \
		echo "Warning: .env.$(ENV) not found. Only .env.base content added."; \
	fi
	@echo "$(ENV_FILE) has been created successfully."
	@echo "Set GRAFANA_ADMIN_PASSWORD in $(ENV_FILE), then: make up ENV=$(ENV)"

ensure-creds:
	@set -a; . ./$(ENV_FILE); set +a; \
	if [ -z "$$GRAFANA_ADMIN_PASSWORD" ] || [ "$$GRAFANA_ADMIN_PASSWORD" = "change-me" ]; then \
		echo "Error: set a real GRAFANA_ADMIN_PASSWORD in $(ENV_FILE) (not change-me)." >&2; \
		exit 1; \
	fi; \
	if [ -z "$$GRAFANA_ROOT_URL" ]; then \
		echo "Error: set GRAFANA_ROOT_URL in $(ENV_FILE)." >&2; \
		exit 1; \
	fi

up: ensure-creds
	@echo "Starting the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d
	@echo "$(ENV) environment has been started successfully."

build: ensure-creds
	@echo "Recreating and rebuilding the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d --build --force-recreate --remove-orphans
	@echo "$(ENV) environment has been started successfully."

deploy: ensure-creds
	@echo "Recreating the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d --force-recreate
	@echo "$(ENV) environment has been started successfully."

down:
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml down --remove-orphans

.PHONY: env ensure-creds up build deploy down

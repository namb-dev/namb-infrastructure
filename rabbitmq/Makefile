# Makefile

ENV_FILE=.env
BASE_ENV_FILE=.env.base

# Default environment (can be overridden by specifying ENV=dev or ENV=local)
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
	@echo "Fill RABBITMQ_USER and RABBITMQ_PASSWORD in $(ENV_FILE) (must match apps), then: make up ENV=$(ENV)"

ensure-auth:
	@set -a; . ./$(ENV_FILE); set +a; \
	if [ -z "$$RABBITMQ_USER" ] || [ -z "$$RABBITMQ_PASSWORD" ]; then \
		echo "Error: set RABBITMQ_USER and RABBITMQ_PASSWORD in $(ENV_FILE) (must match app credentials)." >&2; \
		exit 1; \
	fi; \
	AUTH=$$(printf '%s' "$$RABBITMQ_USER:$$RABBITMQ_PASSWORD" | base64 | tr -d '\n'); \
	if grep -q '^RABBITMQ_BASIC_AUTH=' $(ENV_FILE); then \
		sed -i "s|^RABBITMQ_BASIC_AUTH=.*|RABBITMQ_BASIC_AUTH=$$AUTH|" $(ENV_FILE); \
	else \
		echo "RABBITMQ_BASIC_AUTH=$$AUTH" >> $(ENV_FILE); \
	fi; \
	echo "RABBITMQ_BASIC_AUTH ready for management autologin."

up: ensure-auth
	@echo "Starting the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d
	@echo "$(ENV) environment has been started successfully."

build: ensure-auth
	@echo "Recreating and rebuilding the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d --build --force-recreate --remove-orphans
	@echo "$(ENV) environment has been started successfully."

deploy: ensure-auth
	@echo "Recreating the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d --force-recreate
	@echo "$(ENV) environment has been started successfully."

.PHONY: env ensure-auth up build deploy

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

up:
	@echo "Starting the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d
	@echo "$(ENV) environment has been started successfully."

build:
	@echo "Recreating and rebuilding the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d --build --force-recreate --remove-orphans
	@echo "$(ENV) environment has been started successfully."

deploy:
	@echo "Recreating the $(ENV) environment"
	docker compose -f docker-compose.yml -f docker-compose.@$(ENV).yml up -d --force-recreate
	@echo "$(ENV) environment has been started successfully."

.PHONY: make_env up build deploy

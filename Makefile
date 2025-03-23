include .env
export

PHPUNIT         = ./vendor/bin/phpunit
PHPSTAN         = ./vendor/bin/phpstan --memory-limit=1G
PHPINSIGHTS     = ./vendor/bin/phpinsights
SAIL            = ./vendor/bin/sail
ARTISAN         = php artisan
LOCALHOST_ENTRY = "127.0.0.1 localhost indoxnito.local"
HOSTS_PATH         = /etc/hosts
DB_CONTAINER_NAME = indoxnito-mariadb-1

.PHONY: shell start stop init-install install update test phpstan phpinsights standards lint-fix ide-helper db-up db-reset key-gen cache-clear copy-env init update-hosts wait-for-db db-seed

help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

shell: ## login to web/laravel container
	$(SAIL) exec laravel.test bash

start: ## start the docker services
	$(SAIL) up -d

stop: ## down docker services
	$(SAIL) stop

rebuild: ## rebuild after updating compose
	$(SAIL) build --no-cache

init-install: ## Initial Installation of deps. Used if the host doesn't have compatible PHP or Composer
	docker run --rm \
	-u "$$(id -u):$$(id -g)" \
	-v $$(pwd):/var/www/html \
	-w /var/www/html \
	laravelsail/php82-composer:latest \
	composer install --ignore-platform-reqs

install-front-end:
	$(SAIL) npm install

install: ## Install all php libraries
	$(SAIL) composer install

update: ## Update all php libraries
	$(SAIL) composer update

test: ## run tests
	$(SAIL) $(ARTISAN) test

phpstan: ## run phpstan
	-$(SAIL) exec laravel.test $(PHPSTAN)

phpinsights: ## run phpinsights
	-$(SAIL) exec laravel.test $(PHPINSIGHTS)

standards: phpstan phpinsights ## check if code complies to standards

lint-fix: ## fixes phpinsights
	$(SAIL) $(PHPINSIGHTS) --fix

ide-helper: ## generate ide-helper files
	$(SAIL) $(ARTISAN) ide-helper:generate
	$(SAIL) $(ARTISAN) ide-helper:models --nowrite
	$(SAIL) $(ARTISAN) ide-helper:meta

ide-helper-local: ## generate ide-helper files
	$(ARTISAN) ide-helper:generate
	$(ARTISAN) ide-helper:models --nowrite
	$(ARTISAN) ide-helper:meta

db-up: ## run migration and seed
	$(SAIL) $(ARTISAN) migrate --seed

db-reset: ## reset and re-seed
	$(SAIL) $(ARTISAN) migrate:refresh --seed

key-gen: ## Generate Private/Public keys
	$(SAIL) $(ARTISAN) key:generate

cache-clear: ## reset and re-seed
	$(SAIL) $(ARTISAN) cache:clear

copy-env: ## Copy .env file
	cp .env.example .env

init: init-install start key-gen wait-for-db db-up install-front-end ## Initialize for first time setup

queue-restart:
	$(SAIL) $(ARTISAN) queue:restart

update-hosts:
	@echo "Checking and adding to /etc/hosts..."
	@if ! grep -q $(LOCALHOST_ENTRY) $(HOSTS_PATH); then \
		echo $(LOCALHOST_ENTRY) | sudo tee -a $(HOSTS_PATH); \
		echo "Entry added to $(HOSTS_PATH)."; \
	else \
		echo "Entry already exists in $(HOSTS_PATH)"; \
	fi

wait-for-db:
	@echo "Waiting for database to become ready..."
	@while ! docker exec $(DB_CONTAINER_NAME) mariadb -u"$$DB_USERNAME" -p"$$DB_PASSWORD" -e"SELECT 1" > /dev/null 2>&1; do \
		sleep 1; \
		echo "Waiting for DB..."; \
	done
	@echo "DB Healthy"

db-seed: ## run php artisan db:seed
	$(SAIL) $(ARTISAN) db:seed

pint:
	./vendor/bin/pint --dirty
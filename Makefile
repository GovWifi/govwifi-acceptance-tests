RADIUS_SERVER_IP := $()

setup: .frontend .authentication-api .logging-api .user-signup-api .admin

.PHONY: build
build:
	docker compose down
	docker compose build --progress plain
	docker compose up govwifi-frontend-raddb

.PHONY: build
test: setup build
	docker compose run --rm govwifi-test

## used for codebuild / codepipeline to allow for custom branches
.PHONY: build
test-ci: build
	docker compose run --rm govwifi-test

# Assumes build has been run previously. Used for local development within this environment.
.PHONY: local-dev
local-dev:
	docker compose up -d local-dev govwifi-developer-helper

.PHONY: shell
shell: local-dev
	docker compose exec local-dev /bin/sh -l

.PHONY: admin-shell
admin-shell: local-dev
	docker compose exec govwifi-admin /bin/sh

.PHONY: console
console: local-dev
	docker compose exec govwifi-admin /usr/local/bundle/bin/rails console

.PHONY: admin-db-setup
admin-db-setup: local-dev
	docker compose cp local-dev/admin-db-setup.sh govwifi-admin:/tmp
	docker compose cp local-dev/admin_database_configuration.rb govwifi-admin:/tmp
	docker compose exec govwifi-admin /bin/sh /tmp/admin-db-setup.sh

.PHONY: tail-logs
tail-logs:
	docker compose logs -f

.admin:
	git clone https://github.com/GovWifi/govwifi-admin.git .admin

.frontend:
	git clone https://github.com/GovWifi/govwifi-frontend.git .frontend

.authentication-api:
	git clone https://github.com/GovWifi/govwifi-authentication-api.git .authentication-api

.user-signup-api:
	git clone https://github.com/GovWifi/govwifi-user-signup-api.git .user-signup-api

.logging-api:
	git clone https://github.com/GovWifi/govwifi-logging-api.git .logging-api

destroy:
	docker compose down --volumes

.PHONY: clean
clean:
	rm -rf .frontend .logging-api .authentication-api .admin .user-signup-api

setup: .frontend .authentication-api .logging-api .user-signup-api

build:
	docker compose down
	docker compose build --progress plain
	docker compose up govwifi-frontend-raddb-local

test: setup build
	docker compose run --rm govwifi-test

## used for codebuild / codepipeline to allow for custom branches
test-ci: build
	docker compose run --rm govwifi-test

# Assumes build has been run previously. Used for local development within this environment.
.PHONY: local-dev
local-dev:
	docker compose up -d local-dev

.PHONY: shell
shell: local-dev
	docker compose exec local-dev /bin/sh

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

clean:
	rm -rf .frontend .logging-api .authentication-api

.PHONY: setup build test test-ci destroy clean

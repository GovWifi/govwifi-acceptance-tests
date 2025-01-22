setup: .frontend .authentication-api .logging-api

build: 
	docker compose down
	docker compose build --progress plain
	docker compose up govwifi-frontend-raddb-local

test: setup build
	docker compose run --rm govwifi-test

## used for codebuild / codepipeline to allow for custom branches
test-ci: build
	docker compose run --rm govwifi-test

.frontend:
	git clone https://github.com/GovWifi/govwifi-frontend.git .frontend

.authentication-api:
	git clone https://github.com/GovWifi/govwifi-authentication-api.git .authentication-api

.logging-api:
	git clone https://github.com/GovWifi/govwifi-logging-api.git .logging-api

destroy: 
	docker compose down --volumes

clean:
	rm -rf .frontend .logging-api .authentication-api

.PHONY: setup build test test-ci destroy clean

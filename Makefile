# Dev stack + lokální HTTPS (viz Caddyfile a scripts/setup-local-https.sh)

.PHONY: https proxy stack up down

https: ## jednorázové nastavení mkcert certů + /etc/hosts
	./scripts/setup-local-https.sh

stack: ## spustit Saleor dev stack (docker compose)
	docker compose up -d

up: stack ## celý dev stack včetně HTTPS proxy (caddy jede v compose)

down: ## zastavit stack
	docker compose down

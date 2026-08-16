# Dev stack + lokální HTTPS (viz Caddyfile a scripts/setup-local-https.sh)

.PHONY: https proxy stack up down

https: ## jednorázové nastavení mkcert certů + /etc/hosts
	./scripts/setup-local-https.sh

proxy: ## spustit Caddy (HTTPS na local.a-green.cz)
	caddy run --config Caddyfile

stack: ## spustit Saleor dev stack (docker compose)
	docker compose up -d

up: stack proxy ## celý dev stack včetně HTTPS proxy

down: ## zastavit stack i proxy
	docker compose down
	caddy stop 2>/dev/null || true

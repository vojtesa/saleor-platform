#!/usr/bin/env bash
# Start the whole local dev environment with one command:
#   docker stack (Saleor, db, typesense, workflow, ...) + Caddy HTTPS proxy
#   → waits for the API → runs frontend dev server in the foreground.
#
# Usage: bash dev.sh   (from anywhere; Ctrl+C stops the frontend)
# The stack keeps running in the background — stop it with `make down`.
set -euo pipefail

# mkcert CA pro Node (codegen při pnpm dev) — i pro staré shelly bez .bashrc
export NODE_EXTRA_CA_CERTS="${NODE_EXTRA_CA_CERTS:-$HOME/.local/share/mkcert/rootCA.pem}"

cd "$(dirname "$0")"

echo "▶ Startuji dev stack (docker compose + Caddy HTTPS)"
docker compose up -d

echo "▶ Čekám na Saleor (https://api.local.a-green.cz/health/)"
for _ in $(seq 1 60); do
	if curl -sk -o /dev/null "https://api.local.a-green.cz/health/" 2>/dev/null; then
		echo "✓ Saleor běží"
		break
	fi
	sleep 2
done

echo ""
echo "✓ Stack běží — otevři https://www.local.a-green.cz"
echo "▶ Startuji frontend (pnpm dev) — ukončení: Ctrl+C"
echo ""
cd ../frontend
pnpm dev

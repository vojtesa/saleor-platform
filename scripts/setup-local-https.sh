#!/usr/bin/env bash
# Jednorázové nastavení lokálního HTTPS:
#   1) mkcert CA + wildcard cert pro *.local.a-green.cz (do certs/, gitignored)
#   2) /etc/hosts záznamy (idempotentně; bez nich se domény nerozliší — v DNS nejsou)
#
# Spuštění: ./scripts/setup-local-https.sh
set -euo pipefail

HOSTS_ENTRY="127.0.0.1 www.local.a-green.cz api.local.a-green.cz workflow.local.a-green.cz dashboard.local.a-green.cz"

command -v mkcert >/dev/null || { echo "mkcert není nainstalované (brew install mkcert)"; exit 1; }

cd "$(dirname "$0")/.."
mkdir -p certs

# Caddy běží jako docker compose služba — porty 443/80 binduje docker daemon
# (root), takže na hostu žádné setcap není potřeba.

# CA do systémového trust storu (nss pro Firefox, systém pro Chromium/curl)
mkcert -install

# Wildcard cert — jeden pokrývá všechny subdomény
mkcert -cert-file certs/_wildcard.local.a-green.cz.pem \
       -key-file  certs/_wildcard.local.a-green.cz-key.pem \
       "local.a-green.cz" "*.local.a-green.cz"

# /etc/hosts — idempotentní přidání
if grep -qF "www.local.a-green.cz" /etc/hosts; then
  echo "hosts: záznamy už existují, přeskakuji"
else
  echo "$HOSTS_ENTRY" | sudo tee -a /etc/hosts >/dev/null || {
    echo "Nepodařilo se zapsat do /etc/hosts — přidej ručně:" >&2
    echo "  $HOSTS_ENTRY" >&2
  }
fi

echo ""
echo "Hotovo. Zkontroluj: curl -s https://www.local.a-green.cz -o /dev/null -w '%{http_code}'"
echo "Stack + HTTPS proxy spustíš: make up (Caddy jede jako compose služba)"

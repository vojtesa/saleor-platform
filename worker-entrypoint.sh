#!/bin/bash
set -e

# Start the promotion-price watchdog in background
/app/promotion-watchdog.sh &

# Start Celery worker with embedded Beat scheduler.
# --concurrency: bez něj si Celery vezme jeden proces na jádro (na tomhle
# stroji 16) a každý si drží vlastní frontu odložených retry úloh. Pro lokální
# vývoj čtyři stačí a drží se to pod mem_limit z docker-compose.yml.
exec celery -A saleor --app=saleor.celeryconf:app worker --loglevel=info -B \
  --concurrency=4

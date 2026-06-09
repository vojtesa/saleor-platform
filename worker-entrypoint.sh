#!/bin/bash
set -e

# Start the promotion-price watchdog in background
/app/promotion-watchdog.sh &

# Start Celery worker with embedded Beat scheduler
exec celery -A saleor --app=saleor.celeryconf:app worker --loglevel=info -B

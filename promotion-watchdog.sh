#!/bin/bash
# Watchdog script — periodically recalculates promotion prices.
# Workaround for Celery Beat tasks not processing dirty promotion rules
# in Saleor 3.23 dev environments.

recalc() {
    python3 -c "
import django, os
os.environ['DJANGO_SETTINGS_MODULE'] = 'saleor.settings'
django.setup()
from saleor.product.tasks import (
    update_variant_relations_for_active_promotion_rules_task,
    recalculate_discounted_price_for_products_task,
)
update_variant_relations_for_active_promotion_rules_task.apply()
recalculate_discounted_price_for_products_task.apply()
" 2>/dev/null
}

# Run immediately on startup, then every 30s
while true; do
    recalc
    sleep 30
done

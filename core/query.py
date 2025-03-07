import os

import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.pos.models import Sale

sale = Sale.objects.get(id=1)
print(sale.generate_electronic_invoice())
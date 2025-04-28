import json
from django.core.management.base import BaseCommand
from aps_app.models import ProductTranslation

class Command(BaseCommand):
    help = 'Import products from a JSON file'

    def add_arguments(self, parser):
        parser.add_argument('product_list.json', type=str, help='Path to the JSON file')

    def handle(self, *args, **kwargs):
        file_path = kwargs['product_list.json']
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        objects = [
            ProductTranslation(
                codetved=item['codetved'],
                position=item['position'],
                english=item['english'],
                russian=item['russian'],
                uzbek=item['uzbek'],
                turkish=item['turkish']
            )
            for item in data
        ]
        ProductTranslation.objects.bulk_create(objects, batch_size=1000)
        self.stdout.write(self.style.SUCCESS(f"Successfully imported {len(objects)} products"))
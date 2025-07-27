import random
from datetime import date, timedelta
from django.core.management.base import BaseCommand
from django.db import transaction
from ports.models import Country, Port
from containers.models import ContainerType, CargoType
from quotes.models import ShippingRoute, BaseRate

class Command(BaseCommand):
    help = 'Popula la base de datos con datos de ejemplo.'

    def handle(self, *args, **kwargs):
        self.stdout.write(self.style.SUCCESS('Iniciando la población de la base de datos...'))

        with transaction.atomic():
            self._crear_paises()
            self._crear_puertos()
            self._crear_tipos_contenedores()
            self._crear_tipos_carga()
            self._crear_rutas_envio()
            self._crear_tarifas_base()

        self.stdout.write(self.style.SUCCESS('¡Población de la base de datos completada exitosamente!'))

    def _crear_paises(self):
        self.stdout.write('Creando países...')
        countries_data = [
            {'name': 'Estados Unidos', 'code': 'USA', 'continent': 'América del Norte'},
            {'name': 'China', 'code': 'CHN', 'continent': 'Asia'},
            {'name': 'Alemania', 'code': 'DEU', 'continent': 'Europa'},
            {'name': 'Brasil', 'code': 'BRA', 'continent': 'América del Sur'},
            {'name': 'Australia', 'code': 'AUS', 'continent': 'Oceanía'},
            {'name': 'Sudáfrica', 'code': 'ZAF', 'continent': 'África'},
            {'name': 'Japón', 'code': 'JPN', 'continent': 'Asia'},
            {'name': 'Reino Unido', 'code': 'GBR', 'continent': 'Europa'},
            {'name': 'Canadá', 'code': 'CAN', 'continent': 'América del Norte'},
            {'name': 'India', 'code': 'IND', 'continent': 'Asia'},
        ]
        for data in countries_data:
            Country.objects.get_or_create(code=data['code'], defaults=data)
        self.stdout.write(self.style.SUCCESS(f'Creados/actualizados {len(countries_data)} países.'))

    def _crear_puertos(self):
        self.stdout.write('Creando puertos...')
        usa = Country.objects.get(code='USA')
        chn = Country.objects.get(code='CHN')
        deu = Country.objects.get(code='DEU')
        bra = Country.objects.get(code='BRA')
        aus = Country.objects.get(code='AUS')
        jpn = Country.objects.get(code='JPN')

        ports_data = [
            {'name': 'Puerto de Nueva York y Nueva Jersey', 'code': 'USNYC', 'country': usa, 'city': 'Nueva York', 'latitude': 40.6892494, 'longitude': -74.0445004},
            {'name': 'Puerto de Los Ángeles', 'code': 'USLAX', 'country': usa, 'city': 'Los Ángeles', 'latitude': 33.729769, 'longitude': -118.262158},
            {'name': 'Puerto de Shanghái', 'code': 'CNSHA', 'country': chn, 'city': 'Shanghái', 'latitude': 31.230416, 'longitude': 121.473701},
            {'name': 'Puerto de Shenzhen', 'code': 'CNSZN', 'country': chn, 'city': 'Shenzhen', 'latitude': 22.543099, 'longitude': 114.057861},
            {'name': 'Puerto de Hamburgo', 'code': 'DEHAM', 'country': deu, 'city': 'Hamburgo', 'latitude': 53.548829, 'longitude': 9.987227},
            {'name': 'Puerto de Santos', 'code': 'BRSSZ', 'country': bra, 'city': 'Santos', 'latitude': -23.960833, 'longitude': -46.333333},
            {'name': 'Puerto de Sídney', 'code': 'AUSYD', 'country': aus, 'city': 'Sídney', 'latitude': -33.868820, 'longitude': 151.209290},
            {'name': 'Puerto de Tokio', 'code': 'JPTYO', 'country': jpn, 'city': 'Tokio', 'latitude': 35.689487, 'longitude': 139.691711},
        ]
        for data in ports_data:
            Port.objects.get_or_create(code=data['code'], defaults=data)
        self.stdout.write(self.style.SUCCESS(f'Creados/actualizados {len(ports_data)} puertos.'))

    def _crear_tipos_contenedores(self):
        self.stdout.write('Creando tipos de contenedores...')
        container_types_data = [
            {'name': 'Contenedor Seco 20ft', 'size': '20', 'type': 'DRY', 'max_weight': 28000, 'internal_length': 5.89, 'internal_width': 2.35, 'internal_height': 2.39, 'volume': 33.2},
            {'name': 'Contenedor Seco 40ft', 'size': '40', 'type': 'DRY', 'max_weight': 26500, 'internal_length': 12.03, 'internal_width': 2.35, 'internal_height': 2.39, 'volume': 67.7},
            {'name': 'Contenedor High Cube 40ft', 'size': '40HC', 'type': 'DRY', 'max_weight': 26500, 'internal_length': 12.03, 'internal_width': 2.35, 'internal_height': 2.69, 'volume': 76.0},
            {'name': 'Contenedor Refrigerado 20ft', 'size': '20', 'type': 'REEFER', 'max_weight': 27000, 'internal_length': 5.45, 'internal_width': 2.29, 'internal_height': 2.27, 'volume': 28.3},
            {'name': 'Contenedor Refrigerado 40ft', 'size': '40', 'type': 'REEFER', 'max_weight': 29000, 'internal_length': 11.58, 'internal_width': 2.29, 'internal_height': 2.50, 'volume': 67.0},
        ]
        for data in container_types_data:
            ContainerType.objects.get_or_create(name=data['name'], defaults=data)
        self.stdout.write(self.style.SUCCESS(f'Creados/actualizados {len(container_types_data)} tipos de contenedores.'))

    def _crear_tipos_carga(self):
        self.stdout.write('Creando tipos de carga...')
        cargo_types_data = [
            {'name': 'Carga General', 'description': 'Mercancías secas estándar', 'hazardous': False, 'requires_special_handling': False},
            {'name': 'Electrónica', 'description': 'Equipos electrónicos sensibles', 'hazardous': False, 'requires_special_handling': True},
            {'name': 'Químicos (No Peligrosos)', 'description': 'Químicos industriales no peligrosos', 'hazardous': False, 'requires_special_handling': True},
            {'name': 'Materiales Peligrosos (Clase 3)', 'description': 'Líquidos inflamables', 'hazardous': True, 'requires_special_handling': True},
            {'name': 'Perecederos (Refrigerados)', 'description': 'Productos alimenticios que requieren refrigeración', 'hazardous': False, 'requires_special_handling': True},
        ]
        for data in cargo_types_data:
            CargoType.objects.get_or_create(name=data['name'], defaults=data)
        self.stdout.write(self.style.SUCCESS(f'Creados/actualizados {len(cargo_types_data)} tipos de carga.'))

    def _crear_rutas_envio(self):
        self.stdout.write('Creando rutas de envío...')
        usnyc = Port.objects.get(code='USNYC')
        uslax = Port.objects.get(code='USLAX')
        cnsha = Port.objects.get(code='CNSHA')
        cnszn = Port.objects.get(code='CNSZN')
        deham = Port.objects.get(code='DEHAM')
        brssz = Port.objects.get(code='BRSSZ')
        ausyd = Port.objects.get(code='AUSYD')
        jptyo = Port.objects.get(code='JPTYO')

        routes_data = [
            {'origin_port': usnyc, 'destination_port': cnsha, 'distance_nautical_miles': 10500, 'estimated_transit_days': 30},
            {'origin_port': cnsha, 'destination_port': usnyc, 'distance_nautical_miles': 10500, 'estimated_transit_days': 30},
            {'origin_port': uslax, 'destination_port': jptyo, 'distance_nautical_miles': 5500, 'estimated_transit_days': 15},
            {'origin_port': jptyo, 'destination_port': uslax, 'distance_nautical_miles': 5500, 'estimated_transit_days': 15},
            {'origin_port': deham, 'destination_port': brssz, 'distance_nautical_miles': 5000, 'estimated_transit_days': 20},
            {'origin_port': brssz, 'destination_port': deham, 'distance_nautical_miles': 5000, 'estimated_transit_days': 20},
            {'origin_port': cnszn, 'destination_port': ausyd, 'distance_nautical_miles': 4000, 'estimated_transit_days': 12},
            {'origin_port': ausyd, 'destination_port': cnszn, 'distance_nautical_miles': 4000, 'estimated_transit_days': 12},
        ]
        for data in routes_data:
            ShippingRoute.objects.get_or_create(
                origin_port=data['origin_port'],
                destination_port=data['destination_port'],
                defaults=data
            )
        self.stdout.write(self.style.SUCCESS(f'Creadas/actualizadas {len(routes_data)} rutas de envío.'))

    def _crear_tarifas_base(self):
        self.stdout.write('Creando tarifas base...')
        today = date.today()
        
        # Obtener algunos tipos de contenedores comunes
        dry_20ft = ContainerType.objects.get(size='20', type='DRY')
        dry_40ft = ContainerType.objects.get(size='40', type='DRY')
        hc_40ft = ContainerType.objects.get(size='40HC', type='DRY')
        reefer_20ft = ContainerType.objects.get(size='20', type='REEFER')

        # Obtener algunas rutas comunes
        usnyc_cnsha = ShippingRoute.objects.get(origin_port__code='USNYC', destination_port__code='CNSHA')
        cnsha_usnyc = ShippingRoute.objects.get(origin_port__code='CNSHA', destination_port__code='USNYC')
        uslax_jptyo = ShippingRoute.objects.get(origin_port__code='USLAX', destination_port__code='JPTYO')
        deham_brssz = ShippingRoute.objects.get(origin_port__code='DEHAM', destination_port__code='BRSSZ')

        base_rates_data = [
            # USNYC <-> CNSHA
            {'route': usnyc_cnsha, 'container_type': dry_20ft, 'base_rate_usd': 2500.00, 'fuel_surcharge_percentage': 15, 'effective_from': today},
            {'route': usnyc_cnsha, 'container_type': dry_40ft, 'base_rate_usd': 4000.00, 'fuel_surcharge_percentage': 15, 'effective_from': today},
            {'route': usnyc_cnsha, 'container_type': hc_40ft, 'base_rate_usd': 4500.00, 'fuel_surcharge_percentage': 15, 'effective_from': today},
            {'route': usnyc_cnsha, 'container_type': reefer_20ft, 'base_rate_usd': 3500.00, 'fuel_surcharge_percentage': 20, 'effective_from': today},

            {'route': cnsha_usnyc, 'container_type': dry_20ft, 'base_rate_usd': 2200.00, 'fuel_surcharge_percentage': 12, 'effective_from': today},
            {'route': cnsha_usnyc, 'container_type': dry_40ft, 'base_rate_usd': 3800.00, 'fuel_surcharge_percentage': 12, 'effective_from': today},

            # USLAX <-> JPTYO
            {'route': uslax_jptyo, 'container_type': dry_20ft, 'base_rate_usd': 1800.00, 'fuel_surcharge_percentage': 10, 'effective_from': today},
            {'route': uslax_jptyo, 'container_type': dry_40ft, 'base_rate_usd': 3000.00, 'fuel_surcharge_percentage': 10, 'effective_from': today},

            # DEHAM <-> BRSSZ
            {'route': deham_brssz, 'container_type': dry_20ft, 'base_rate_usd': 2000.00, 'fuel_surcharge_percentage': 18, 'effective_from': today},
            {'route': deham_brssz, 'container_type': dry_40ft, 'base_rate_usd': 3500.00, 'fuel_surcharge_percentage': 18, 'effective_from': today},
        ]
        
        for data in base_rates_data:
            # Usar update_or_create para evitar duplicados si se ejecuta varias veces
            BaseRate.objects.update_or_create(
                route=data['route'],
                container_type=data['container_type'],
                effective_from=data['effective_from'],
                defaults=data
            )
        self.stdout.write(self.style.SUCCESS(f'Creadas/actualizadas {len(base_rates_data)} tarifas base.'))
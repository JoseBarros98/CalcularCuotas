# Cálculo de cotizaciones para envios de contenedores

Aplicación completa para la gestión y cálculo de cotizaciones de envíos marítimos. Backend desarrollado con Django REST Framework y frontend con Flutter.

## Características Principales

- **Cálculo de Cotizaciones**: Calcula costos de envío marítimo en tiempo real
- **Gestión Completa (CRUD)**: Países, puertos, contenedores, tipos de carga, rutas y tarifas
- **API RESTful**: Backend robusto con documentación automática
- **Interfaz Intuitiva**: Frontend Flutter multiplataforma

## Tecnologías

**Backend**: Python, Django REST Framework, SQL Server  
**Frontend**: Flutter/Dart

## Estructura del Proyecto

```
.
├── backend/
│   ├── shipquote_backend/     # Configuración Django
│   ├── ports/                 # Países y Puertos
│   ├── containers/            # Contenedores y Carga
│   └── quotes/                # Rutas, Tarifas y Cotizaciones
└── frontend/
    ├── lib/
    │   ├── models/            # Modelos Dart
    │   ├── services/          # API clients
    │   └── screens/           # UI screens
    └── pubspec.yaml
```

## Configuración Rápida

### Prerrequisitos
- Python 3.8+
- Flutter SDK 3.0+
- SQL Server

### Backend (Django)

1. **Instalar y configurar:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: .\venv\Scripts\activate
pip install -r requirements.txt
```

2. **Crear archivo `.env` en `backend/shipquote_backend/`:**
```dotenv
SECRET_KEY='tu_clave_secreta_aqui'
DEBUG=True
DB_NAME='shipquote_db'
DB_USER='sa'
DB_PASSWORD='YourStrong@Passw0rd'
DB_HOST='localhost'
DB_PORT='1433'
```

3. **Ejecutar:**
```bash
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

**Nota para Android Emulator**: Cambiar URL base a `http://10.0.2.2:8000`

## Endpoints Principales

- **API Base**: `/api/v1/`
- **Países**: `/countries/`
- **Puertos**: `/ports/`
- **Contenedores**: `/container-types/`
- **Carga**: `/cargo-types/`
- **Rutas**: `/shipping-routes/`
- **Tarifas**: `/base-rates/`
- **Cotización**: `/calculate-quote/` (POST)
- **Documentación**: `/api/schema/swagger-ui/`

## Uso

1. Accede al backend en `http://localhost:8000`
2. Usa el panel admin para datos iniciales o la app Flutter
3. Navega por las secciones usando el menú lateral
4. Calcula cotizaciones en la sección correspondiente

## Contribución

1. Fork del repositorio
2. Crear rama: `git checkout -b feature/nueva-caracteristica`
3. Commit: `git commit -am 'feat: Añadir característica'`
4. Push: `git push origin feature/nueva-caracteristica`
5. Crear Pull Request

## Licencia

MIT License

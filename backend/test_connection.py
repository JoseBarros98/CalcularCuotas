import os
import django
from django.conf import settings

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'shipquote_backend.settings')
django.setup()

from django.db import connection

def test_database_connection():
    try:
        # Probar la conexión
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            result = cursor.fetchone()
            
        print("✅ Conexión a SQL Server exitosa!")
        print(f"Resultado de prueba: {result}")
        
        # Mostrar información de la base de datos
        print(f"Base de datos: {settings.DATABASES['default']['NAME']}")
        print(f"Servidor: {settings.DATABASES['default']['HOST']}")
        print(f"Usuario: {settings.DATABASES['default']['USER']}")
        
    except Exception as e:
        print(f"❌ Error de conexión: {e}")
        print("\nVerifica:")
        print("1. SQL Server está ejecutándose")
        print("2. Las credenciales en .env son correctas")
        print("3. El firewall permite conexiones al puerto 1433")
        print("4. ODBC Driver 18 for SQL Server está instalado")

if __name__ == "__main__":
    test_database_connection()
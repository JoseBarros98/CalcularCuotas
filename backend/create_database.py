import pyodbc
from decouple import config

def create_database():
    
    server = config('DB_HOST', default='localhost')
    username = config('DB_USER', default='sa')
    password = config('DB_PASSWORD', default='root_password')
    database_name = config('DB_NAME', default='shipquote_db')
    
    connection_string = f"""
    DRIVER={{ODBC Driver 18 for SQL Server}};
    SERVER={server};
    UID={username};
    PWD={password};
    TrustServerCertificate=yes;
    """
    
    try:
        
        conn = pyodbc.connect(connection_string)
        conn.autocommit = True
        cursor = conn.cursor()
        
        cursor.execute(f"""
        IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '{database_name}')
        BEGIN
            CREATE DATABASE [{database_name}]
        END
        """)
        
        print(f"Base de datos '{database_name}' creada exitosamente o ya existe.")
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Error al crear la base de datos: {e}")

if __name__ == "__main__":
    create_database()
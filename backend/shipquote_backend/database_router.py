class DatabaseRouter:
    """
    Router para optimizar consultas en SQL Server
    """
    
    def db_for_read(self, model, **hints):
        """Sugerir la base de datos para lecturas."""
        return 'default'
    
    def db_for_write(self, model, **hints):
        """Sugerir la base de datos para escrituras."""
        return 'default'
    
    def allow_migrate(self, db, app_label, model_name=None, **hints):
        """Permitir migraciones."""
        return True
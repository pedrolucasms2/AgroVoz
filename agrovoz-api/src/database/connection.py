from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
from src.database.models import Base
import os
from typing import Generator

# URL do banco de dados (Railway PostgreSQL ou SQLite local)
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "sqlite:///./agrovoz.db"  # Fallback para desenvolvimento local
)

# Configurar engine do SQLAlchemy
if DATABASE_URL.startswith("sqlite"):
    # Configuração para SQLite (desenvolvimento)
    engine = create_engine(
        DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
        echo=False  # True para ver queries SQL
    )
else:
    # Configuração para PostgreSQL (produção)
    engine = create_engine(
        DATABASE_URL,
        echo=False,
        pool_size=10,
        max_overflow=20
    )

# Criar sessionmaker
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def create_tables():
    """Criar todas as tabelas no banco"""
    try:
        Base.metadata.create_all(bind=engine)
        print("✅ Tabelas criadas com sucesso!")
    except Exception as e:
        print(f"❌ Erro ao criar tabelas: {e}")

def get_db() -> Generator[Session, None, None]:
    """Dependency para obter sessão do banco"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Classe para operações do banco
class DatabaseService:
    def __init__(self, db: Session):
        self.db = db
    
    def criar_registro(self, registro_data: dict) -> int:
        """Criar novo registro rural"""
        from src.database.models import RegistroRural
        
        registro = RegistroRural(**registro_data)
        self.db.add(registro)
        self.db.commit()
        self.db.refresh(registro)
        return registro.id
    
    def buscar_registros_usuario(self, usuario_id: str, limit: int = 50):
        """Buscar registros de um usuário"""
        from src.database.models import RegistroRural
        
        return self.db.query(RegistroRural)\
                     .filter(RegistroRural.usuario_id == usuario_id)\
                     .order_by(RegistroRural.data_registro.desc())\
                     .limit(limit)\
                     .all()
    
    def confirmar_registro(self, registro_id: int, usuario_id: str) -> bool:
        """Confirmar um registro como correto"""
        from src.database.models import RegistroRural
        
        registro = self.db.query(RegistroRural)\
                         .filter(RegistroRural.id == registro_id,
                                RegistroRural.usuario_id == usuario_id)\
                         .first()
        
        if registro:
            registro.confirmado = True
            registro.precisa_revisao = False
            self.db.commit()
            return True
        return False

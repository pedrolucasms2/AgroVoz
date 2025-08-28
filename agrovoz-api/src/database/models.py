from sqlalchemy import Column, Integer, String, Float, DateTime, Text, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func
from datetime import datetime

Base = declarative_base()

class RegistroRural(Base):
    """Modelo principal para registros da fazenda"""
    __tablename__ = "registros_rurais"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(String(100), nullable=False, index=True)
    data_registro = Column(DateTime, default=func.now(), nullable=False)
    tipo_atividade = Column(String(50), nullable=False)  
    descricao_original = Column(Text, nullable=False) 
    
    # Campos extraídos pelo NLP
    pessoa_envolvida = Column(String(100), nullable=True)
    servico_realizado = Column(String(100), nullable=True)
    cultura = Column(String(50), nullable=True)
    talhao = Column(Integer, nullable=True)
    
    # Valores monetários e quantidades
    valor_monetario = Column(Float, nullable=True)
    quantidade = Column(Float, nullable=True)
    unidade_medida = Column(String(20), nullable=True) 
    
    # Status e validação
    confirmado = Column(Boolean, default=False)
    precisa_revisao = Column(Boolean, default=False)
    
    # Metadados
    data_criacao = Column(DateTime, default=func.now())
    data_atualizacao = Column(DateTime, default=func.now(), onupdate=func.now())

class Usuario(Base):
    """Modelo para usuários do sistema"""
    __tablename__ = "usuarios"
    
    id = Column(String(100), primary_key=True)  
    nome = Column(String(200), nullable=False)
    propriedade = Column(String(200), nullable=True)
    telefone = Column(String(20), nullable=True)
    data_cadastro = Column(DateTime, default=func.now())
    ativo = Column(Boolean, default=True)

class ConfiguracaoNLP(Base):
    """Configurações personalizadas de NLP por usuário"""
    __tablename__ = "configuracoes_nlp"
    
    id = Column(Integer, primary_key=True)
    usuario_id = Column(String(100), nullable=False)
    
    # Vocabulário personalizado
    nomes_funcionarios = Column(Text, nullable=True)  # JSON com nomes
    culturas_utilizadas = Column(Text, nullable=True)  # JSON com culturas
    talhoes_existentes = Column(Text, nullable=True)   # JSON com números
    
    data_atualizacao = Column(DateTime, default=func.now(), onupdate=func.now())

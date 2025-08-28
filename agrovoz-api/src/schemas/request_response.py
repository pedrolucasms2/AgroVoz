from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

class ProcessarFalaRequest(BaseModel):
    """Request para processar fala"""
    texto: str = Field(..., description="Texto transcrito da fala")
    usuario_id: str = Field(..., description="ID único do usuário")
    
    class Config:
        json_schema_extra = {
            "example": {
                "texto": "contratei o Eduardo para plantar soja no talhão 5 por 3000 reais",
                "usuario_id": "user_12345"
            }
        }

class DadosExtraidos(BaseModel):
    """Dados extraídos pelo NLP"""
    usuario_id: Optional[str] = None
    tipo_atividade: str
    pessoa_envolvida: Optional[str] = None
    servico_realizado: Optional[str] = None
    cultura: Optional[str] = None
    talhao: Optional[int] = None
    valor_monetario: Optional[float] = None
    quantidade: Optional[float] = None
    unidade_medida: Optional[str] = None
    descricao_original: str
    data_registro: datetime

class ValidacaoResult(BaseModel):
    """Resultado da validação"""
    valido: bool
    erros: List[str] = []
    alertas: List[str] = []
    sugestoes: List[str] = []
    confianca_validacao: float

class ProcessarFalaResponse(BaseModel):
    """Response do processamento de fala"""
    id: int = Field(..., description="ID do registro criado")
    dados_extraidos: DadosExtraidos
    validacao: ValidacaoResult
    confianca: float = Field(..., description="Nível de confiança (0.0 a 1.0)")
    sugestoes: List[str] = []
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": 123,
                "dados_extraidos": {
                    "tipo_atividade": "contratacao",
                    "pessoa_envolvida": "Eduardo",
                    "valor_monetario": 3000.0,
                    "talhao": 5
                },
                "validacao": {
                    "valido": True,
                    "alertas": ["Valor alto - confirmar"],
                    "confianca_validacao": 0.8
                },
                "confianca": 0.85
            }
        }

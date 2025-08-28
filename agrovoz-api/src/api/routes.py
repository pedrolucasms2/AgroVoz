from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from src.database.connection import get_db, DatabaseService
from src.nlp.processador import ProcessadorNLPRural
from src.schemas.request_response import ProcessarFalaRequest, ProcessarFalaResponse
from typing import List

router = APIRouter()

# Instância global do processador NLP
nlp_processor = ProcessadorNLPRural()

@router.post("/processar-fala", response_model=ProcessarFalaResponse)
async def processar_fala(
    request: ProcessarFalaRequest, 
    db: Session = Depends(get_db)
):
    """
    Endpoint principal para processar texto de voz
    """
    try:
        # Processar texto com NLP
        resultado_nlp = nlp_processor.processar_texto(
            request.texto, 
            request.usuario_id
        )
        
        # Preparar dados para o banco
        dados_banco = resultado_nlp['dados'].copy()
        dados_banco['precisa_revisao'] = resultado_nlp['confianca'] < 0.7
        
        # Salvar no banco de dados
        db_service = DatabaseService(db)
        registro_id = db_service.criar_registro(dados_banco)
        
        return ProcessarFalaResponse(
            id=registro_id,
            dados_extraidos=resultado_nlp['dados'],
            validacao=resultado_nlp['validacao'],
            confianca=resultado_nlp['confianca'],
            sugestoes=resultado_nlp['sugestoes']
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Erro ao processar fala: {str(e)}"
        )

@router.get("/registros/{usuario_id}")
async def listar_registros(
    usuario_id: str,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """
    Listar registros de um usuário
    """
    try:
        db_service = DatabaseService(db)
        registros = db_service.buscar_registros_usuario(usuario_id, limit)
        
        return {
            "registros": registros,
            "total": len(registros)
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao buscar registros: {str(e)}"
        )

@router.put("/registros/{registro_id}/confirmar")
async def confirmar_registro(
    registro_id: int,
    usuario_id: str,
    db: Session = Depends(get_db)
):
    """
    Confirmar que um registro está correto
    """
    try:
        db_service = DatabaseService(db)
        sucesso = db_service.confirmar_registro(registro_id, usuario_id)
        
        if sucesso:
            return {"message": "Registro confirmado com sucesso"}
        else:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Registro não encontrado"
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao confirmar registro: {str(e)}"
        )

@router.get("/estatisticas/{usuario_id}")
async def obter_estatisticas(
    usuario_id: str,
    db: Session = Depends(get_db)
):
    """
    Obter estatísticas básicas dos registros
    """
    try:
        # Implementar lógica de estatísticas
        # Por ora, retornar placeholder
        return {
            "total_registros": 0,
            "valor_total_gastos": 0.0,
            "atividades_por_tipo": {},
            "periodo": "últimos_30_dias"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erro ao obter estatísticas: {str(e)}"
        )

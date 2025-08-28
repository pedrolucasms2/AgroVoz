from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from src.api.routes import router
from src.database.connection import create_tables
import os

# Criar aplicação FastAPI
app = FastAPI(
    title="AgroVoz API",
    description="API para processamento de comandos de voz rurais",
    version="1.0.0"
)

# Configurar CORS para permitir acesso do app mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especificar domínios
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir rotas da API
app.include_router(router, prefix="/api/v1")

# Endpoint básico de health check
@app.get("/")
async def root():
    return {
        "message": "AgroVoz API está funcionando!",
        "version": "1.0.0",
        "status": "online"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy", "database": "connected"}

# Inicializar tabelas do banco na startup
@app.on_event("startup")
async def startup_event():
    print("Iniciando AgroVoz API...")
    create_tables()
    print("Tabelas criadas/verificadas com sucesso!")

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True)

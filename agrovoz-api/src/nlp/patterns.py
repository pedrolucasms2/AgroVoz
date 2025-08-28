import re

# Padrões regex organizados por categoria
PATTERNS_REGEX = {
    # Pessoas e contratação
    'pessoa_contratacao': re.compile(
        r'(?:contratei|chamei|paguei)\s+(?:o|a|ao|à)?\s*([A-Za-zÀ-ÿ]+)(?:\s+para|\s+que|\s+por)',
        re.IGNORECASE
    ),
    
    'pessoa_geral': re.compile(
        r'(?:com\s+(?:o|a)\s+|pelo\s+|pela\s+)([A-Za-zÀ-ÿ]+)',
        re.IGNORECASE
    ),
    
    # Atividades e verbos
    'atividade_verbo': re.compile(
        r'\b(plantar|plantei|colher|colhi|pulverizar|pulverizei|arar|arei|semear|semeei|aplicar|apliquei|fertilizar|fertilizei)\b',
        re.IGNORECASE
    ),
    
    # Culturas
    'cultura': re.compile(
        r'\b(soja|milho|algodão|feijão|café|cana|cana-de-açúcar|arroz|trigo|sorgo|girassol|amendoim)\b',
        re.IGNORECASE
    ),
    
    # Localização
    'talhao': re.compile(
        r'(?:talhão|talião|área|lote|gleba)\s*(\d+)',
        re.IGNORECASE
    ),
    
    # Valores monetários - padrão mais robusto
    'valor_monetario': re.compile(
        r'(?:por\s+|custou\s+|gastei\s+|paguei\s+|valor\s+de\s+)?(?:R\$\s*)?(\d{1,6}(?:[.,]\d{3})*(?:[.,]\d{2})?)\s*(?:reais?|R\$)',
        re.IGNORECASE
    ),
    
    # Quantidades específicas
    'quantidade_kg': re.compile(
        r'(\d+(?:[.,]\d+)?)\s*(?:kg|quilos?|quilogramas?)',
        re.IGNORECASE
    ),
    
    'quantidade_sacas': re.compile(
        r'(\d+(?:[.,]\d+)?)\s*sacas?',
        re.IGNORECASE
    ),
    
    'quantidade_litros': re.compile(
        r'(\d+(?:[.,]\d+)?)\s*(?:litros?|l)\b',
        re.IGNORECASE
    ),
    
    'quantidade_hectares': re.compile(
        r'(\d+(?:[.,]\d+)?)\s*(?:hectares?|ha|alqueires?)',
        re.IGNORECASE
    ),
    
    # Insumos e materiais
    'insumos': re.compile(
        r'\b(adubo|fertilizante|semente|sementes|defensivo|herbicida|fungicida|inseticida|calcário|ureia|npk|superfosfato)\b',
        re.IGNORECASE
    ),
    
    # Máquinas e equipamentos
    'maquinas': re.compile(
        r'\b(trator|colheitadeira|plantadeira|pulverizador|arado|grade|cultivador)\b',
        re.IGNORECASE
    )
}

# Padrões alternativos para casos específicos
PATTERNS_ALTERNATIVOS = {
    # Formas coloquiais de valores
    'valor_contexto': re.compile(
        r'(?:por|custou|gastei|paguei|valor de)\s+(?:R\$\s*)?(\d{1,6}(?:[.,]\d{3})*(?:[.,]\d{2})?)',
        re.IGNORECASE
    ),
    
    # Tempo/período
    'periodo_tempo': re.compile(
        r'(?:por\s+|durante\s+)?(\d+)\s*(?:dias?|semanas?|meses?|horas?)',
        re.IGNORECASE
    ),
    
    # Área aproximada
    'area_aproximada': re.compile(
        r'(?:cerca\s+de\s+|aproximadamente\s+|uns\s+)?(\d+(?:[.,]\d+)?)\s*(?:hectares?|ha)',
        re.IGNORECASE
    )
}

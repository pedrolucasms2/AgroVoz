import re
import json
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Any
from src.nlp.patterns import PATTERNS_REGEX
from src.nlp.validador import ValidadorDados

class ProcessadorNLPRural:
    """Classe principal para processamento de linguagem natural rural"""
    
    def __init__(self):
        self.patterns = PATTERNS_REGEX
        self.validador = ValidadorDados()
        self.vocabulario = self._carregar_vocabulario_base()
    
    def _carregar_vocabulario_base(self) -> Dict[str, List[str]]:
        """Carrega vocabulário básico do agronegócio"""
        return {
            'culturas': ['soja', 'milho', 'algodão', 'feijão', 'café', 'cana', 'arroz', 'trigo'],
            'atividades_plantio': ['plantar', 'plantei', 'semear', 'semeei'],
            'atividades_colheita': ['colher', 'colhi', 'colhendo'],
            'atividades_pulverizacao': ['pulverizar', 'pulverizei', 'aplicar', 'apliquei'],
            'atividades_preparo': ['arar', 'arei', 'preparar', 'gradear'],
            'unidades_medida': ['kg', 'sacas', 'litros', 'hectares', 'alqueires']
        }
    
    def processar_texto(self, texto: str, usuario_id: str = None) -> Dict[str, Any]:
        """
        Processa um texto e extrai informações estruturadas
        
        Args:
            texto: Texto falado pelo usuário
            usuario_id: ID do usuário (para personalização futura)
            
        Returns:
            Dict com dados extraídos e metadados
        """
        texto_limpo = self._limpar_texto(texto)
        
        # Extrair informações básicas
        dados_extraidos = {
            'usuario_id': usuario_id,
            'descricao_original': texto,
            'tipo_atividade': self._classificar_atividade(texto_limpo),
            'pessoa_envolvida': self._extrair_pessoa(texto_limpo),
            'servico_realizado': self._extrair_servico(texto_limpo),
            'cultura': self._extrair_cultura(texto_limpo),
            'talhao': self._extrair_talhao(texto_limpo),
            'valor_monetario': self._extrair_valor(texto_limpo),
            'data_registro': datetime.now()
        }
        
        # Extrair quantidade e unidade
        quantidade, unidade = self._extrair_quantidade_unidade(texto_limpo)
        dados_extraidos['quantidade'] = quantidade
        dados_extraidos['unidade_medida'] = unidade
        
        # Validar dados extraídos
        validacao = self.validador.validar_dados(dados_extraidos)
        
        return {
            'dados': dados_extraidos,
            'validacao': validacao,
            'confianca': self._calcular_confianca(dados_extraidos),
            'sugestoes': self._gerar_sugestoes(dados_extraidos, texto_limpo)
        }
    
    def _limpar_texto(self, texto: str) -> str:
        """Limpa e normaliza o texto"""
        # Converter para minúsculas
        texto = texto.lower().strip()
        
        # Remover acentos desnecessários para matching
        # (mas manter o texto original para display)
        
        # Normalizar números
        texto = re.sub(r'(\d+)\s*mil', r'\1000', texto)
        texto = re.sub(r'(\d+)\s*e\s*(\d+)', r'\1.\2', texto)
        
        return texto
    
    def _classificar_atividade(self, texto: str) -> str:
        """Classifica o tipo principal da atividade"""
        classificacoes = {
            'contratacao': ['contratei', 'chamei', 'paguei', 'contrato'],
            'compra_insumo': ['comprei', 'adquiri', 'compra'],
            'venda': ['vendi', 'entreguei', 'comercializei'],
            'plantio': ['plantei', 'plantar', 'semeei', 'semear'],
            'colheita': ['colhi', 'colher', 'colhendo'],
            'pulverizacao': ['pulverizei', 'apliquei', 'pulverizar'],
            'preparo_solo': ['arei', 'arar', 'preparei', 'gradear']
        }
        
        for tipo, palavras in classificacoes.items():
            if any(palavra in texto for palavra in palavras):
                return tipo
        
        return 'atividade_geral'
    
    def _extrair_pessoa(self, texto: str) -> Optional[str]:
        """Extrai nome de pessoa"""
        match = re.search(self.patterns['pessoa_contratacao'], texto)
        if match:
            nome = match.group(1).strip().title()
            return nome
        
        # Padrão alternativo
        match = re.search(self.patterns['pessoa_geral'], texto)
        if match:
            return match.group(1).strip().title()
        
        return None
    
    def _extrair_servico(self, texto: str) -> Optional[str]:
        """Extrai tipo de serviço/atividade"""
        match = re.search(self.patterns['atividade_verbo'], texto)
        if match:
            atividade = match.group(1)
            # Normalizar para infinitivo
            normalizacao = {
                'plantei': 'plantar', 'colhi': 'colher', 
                'pulverizei': 'pulverizar', 'arei': 'arar',
                'apliquei': 'aplicar', 'fertilizei': 'fertilizar'
            }
            return normalizacao.get(atividade, atividade)
        return None
    
    def _extrair_cultura(self, texto: str) -> Optional[str]:
        """Extrai tipo de cultura"""
        for cultura in self.vocabulario['culturas']:
            if cultura in texto:
                return cultura.title()
        return None
    
    def _extrair_talhao(self, texto: str) -> Optional[int]:
        """Extrai número do talhão"""
        match = re.search(self.patterns['talhao'], texto)
        if match:
            return int(match.group(1))
        return None
    
    def _extrair_valor(self, texto: str) -> Optional[float]:
        """Extrai valores monetários com contexto específico"""
        
        # Primeiro tentar padrão com "reais"
        match = re.search(self.patterns['valor_monetario'], texto)
        if match:
            valor_str = match.group(1).replace('.', '').replace(',', '.')
            try:
                return float(valor_str)
            except ValueError:
                pass
        
        # Segundo tentar padrão por contexto (por, custou, etc)
        match = re.search(self.patterns['valor_contexto'], texto)
        if match:
            valor_str = match.group(1).replace('.', '').replace(',', '.')
            try:
                return float(valor_str)
            except ValueError:
                pass
        
        # Fallback: buscar números grandes (> 100) após palavras de contexto
        fallback_pattern = r'(?:por|custou|gastei|paguei)\s+.*?(\d{3,})'
        match = re.search(fallback_pattern, texto)
        if match:
            try:
                return float(match.group(1))
            except ValueError:
                pass
        
        return None

    
    def _extrair_quantidade_unidade(self, texto: str) -> Tuple[Optional[float], Optional[str]]:
        """Extrai quantidade e unidade de medida"""
        # Procurar padrões específicos
        padroes_unidade = {
            'kg': self.patterns['quantidade_kg'],
            'sacas': self.patterns['quantidade_sacas'],
            'litros': self.patterns['quantidade_litros'],
            'hectares': self.patterns['quantidade_hectares']
        }
        
        for unidade, padrao in padroes_unidade.items():
            match = re.search(padrao, texto)
            if match:
                try:
                    quantidade = float(match.group(1).replace(',', '.'))
                    return quantidade, unidade
                except ValueError:
                    continue
        
        return None, None
    
    def _calcular_confianca(self, dados: Dict[str, Any]) -> float:
        """Calcula nível de confiança na extração"""
        campos_preenchidos = sum(1 for v in dados.values() if v is not None)
        total_campos = len(dados)
        
        confianca_base = campos_preenchidos / total_campos
        
        # Ajustar baseado em campos críticos
        if dados.get('valor_monetario'):
            confianca_base += 0.1
        if dados.get('pessoa_envolvida'):
            confianca_base += 0.1
        if dados.get('talhao'):
            confianca_base += 0.05
            
        return min(confianca_base, 1.0)
    
    def _gerar_sugestoes(self, dados: Dict[str, Any], texto: str) -> List[str]:
        """Gera sugestões para melhorar a extração"""
        sugestoes = []
        
        if not dados.get('valor_monetario'):
            sugestoes.append("Considere mencionar o valor em reais")
        
        if not dados.get('talhao'):
            sugestoes.append("Especifique o número do talhão")
        
        if dados.get('tipo_atividade') == 'atividade_geral':
            sugestoes.append("Seja mais específico sobre a atividade realizada")
        
        return sugestoes

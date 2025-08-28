from typing import Dict, Any, List
import re

class ValidadorDados:
    """Classe para validar dados extraídos pelo NLP"""
    
    def __init__(self):
        self.culturas_conhecidas = [
            'soja', 'milho', 'algodão', 'feijão', 'café', 'cana', 
            'arroz', 'trigo', 'sorgo', 'girassol'
        ]
        
        self.unidades_validas = [
            'kg', 'sacas', 'litros', 'hectares', 'alqueires', 'unidades'
        ]
    
    def validar_dados(self, dados: Dict[str, Any]) -> Dict[str, Any]:
        """
        Valida todos os dados extraídos
        
        Returns:
            Dict com status de validação, erros e alertas
        """
        validacao = {
            'valido': True,
            'erros': [],
            'alertas': [],
            'sugestoes': [],
            'confianca_validacao': 1.0
        }
        
        # Validar cada campo
        self._validar_pessoa(dados.get('pessoa_envolvida'), validacao)
        self._validar_valor(dados.get('valor_monetario'), validacao)
        self._validar_cultura(dados.get('cultura'), validacao)
        self._validar_talhao(dados.get('talhao'), validacao)
        self._validar_quantidade(dados.get('quantidade'), dados.get('unidade_medida'), validacao)
        
        # Validações cruzadas
        self._validar_consistencia(dados, validacao)
        
        # Calcular confiança final
        validacao['confianca_validacao'] = self._calcular_confianca_validacao(validacao)
        
        return validacao
    
    def _validar_pessoa(self, pessoa: str, validacao: Dict):
        """Valida nome de pessoa"""
        if pessoa:
            # Verificar se é um nome válido (só letras e espaços)
            if not re.match(r'^[A-Za-zÀ-ÿ\s]+$', pessoa):
                validacao['alertas'].append(f"Nome '{pessoa}' contém caracteres suspeitos")
            
            # Verificar comprimento
            if len(pessoa) < 2:
                validacao['alertas'].append("Nome muito curto")
            elif len(pessoa) > 50:
                validacao['alertas'].append("Nome muito longo")
    
    def _validar_valor(self, valor: float, validacao: Dict):
        """Valida valores monetários"""
        if valor is not None:
            if valor <= 0:
                validacao['erros'].append("Valor monetário deve ser positivo")
                validacao['valido'] = False
            elif valor > 100000:  # R$ 100.000
                validacao['alertas'].append(f"Valor R$ {valor:,.2f} é muito alto - confirme")
            elif valor < 10:
                validacao['alertas'].append(f"Valor R$ {valor:.2f} é muito baixo - confirme")
    
    def _validar_cultura(self, cultura: str, validacao: Dict):
        """Valida tipo de cultura"""
        if cultura:
            cultura_lower = cultura.lower()
            if cultura_lower not in self.culturas_conhecidas:
                validacao['alertas'].append(f"Cultura '{cultura}' não é comumente conhecida")
                validacao['sugestoes'].append(f"Culturas comuns: {', '.join(self.culturas_conhecidas)}")
    
    def _validar_talhao(self, talhao: int, validacao: Dict):
        """Valida número do talhão"""
        if talhao is not None:
            if talhao <= 0:
                validacao['erros'].append("Número do talhão deve ser positivo")
                validacao['valido'] = False
            elif talhao > 200:  # Assumindo fazendas com até 200 talhões
                validacao['alertas'].append(f"Talhão {talhao} é um número muito alto")
    
    def _validar_quantidade(self, quantidade: float, unidade: str, validacao: Dict):
        """Valida quantidade e unidade"""
        if quantidade is not None:
            if quantidade <= 0:
                validacao['erros'].append("Quantidade deve ser positiva")
                validacao['valido'] = False
            
            if unidade not in self.unidades_validas:
                validacao['alertas'].append(f"Unidade '{unidade}' não é reconhecida")
            
            # Validações específicas por unidade
            if unidade == 'hectares' and quantidade > 10000:
                validacao['alertas'].append("Área muito grande - confirme")
            elif unidade == 'kg' and quantidade > 50000:
                validacao['alertas'].append("Peso muito alto - confirme")
            elif unidade == 'sacas' and quantidade > 1000:
                validacao['alertas'].append("Muitas sacas - confirme")
    
    def _validar_consistencia(self, dados: Dict[str, Any], validacao: Dict):
        """Validações cruzadas entre campos"""
        tipo_atividade = dados.get('tipo_atividade')
        
        # Se é contratação, deve ter pessoa
        if tipo_atividade == 'contratacao' and not dados.get('pessoa_envolvida'):
            validacao['sugestoes'].append("Para contratação, especifique o nome da pessoa")
        
        # Se tem cultura, deve ter talhão (geralmente)
        if dados.get('cultura') and not dados.get('talhao'):
            validacao['sugestoes'].append("Considere especificar o talhão para a cultura")
        
        # Se é compra/venda, deve ter valor
        if tipo_atividade in ['compra_insumo', 'venda'] and not dados.get('valor_monetario'):
            validacao['sugestoes'].append("Para compra/venda, o valor é importante")
    
    def _calcular_confianca_validacao(self, validacao: Dict) -> float:
        """Calcula confiança baseada nos erros e alertas"""
        confianca = 1.0
        
        # Reduzir por erros
        confianca -= len(validacao['erros']) * 0.3
        
        # Reduzir por alertas
        confianca -= len(validacao['alertas']) * 0.1
        
        return max(confianca, 0.0)

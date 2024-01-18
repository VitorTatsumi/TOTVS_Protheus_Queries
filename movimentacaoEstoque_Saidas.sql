--Relatório de movimentação de estoque - Saídas
--Tabelas utilizadas: SD2/CTT/SF4
--SD2: Itens da NF de saída
--CTT: Centro de custo
--SF4: Tipos de Entrada/Saída

SELECT 
	CTT_DESC01 AS CENTRO_CUSTO, 
	B1_DESC AS PRODUTO, 
	D2_COD AS COD_PRODUTO, 
	SUM(D2_QUANT) AS QTD_VENDA, 
	D2_UM, SUM(D2_VALBRUT) AS VAL_BRUT_TOTAL 
FROM 
	SD2020 AS D2
	INNER JOIN SB1020 AS B1
		ON B1_FILIAL = D2_FILIAL
		AND B1_COD = D2_COD
		AND B1_UM = D2_UM
		AND B1.D_E_L_E_T_ = ''
	INNER JOIN CTT020 AS CTT
		ON CTT_CUSTO = D2_CCUSTO
	INNER JOIN SF4020 AS F4
		ON F4_FILIAL = D2_FILIAL
		--É necessário fazer o relacionamento desse campo para verificar qual a TES da NF
		AND F4_CODIGO = D2_TES
		--Esta flag singnifica se ocorreu ou não a movimentação de estoque. 'S' para SIM e 'N' para NÃO
		AND F4_ESTOQUE = 'S'
WHERE 
	D2_EMISSAO >= '20230101' 
	AND D2_QUANT != ''
	AND D2.D_E_L_E_T_ = '' 
GROUP BY 
	D2_COD, 
	CTT_DESC01, 
	D2_UM, 
	B1_DESC
ORDER BY 
	CTT_DESC01,  
	QTD_VENDA DESC

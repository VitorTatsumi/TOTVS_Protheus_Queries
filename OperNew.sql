--EXEC PRX2_OPERNEW 'vrosa','anascimento','E'

CREATE OR ALTER PROCEDURE [dbo].[PRX2_OPERNEW] (@USR VARCHAR(30), @USRBASE VARCHAR(30), @EXEC VARCHAR(1)) AS


	-- Variáveis do cursor
	DECLARE 
		@FILIAL VARCHAR(2),
		@CODOPER VARCHAR(6),
		@CODOPERBASE VARCHAR(6),
		@NOMEUSRBASE VARCHAR(50),
		@NOME VARCHAR(50),
		@CODUSR VARCHAR(6),
		@CODUSRBASE VARCHAR(6),
		@IMPRESS VARCHAR(6),
		@RECNO VARCHAR(10),
		@CONT INT = 1

	--Verifica a existência do usuário
	IF EXISTS (
		SELECT USR_ID, USR_CODIGO, USR_NOME FROM SYS_USR WHERE LOWER(USR_CODIGO) = LOWER(@USR)
	)
	BEGIN
		--Verifica a existência do usuário base
		IF EXISTS(
			SELECT USR_CODIGO FROM SYS_USR WHERE LOWER(USR_CODIGO) = LOWER(@USRBASE)
		)
		BEGIN
			--Capturando o código de usuário do usuário base
			SELECT TOP 1 @CODUSRBASE = USR_ID, @NOMEUSRBASE = USR_NOME FROM SYS_USR WHERE LOWER(USR_CODIGO) = LOWER(@USRBASE) 

			--Capturando os dados do usuário para inserção na CB1
			SELECT TOP 1 @CODUSR = USR_ID, @NOME = USR_NOME FROM SYS_USR WHERE LOWER(USR_CODIGO) = LOWER(@USR)

			-- Criando um cursor
			DECLARE dadosOper CURSOR
			FOR SELECT CB1_FILIAL, CB1_CODOPE, CB1_NOME, CB1_CODUSR, CB1_IMPRES, R_E_C_N_O_ FROM CB1020 WHERE CB1_CODUSR = @CODUSRBASE;

			-- Abrindo o cursor
			OPEN dadosOper;

			-- Selecionar os dados
			FETCH NEXT FROM dadosOper
			INTO @FILIAL, @CODOPERBASE, @NOME, @CODUSRBASE, @IMPRESS, @RECNO;

			-- Iteração entre os dados retornados pelo cursor
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--Captura a última R_E_C_N_O_ da tabela CB1
				SELECT @RECNO = MAX(R_E_C_N_O_) FROM CB1020

				--Captura o último código de operador de cada filial
				SELECT TOP 1 @CODOPER = CB1_CODOPE FROM CB1020 WHERE CB1_FILIAL = @FILIAL AND CB1_CODOPE < 999990 AND D_E_L_E_T_ = '' ORDER BY R_E_C_N_O_ DESC

				IF @EXEC = 'V'
					BEGIN 
						--Retorno com os dados do usuário base
						SELECT @FILIAL AS FILIAL, @CODOPERBASE AS CODOPERBASE, @NOMEUSRBASE AS NOMEUSRBASE, @CODUSRBASE AS CODUSRBASE, @IMPRESS AS IMPRESSORA, @RECNO AS RECNO;
						--Retorno com os dados do usuário a serem gravados na CB1 com dados reais que irão alimentar a tabela
						SELECT @FILIAL AS FILIAL, REPLICATE('0', 3) + CONVERT(VARCHAR,@CODOPER + 1) AS CODOPERADOR, UPPER(@USR) AS USUARIO, @CODUSR AS CODUSR, @IMPRESS AS IMPRESSORA, @RECNO+@CONT AS RECNO
						SET @CONT = @CONT + 1
					END
				ELSE IF @EXEC = 'E'
					BEGIN
						--Verifica se o registro a ser inserido na CB1 já existe
						IF NOT EXISTS (
							SELECT CB1_FILIAL, CB1_CODOPE, CB1_NOME, CB1_CODUSR, CB1_IMPRES FROM CB1020 WHERE CB1_FILIAL = @FILIAL AND REPLICATE('0', 3) + CONVERT(VARCHAR,@CODOPER) = CB1_CODOPE AND CB1_CODUSR = @CODUSR AND CB1_IMPRES = @IMPRESS AND UPPER(RTRIM(@USR)) = RTRIM(CB1_NOME) AND D_E_L_E_T_ = ''
							--SELECT @FILIAL AS FILIAL, REPLICATE('0', 3) + CONVERT(VARCHAR,@CODOPER + 1) AS CODOPERADOR, UPPER(@USR) AS USUARIO, @CODUSR AS CODUSR, @IMPRESS AS IMPRESSORA, @RECNO+@CONT AS RECNO 
						)
						--Verifica se o código de Operador já existe
						IF NOT EXISTS (
							SELECT CB1_FILIAL, CB1_CODOPE, CB1_NOME, CB1_CODUSR, CB1_IMPRES FROM CB1020 WHERE CB1_FILIAL = @FILIAL AND CB1_CODOPE = @CODOPER+@CONT AND D_E_L_E_T_ = ''
						)
							INSERT INTO CB1020 (CB1_FILIAL, CB1_CODOPE, CB1_NOME, CB1_STATUS, CB1_CODUSR, CB1_INTER, CB1_ACAPSM, CB1_INVPVC, CB1_ALDTHR, CB1_ATVCON, CB1_IMPRES, R_E_C_N_O_, R_E_C_D_E_L_) VALUES (@FILIAL, REPLICATE('0', 3) + CONVERT(VARCHAR,@CODOPER + 1), UPPER(@USR), '1', @CODUSR, '0', '1', '1', '1', '2', @IMPRESS, @RECNO+@CONT, 0)
							--SELECT @FILIAL AS FILIAL, REPLICATE('0', 3) + CONVERT(VARCHAR,@CODOPER + 1) AS CODOPERADOR, UPPER(@USR) AS USUARIO, @CODUSR AS CODUSR, @IMPRESS AS IMPRESSORA, @RECNO+@CONT AS RECNO
							SET @CONT = @CONT + 1

					END 
				ELSE
					PRINT('[ERRO]')

				-- Pegar os próximos dados
				FETCH NEXT FROM dadosOper
				INTO @FILIAL, @CODOPERBASE, @NOME, @CODUSRBASE, @IMPRESS, @RECNO;
			END

			--SELECT @FILIAL, @CODOPER, @NOME, @CODUSR, @IMPRESS;

			-- Fechando e desalocando o cursor da memória
			CLOSE dadosOper;
			DEALLOCATE dadosOper;
		END 
		ELSE
			PRINT('[ERRO_USRBASE] Código de usuário base inválido ou inexistente!')
	END 
	ELSE
		PRINT('[ERRO_USR] Código de usuário inválido ou inexistente!')
GO

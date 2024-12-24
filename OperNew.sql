CREATE OR ALTER PROCEDURE [dbo].[PRX2_OPERNEW] (@USR VARCHAR(30), @USRBASE VARCHAR(30), @EXEC VARCHAR(2)) AS


	-- Variáveis do cursor
	DECLARE 
		--@USR VARCHAR(30) = 'vrosa',
		--@USRBASE VARCHAR(30) = 'anascimento',
		--@EXEC VARCHAR(1) = 'V',
		@FILIAL VARCHAR(2),
		@CODOPER VARCHAR(6),
		@NOMEUSRBASE VARCHAR(50),
		@NOME VARCHAR(50),
		@CODUSR VARCHAR(6),
		@CODUSRBASE VARCHAR(6),
		@IMPRESS VARCHAR(6),
		@RECNO VARCHAR(10)

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
			INTO @FILIAL, @CODOPER, @NOME, @CODUSRBASE, @IMPRESS, @RECNO;

			-- Iteração entre os dados retornados pelo cursor
			WHILE @@FETCH_STATUS = 0
			BEGIN
				
				--Captura a última R_E_C_N_O_ da tabela CB1
				SELECT @RECNO = MAX(R_E_C_N_O_) + 1 FROM CB1020

				--Captura o último código de operador de cada filial
				SELECT TOP 1 @CODOPER = CB1_CODOPE FROM CB1020 WHERE CB1_FILIAL = @FILIAL AND CB1_CODOPE < 999990 ORDER BY R_E_C_N_O_ DESC

				IF @EXEC = 'V'
					BEGIN 
						SELECT @FILIAL AS FILIAL, @CODOPER AS CODOPER, @NOMEUSRBASE AS NOME, @CODUSRBASE AS CODUSR, @IMPRESS AS IMPRESSORA, @RECNO AS RECNO;
						SELECT @FILIAL AS FILIAL, REPLICATE('0', 3) + CONVERT(VARCHAR,@CODOPER + 1) AS CODOPERADOR, UPPER(@USR), @CODUSR, @IMPRESS, @RECNO
					END
				ELSE IF @EXEC = 'E'
					BEGIN

					
						SELECT TOP 10 * FROM CB1020 
						--INSERT INTO CB1020 (CB1_FILIAL, CB1_CODOPE, CB1_NOME, CB1_STATUS, CB1_CODUSR, CB1_INTER, CB1_ACAPSM, CB1_INVPVC, CB1_ALDTHR, CB1_ATVCON, , ADM, NOME) VALUES ('msmartins','mamartins','001456','0','0','Maura Martins')
						SELECT @FILIAL AS FILIAL, REPLICATE('0', 3) + CONVERT(VARCHAR,@CODOPER + 1) AS CODOPERADOR, UPPER(@USR), @CODUSR, @IMPRESS, @RECNO
					END 
				ELSE
					PRINT('[ERRO]')

				-- Pegar os próximos dados
				FETCH NEXT FROM dadosOper
				INTO @FILIAL, @CODOPER, @NOME, @CODUSRBASE, @IMPRESS, @RECNO;
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


go

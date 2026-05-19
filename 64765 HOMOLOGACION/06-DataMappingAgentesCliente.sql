/*
  VERSION     MODIFIEDBY          MODIFIEDDATE    HU            MODIFICATION
  1           Luchin/Patty/Juan   2025-12-19      64765         DataMapping AgentesCliente
  2           Jaime Astudillo     2026-05-19      AC 55188      Filter by date range(FechaCambio)
  */
DECLARE @BatchSize INT = 5000
	,@TotalRecords INT = 0
	,@ErrorCount INT = 0
	,@RowStart INT = 1
	,@RowEnd INT = 0
	,
	-- Rango de fechas a procesar (ajustar antes de cada ejecución)
	@FechaInicio DATETIME = '2024-01-01'
	,@FechaFin DATETIME = '2024-12-31'

-- AgentesCliente.EntityTypeId
IF OBJECT_ID('tempdb..#AgentesClienteUpdate') IS NOT NULL
	DROP TABLE #AgentesClienteUpdate

CREATE TABLE #AgentesClienteUpdate (
	id VARCHAR(16)
	,EntityTypeId VARCHAR(16) NULL
	,Nro INT IDENTITY(1, 1)
	)

-- Índice clúster optimizado para el proceso
CREATE CLUSTERED INDEX IDX_AgentesCliente ON #AgentesClienteUpdate (id)

INSERT INTO #AgentesClienteUpdate (
	id
	,EntityTypeId
	)
SELECT ac.id
	,er.EntityTypeId
FROM AgentesCliente ac WITH (NOLOCK)
CROSS APPLY (
	SELECT TOP 1 er.EntityTypeId
	FROM EntityRelations er WITH (NOLOCK)
	WHERE er.ReferenceId = ac.idCliente
		AND er.SubType IN (
			1
			,2
			,3
			)
	ORDER BY CASE er.SubType
			WHEN 1
				THEN 1
			WHEN 2
				THEN 2
			WHEN 3
				THEN 3
			END
	) er
WHERE ac.EntityTypeId IS NULL
	AND er.EntityTypeId IS NOT NULL
	AND ac.FechaCambio >= @FechaInicio
	AND ac.FechaCambio < DATEADD(DAY, 1, CAST(@FechaFin AS DATE))

SELECT @TotalRecords = @@ROWCOUNT

INSERT INTO administracion_db..DBA_LogDepuracion
SELECT GETDATE()
	,'AgentesCliente'
	,'INICIO ACTUALIZACIÓN Rango ' + CONVERT(VARCHAR(10), @FechaInicio, 120) + ' a ' + CONVERT(VARCHAR(10), @FechaFin, 120)
	,@TotalRecords
	,GETDATE()

WHILE @RowStart <= @TotalRecords
BEGIN
	SELECT @RowEnd = @RowStart + @BatchSize - 1

	BEGIN TRY
		BEGIN TRANSACTION

		-- Usar ROWLOCK para minimizar bloqueos a nivel de tabla
		UPDATE ac
		WITH (ROWLOCK)

		SET ac.EntityTypeId = ISNULL(ac.EntityTypeId, tmp.EntityTypeId)
		FROM #AgentesClienteUpdate tmp WITH (NOLOCK)
		INNER JOIN AgentesCliente ac WITH (ROWLOCK) ON ac.id = tmp.id
		WHERE tmp.Nro BETWEEN @RowStart
				AND @RowEnd

		INSERT INTO administracion_db..DBA_LogDepuracion
		SELECT GETDATE()
			,'AgentesCliente'
			,'Lote ' + CAST(@RowStart AS VARCHAR(8)) + '-' + CAST(@RowEnd AS VARCHAR(8))
			,@@ROWCOUNT
			,GETDATE()

		COMMIT TRANSACTION

		WAITFOR DELAY '00:00:00.100'

		SELECT @RowStart = @RowEnd + 1
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT @ErrorCount = @ErrorCount + 1

		-- Intentar de nuevo con lote más pequeño progresivamente
		IF @BatchSize > 500
		BEGIN
			SELECT @BatchSize = CAST(@BatchSize * 0.8 AS INT)

			PRINT '   -> Reintentando con BatchSize: ' + CAST(@BatchSize AS VARCHAR(10))
		END
		ELSE
		BEGIN
			-- Si el lote es muy pequeño, saltar este rango
			PRINT '   -> BatchSize muy pequeño, saltando'

			SELECT @RowStart = @RowEnd + 1
		END
	END CATCH
END

IF OBJECT_ID('tempdb..#AgentesClienteUpdate') IS NOT NULL
	DROP TABLE #AgentesClienteUpdate

IF @ErrorCount = 0
	PRINT 'Estado: ? COMPLETADO EXITOSAMENTE'
ELSE
	PRINT 'Estado: ? COMPLETADO CON ERRORES'
GO
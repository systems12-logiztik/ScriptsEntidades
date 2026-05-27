/*
  VERSION     MODIFIEDBY          MODIFIEDDATE    HU            MODIFICATION
  1           Luchin/Patty/Juan   2025-12-19      64765         DataMapping GuiasHouse
  2           Jaime Astudillo     2026-05-14      64765         Filter by date range(FechaCreacion)
  */
DECLARE @BatchSize INT = 10000
	,@TotalRecords INT = 0
	,@ErrorCount INT = 0
	,@RowStart INT = 1
	,@RowEnd INT = 0
	,
	-- Rango de fechas: ultimos 6 meses.
	-- Si se requiere homologar mas hacia el pasado, modificar estas fechas y volver a ejecutar el script.
	@FechaInicio DATETIME = DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
	,@FechaFin DATETIME = CAST(GETDATE() AS DATE)

IF OBJECT_ID('tempdb..#GuiasHouseUpdate') IS NOT NULL
	DROP TABLE #GuiasHouseUpdate

CREATE TABLE #GuiasHouseUpdate (
	id UNIQUEIDENTIFIER
	,BilltoConsigneeId VARCHAR(16) NULL
	,ConsigneeId VARCHAR(16) NULL
	,Nro INT IDENTITY(1, 1)
	)

CREATE CLUSTERED INDEX IDX_GuiasHouse ON #GuiasHouseUpdate (id)

INSERT INTO #GuiasHouseUpdate (
	id
	,BilltoConsigneeId
	,ConsigneeId
	)
SELECT gh.id
	,er.Id
	,er.ChildEntityTypeId
FROM GuiasHouse gh WITH (NOLOCK)
LEFT JOIN EntityRelations er WITH (NOLOCK) ON er.ReferenceId = gh.idCliente
WHERE er.id IS NOT NULL
	AND (
		gh.BilltoConsigneeId IS NULL
		OR gh.ConsigneeId IS NULL
		)
	AND gh.FechaCreacion >= @FechaInicio
	AND gh.FechaCreacion < DATEADD(DAY, 1, CAST(@FechaFin AS DATE))

SELECT @TotalRecords = @@ROWCOUNT

INSERT INTO administracion_db..DBA_LogDepuracion
SELECT GETDATE()
	,'GuiasHouse'
		,'INICIO ACTUALIZACION Rango ' + CONVERT(VARCHAR(10), @FechaInicio, 120) + ' a ' + CONVERT(VARCHAR(10), @FechaFin, 120)
	,@TotalRecords
	,GETDATE()

WHILE @RowStart <= @TotalRecords
BEGIN
	SELECT @RowEnd = @RowStart + @BatchSize - 1

	BEGIN TRY
		BEGIN TRANSACTION

		UPDATE gh
		WITH (ROWLOCK)

		SET gh.BilltoConsigneeId = ISNULL(gh.BilltoConsigneeId, tmp.BilltoConsigneeId)
			,gh.ConsigneeId = ISNULL(gh.ConsigneeId, tmp.ConsigneeId)
		FROM #GuiasHouseUpdate tmp WITH (NOLOCK)
		INNER JOIN GuiasHouse gh WITH (ROWLOCK) ON gh.id = tmp.id
		WHERE tmp.Nro BETWEEN @RowStart
				AND @RowEnd

		INSERT INTO administracion_db..DBA_LogDepuracion
		SELECT GETDATE()
			,'GuiasHouse'
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

		IF @BatchSize > 500
		BEGIN
			SELECT @BatchSize = CAST(@BatchSize * 0.8 AS INT)

			PRINT '   -> Reintentando con BatchSize: ' + CAST(@BatchSize AS VARCHAR(10))
		END
		ELSE
		BEGIN
			PRINT '   -> BatchSize muy pequeno, saltando'

			SELECT @RowStart = @RowEnd + 1
		END
	END CATCH
END

IF OBJECT_ID('tempdb..#GuiasHouseUpdate') IS NOT NULL
	DROP TABLE #GuiasHouseUpdate

IF @ErrorCount = 0
	PRINT 'Estado: COMPLETADO EXITOSAMENTE'
ELSE
	PRINT 'Estado: COMPLETADO CON ERRORES'
GO

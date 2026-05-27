/*
  VERSION     MODIFIEDBY          MODIFIEDDATE    HU            MODIFICATION
  1           Luis Campos         2026-05-21      64765         DataMapping CodigosRelacionSistemas
  */
DECLARE @BatchSize INT = 10000,
	@TotalRecords INT = 0,
	@ErrorCount INT = 0,
	@RowStart INT = 1,
	@RowEnd INT = 0,
	-- Rango de fechas: ultimos 6 meses.
	-- Si se requiere homologar mas hacia el pasado, modificar estas fechas y volver a ejecutar el script.
	@FechaInicio DATETIME = DATEADD(MONTH, -6, CAST(GETDATE() AS DATE)),
	@FechaFin DATETIME = CAST(GETDATE() AS DATE)

IF OBJECT_ID('tempdb..#TMP_CodigosRelacionSistemasUpdate') IS NOT NULL
	DROP TABLE #TMP_CodigosRelacionSistemasUpdate

CREATE TABLE #TMP_CodigosRelacionSistemasUpdate (
	id VARCHAR(36),
	EntityRelationId VARCHAR(16) NULL,
	Nro INT IDENTITY(1, 1)
	)

CREATE CLUSTERED INDEX idx_TMP_CodigosRelacionSistemasUpdate_id ON #TMP_CodigosRelacionSistemasUpdate (id)

INSERT INTO #TMP_CodigosRelacionSistemasUpdate (
	id,
	EntityRelationId
	)
SELECT
	crs.id,
	er.Id
FROM CodigosRelacionSistemas crs WITH (NOLOCK)
INNER JOIN EntityRelations er WITH (NOLOCK) ON er.ReferenceId = crs.idEntidad
INNER JOIN EntityTypes et WITH (NOLOCK) ON et.Id = er.EntityTypeId
	AND et.EntityType = 1 -- solo Bill-to
WHERE crs.EntityRelationId IS NULL
	AND crs.FechaCambio >= @FechaInicio
	AND crs.FechaCambio < DATEADD(DAY, 1, CAST(@FechaFin AS DATE))
	AND crs.tipoEntidad = 'CLIENTE'

SELECT @TotalRecords = @@ROWCOUNT

INSERT INTO administracion_db..DBA_LogDepuracion
SELECT
	GETDATE(),
	'CodigosRelacionSistemas',
	'INICIO ACTUALIZACION Rango ' + CONVERT(VARCHAR(10), @FechaInicio, 120) + ' a ' + CONVERT(VARCHAR(10), @FechaFin, 120),
	@TotalRecords,
	GETDATE()

WHILE @RowStart <= @TotalRecords
BEGIN
	SELECT @RowEnd = @RowStart + @BatchSize - 1

	BEGIN TRY
		BEGIN TRANSACTION

		UPDATE crs
		WITH (ROWLOCK)
		SET
			crs.EntityRelationId = ISNULL(crs.EntityRelationId, tmp.EntityRelationId),
			crs.tipoEntidad = 'CLIENTE'
		FROM #TMP_CodigosRelacionSistemasUpdate tmp WITH (NOLOCK)
		INNER JOIN CodigosRelacionSistemas crs WITH (ROWLOCK) ON crs.id = tmp.id
		WHERE tmp.Nro BETWEEN @RowStart AND @RowEnd

		INSERT INTO administracion_db..DBA_LogDepuracion
		SELECT
			GETDATE(),
			'CodigosRelacionSistemas',
			'Lote ' + CAST(@RowStart AS VARCHAR(8)) + '-' + CAST(@RowEnd AS VARCHAR(8)),
			@@ROWCOUNT,
			GETDATE()

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

IF OBJECT_ID('tempdb..#TMP_CodigosRelacionSistemasUpdate') IS NOT NULL
	DROP TABLE #TMP_CodigosRelacionSistemasUpdate

IF @ErrorCount = 0
	PRINT 'Estado: COMPLETADO EXITOSAMENTE'
ELSE
	PRINT 'Estado: COMPLETADO CON ERRORES'
GO

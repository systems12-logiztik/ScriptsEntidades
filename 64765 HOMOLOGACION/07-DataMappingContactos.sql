/*
  VERSION     MODIFIEDBY          MODIFIEDDATE    HU            MODIFICATION
  3           Luis Campos         2026-04-21      TBD           DataMapping ContactoEmpresas - Sin captura de IDs
  4           Jaime Astudillo     2026-05-15      AC 55188      Fix Bill-to mapping: use er.EntityTypeId (not ChildEntityTypeId), join on ce.idEntidad, filter EntityType='1', dedup by idEmpresa+EntityTypeId+idContacto */
  -- Limpiar cualquier transacción pendiente
  IF @@TRANCOUNT > 0
      ROLLBACK TRANSACTION

  SET XACT_ABORT OFF
  SET IMPLICIT_TRANSACTIONS OFF
  SET NOCOUNT ON

  DECLARE @TotalRecordsInserted INT = 0
      ,@ErrorCount INT = 0
      ,@StartTime DATETIME = GETDATE()

  PRINT '========================================='
  PRINT 'DataMapping ContactoEmpresas v5'
  PRINT '========================================='
  PRINT 'Inicio: ' + CONVERT(VARCHAR(20), @StartTime, 120)

  -- ========================================
  -- PASO 1: Extraer datos de origen (dedup por email dentro del Bill-to)
  -- ========================================
  PRINT ''
  PRINT '--- PASO 1: Extrayendo datos de origen ---'

  IF OBJECT_ID('tempdb..#DataToInsert') IS NOT NULL
  BEGIN
      DROP TABLE #DataToInsert
  END

  CREATE TABLE #DataToInsert (
      idEmpresa VARCHAR(16)
      ,idEntidad VARCHAR(16)
      ,idContacto VARCHAR(16)
      ,idUsuarioLog VARCHAR(16)
      ,Seq INT IDENTITY(1, 1)
      )

  -- Preparar todos los datos
  ;WITH Candidates AS (
      SELECT
          ce.idEmpresa,
          er.EntityTypeId,
          ce.idContacto,
          c.Email,
          ROW_NUMBER() OVER (
              PARTITION BY
                  ce.idEmpresa,
                  er.EntityTypeId,
                  COALESCE(NULLIF(LTRIM(RTRIM(LOWER(c.Email))), ''),
  ce.idContacto)
              ORDER BY ce.idContacto
          ) AS rn
      FROM ContactoEmpresas ce WITH (NOLOCK)
      INNER JOIN Contactos c WITH (NOLOCK)
          ON c.id = ce.idContacto
      INNER JOIN EntityRelations er WITH (NOLOCK)
          ON er.ReferenceId = ce.idEntidad
      INNER JOIN EntityTypes et WITH (NOLOCK)
          ON et.Id = er.EntityTypeId
          AND et.EntityType = '1'
      LEFT JOIN ContactoEmpresas ce2 WITH (NOLOCK)
          ON ce2.idEntidad = er.EntityTypeId
          AND ce2.idEmpresa = ce.idEmpresa
          AND ce2.idContacto = ce.idContacto
      WHERE ce.status = 'ACTIVO'
          AND ce2.id IS NULL
  )
INSERT INTO #DataToInsert (idEmpresa, idEntidad, idContacto,
  idUsuarioLog)
  SELECT 
      idEmpresa,
      EntityTypeId,
      idContacto,
      'yUJoJlBG'
  FROM Candidates
  WHERE rn = 1;

  DECLARE @TotalRecords INT = @@ROWCOUNT

  PRINT 'Registros extraídos: ' + CAST(@TotalRecords AS VARCHAR(10))

  IF @TotalRecords = 0
  BEGIN
      PRINT 'No hay registros para insertar'
  END
  ELSE
  BEGIN
	-- ========================================
	-- PASO 2: Generar IDs masivos (capturando tabla del SP)
	-- ========================================
	PRINT ''
	PRINT '--- PASO 2: Generando IDs masivos ---'

	IF OBJECT_ID('tempdb..#AllIds') IS NOT NULL
	BEGIN
		DROP TABLE #AllIds
	END

	CREATE TABLE #AllIds (
		idEmpresa VARCHAR(16)
		,id INT
		,unificado VARCHAR(16)
		)

	-- Generar IDs para cada empresa y almacenar en tabla
	BEGIN TRY
		DECLARE @Emp011Count INT = (
				SELECT COUNT(*)
				FROM #DataToInsert
				WHERE idEmpresa = 'EMP011'
				)

		IF @Emp011Count > 0
		BEGIN
			CREATE TABLE #Temp011 (
				id INT
				,unificado VARCHAR(16)
				)

			INSERT INTO #Temp011
			EXEC dbo.pro_GeneralGenerarIdUnicoMasivo @tabla = 'ContactoEmpresas'
				,@cantidad = @Emp011Count
				,@idEmpresa = 'EMP011'

			INSERT INTO #AllIds (
				idEmpresa
				,id
				,unificado
				)
			SELECT 'EMP011'
				,id
				,unificado
			FROM #Temp011

			DROP TABLE #Temp011

			PRINT '  ✓ EMP011: ' + CAST(@Emp011Count AS VARCHAR(10)) + ' IDs generados'
		END
	END TRY

	BEGIN CATCH
		PRINT '  ✗ ERROR EMP011: ' + ERROR_MESSAGE()

		SELECT @ErrorCount = @ErrorCount + 1
	END CATCH;

	BEGIN TRY
		DECLARE @Emp012Count INT = (
				SELECT COUNT(*)
				FROM #DataToInsert
				WHERE idEmpresa = 'EMP012'
				)

		IF @Emp012Count > 0
		BEGIN
			CREATE TABLE #Temp012 (
				id INT
				,unificado VARCHAR(16)
				)

			INSERT INTO #Temp012
			EXEC dbo.pro_GeneralGenerarIdUnicoMasivo @tabla = 'ContactoEmpresas'
				,@cantidad = @Emp012Count
				,@idEmpresa = 'EMP012'

			INSERT INTO #AllIds (
				idEmpresa
				,id
				,unificado
				)
			SELECT 'EMP012'
				,id
				,unificado
			FROM #Temp012

			DROP TABLE #Temp012

			PRINT '  ✓ EMP012: ' + CAST(@Emp012Count AS VARCHAR(10)) + ' IDs generados'
		END
	END TRY

	BEGIN CATCH
		PRINT '  ✗ ERROR EMP012: ' + ERROR_MESSAGE()

		SELECT @ErrorCount = @ErrorCount + 1
	END CATCH;

	BEGIN TRY
		DECLARE @Emp013Count INT = (
				SELECT COUNT(*)
				FROM #DataToInsert
				WHERE idEmpresa = 'EMP013'
				)

		IF @Emp013Count > 0
		BEGIN
			CREATE TABLE #Temp013 (
				id INT
				,unificado VARCHAR(16)
				)

			INSERT INTO #Temp013
			EXEC dbo.pro_GeneralGenerarIdUnicoMasivo @tabla = 'ContactoEmpresas'
				,@cantidad = @Emp013Count
				,@idEmpresa = 'EMP013'

			INSERT INTO #AllIds (
				idEmpresa
				,id
				,unificado
				)
			SELECT 'EMP013'
				,id
				,unificado
			FROM #Temp013

			DROP TABLE #Temp013

			PRINT '  ✓ EMP013: ' + CAST(@Emp013Count AS VARCHAR(10)) + ' IDs generados'
		END
	END TRY

	BEGIN CATCH
		PRINT '  ✗ ERROR EMP013: ' + ERROR_MESSAGE()

		SELECT @ErrorCount = @ErrorCount + 1
	END CATCH;

	BEGIN TRY
		DECLARE @Emp014Count INT = (
				SELECT COUNT(*)
				FROM #DataToInsert
				WHERE idEmpresa = 'EMP014'
				)

		IF @Emp014Count > 0
		BEGIN
			CREATE TABLE #Temp014 (
				id INT
				,unificado VARCHAR(16)
				)

			INSERT INTO #Temp014
			EXEC dbo.pro_GeneralGenerarIdUnicoMasivo @tabla = 'ContactoEmpresas'
				,@cantidad = @Emp014Count
				,@idEmpresa = 'EMP014'

			INSERT INTO #AllIds (
				idEmpresa
				,id
				,unificado
				)
			SELECT 'EMP014'
				,id
				,unificado
			FROM #Temp014

			DROP TABLE #Temp014

			PRINT '  ✓ EMP014: ' + CAST(@Emp014Count AS VARCHAR(10)) + ' IDs generados'
		END
	END TRY

	BEGIN CATCH
		PRINT '  ✗ ERROR EMP014: ' + ERROR_MESSAGE()

		SELECT @ErrorCount = @ErrorCount + 1
	END CATCH;

	BEGIN TRY
		DECLARE @Emp016Count INT = (
				SELECT COUNT(*)
				FROM #DataToInsert
				WHERE idEmpresa = 'EMP016'
				)

		IF @Emp016Count > 0
		BEGIN
			CREATE TABLE #Temp016 (
				id INT
				,unificado VARCHAR(16)
				)

			INSERT INTO #Temp016
			EXEC dbo.pro_GeneralGenerarIdUnicoMasivo @tabla = 'ContactoEmpresas'
				,@cantidad = @Emp016Count
				,@idEmpresa = 'EMP016'

			INSERT INTO #AllIds (
				idEmpresa
				,id
				,unificado
				)
			SELECT 'EMP016'
				,id
				,unificado
			FROM #Temp016

			DROP TABLE #Temp016

			PRINT '  ✓ EMP016: ' + CAST(@Emp016Count AS VARCHAR(10)) + ' IDs generados'
		END
	END TRY

	BEGIN CATCH
		PRINT '  ✗ ERROR EMP016: ' + ERROR_MESSAGE()

		SELECT @ErrorCount = @ErrorCount + 1
	END CATCH;

	BEGIN TRY
		DECLARE @Emp017Count INT = (
				SELECT COUNT(*)
				FROM #DataToInsert
				WHERE idEmpresa = 'EMP017'
				)

		IF @Emp017Count > 0
		BEGIN
			CREATE TABLE #Temp017 (
				id INT
				,unificado VARCHAR(16)
				)

			INSERT INTO #Temp017
			EXEC dbo.pro_GeneralGenerarIdUnicoMasivo @tabla = 'ContactoEmpresas'
				,@cantidad = @Emp017Count
				,@idEmpresa = 'EMP017'

			INSERT INTO #AllIds (
				idEmpresa
				,id
				,unificado
				)
			SELECT 'EMP017'
				,id
				,unificado
			FROM #Temp017

			DROP TABLE #Temp017

			PRINT '  ✓ EMP017: ' + CAST(@Emp017Count AS VARCHAR(10)) + ' IDs generados'
		END
	END TRY

	BEGIN CATCH
		PRINT '  ✗ ERROR EMP017: ' + ERROR_MESSAGE()

		SELECT @ErrorCount = @ErrorCount + 1
	END CATCH;

	DECLARE @IdsCount INT = (
			SELECT COUNT(*)
			FROM #AllIds
			)

	PRINT 'Total IDs generados: ' + CAST(@IdsCount AS VARCHAR(10))
	-- ========================================
	-- PASO 3: Insertar registros con IDs
	-- ========================================
	PRINT ''
	PRINT '--- PASO 3: Insertando en ContactoEmpresas con IDs ---'

	BEGIN TRY
		INSERT INTO ContactoEmpresas (
			id
			,idEmpresa
			,idEntidad
			,idContacto
			,idUsuarioLog
			,nota
			,STATUS
			,fechaCambio
			)
		SELECT ai.unificado
			,dt.idEmpresa
			,dt.idEntidad
			,dt.idContacto
			,dt.idUsuarioLog
			,'datamapping'
			,'ACTIVO'
			,GETDATE()
		FROM #DataToInsert dt
		INNER JOIN #AllIds ai ON dt.Seq = ai.id
			AND dt.idEmpresa = ai.idEmpresa

		SELECT @TotalRecordsInserted = @@ROWCOUNT

		PRINT 'ContactoEmpresas: ' + CAST(@TotalRecordsInserted AS VARCHAR(10)) + ' registros insertados'
	END TRY

	BEGIN CATCH
		SELECT @ErrorCount = @ErrorCount + 1

		PRINT 'ERROR insertando: ' + ERROR_MESSAGE()
	END CATCH

	IF OBJECT_ID('tempdb..#AllIds') IS NOT NULL
	BEGIN
		DROP TABLE #AllIds
	END
END

-- ========================================
-- RESUMEN FINAL
-- ========================================
PRINT ''
PRINT '========================================='
PRINT 'RESUMEN FINAL'
PRINT '========================================='
PRINT 'Registros insertados: ' + CAST(@TotalRecordsInserted AS VARCHAR(10))
PRINT 'Errores: ' + CAST(@ErrorCount AS VARCHAR(10))
PRINT 'Duracion: ' + CONVERT(VARCHAR(10), DATEDIFF(SECOND, @StartTime, GETDATE())) + ' segundos'

IF @ErrorCount = 0
	AND @TotalRecordsInserted > 0
	PRINT 'Estado: ✓ COMPLETADO EXITOSAMENTE'
ELSE
	PRINT 'Estado: ⚠ COMPLETADO CON ERRORES O SIN REGISTROS'

-- Limpiar tablas temporales
IF OBJECT_ID('tempdb..#DataToInsert') IS NOT NULL
BEGIN
	DROP TABLE #DataToInsert
END
GO

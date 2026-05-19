 /*
  VERSION     MODIFIEDBY          MODIFIEDDATE    HU            MODIFICATION
  1           Luis Campos         2026-04-20      AC 55188      DataMapping Guias (similar to
  GuiasHouse)
  2           Jaime Astudillo     2026-05-18      AC 55188      Filter only Bill-to entities
  (EntityType='1') + filter range to date (FechaEmbarque)
  */
  DECLARE
      @BatchSize INT = 10000,
      @TotalRecords INT = 0,
      @ErrorCount INT = 0,
      @RowStart INT = 1,
      @RowEnd INT = 0,
      -- Rango de fechas a procesar (ajustar antes de cada ejecución)
      @FechaInicio DATETIME = '2024-01-01',
      @FechaFin    DATETIME = '2024-12-31'

  IF OBJECT_ID('tempdb..#GuiasUpdate') IS NOT NULL DROP TABLE #GuiasUpdate

  CREATE TABLE #GuiasUpdate (
      id VARCHAR(36),
      BilltoConsigneeId VARCHAR(16) NULL,
      Nro INT IDENTITY(1,1)
  )

  CREATE CLUSTERED INDEX IDX_Guias ON #GuiasUpdate (id)

  INSERT INTO #GuiasUpdate (id, BilltoConsigneeId)
  SELECT
      g.id,
      er.Id
  FROM Guias g WITH (NOLOCK)
  INNER JOIN EntityRelations er WITH (NOLOCK)
      ON er.ReferenceId = g.idCliente
  INNER JOIN EntityTypes et WITH (NOLOCK)
      ON et.Id = er.EntityTypeId
      AND et.EntityType = '1'                       -- solo Bill-to
  WHERE g.BilltoConsigneeId IS NULL
    AND g.FechaEmbarque >= @FechaInicio
    AND g.FechaEmbarque <  DATEADD(DAY, 1, CAST(@FechaFin AS DATE))

  SELECT @TotalRecords = @@ROWCOUNT

  INSERT INTO administracion_db..DBA_LogDepuracion
  SELECT GETDATE(),'Guias',
         'INICIO ACTUALIZACIÓN Rango '
          + CONVERT(VARCHAR(10), @FechaInicio, 120) + ' a '
          + CONVERT(VARCHAR(10), @FechaFin, 120),
         @TotalRecords, GETDATE()

  WHILE @RowStart <= @TotalRecords
  BEGIN
      SELECT @RowEnd = @RowStart + @BatchSize - 1

      BEGIN TRY
          BEGIN TRANSACTION

          UPDATE g WITH (ROWLOCK)
          SET g.BilltoConsigneeId = ISNULL(g.BilltoConsigneeId, tmp.BilltoConsigneeId)
          FROM #GuiasUpdate tmp WITH (NOLOCK)
          INNER JOIN Guias g WITH (ROWLOCK) ON g.id = tmp.id
          WHERE tmp.Nro BETWEEN @RowStart AND @RowEnd

          INSERT INTO administracion_db..DBA_LogDepuracion
          SELECT GETDATE(),'Guias','Lote ' + CAST(@RowStart AS VARCHAR(8)) + '-' +
  CAST(@RowEnd AS VARCHAR(8)),@@ROWCOUNT,GETDATE()

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
              PRINT '   -> BatchSize muy pequeño, saltando'
              SELECT @RowStart = @RowEnd + 1
          END
      END CATCH
  END

  IF @ErrorCount = 0
      PRINT 'Estado: ✓ COMPLETADO EXITOSAMENTE'
  ELSE
      PRINT 'Estado: ⚠ COMPLETADO CON ERRORES'

  IF OBJECT_ID('tempdb..#GuiasUpdate') IS NOT NULL DROP TABLE #GuiasUpdate

  GO
      PRINT 'Estado: ⚠ COMPLETADO CON ERRORES'

  IF OBJECT_ID('tempdb..#GuiasUpdate') IS NOT NULL DROP TABLE #GuiasUpdate

  GO
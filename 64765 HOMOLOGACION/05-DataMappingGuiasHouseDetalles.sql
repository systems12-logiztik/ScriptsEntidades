/*
VERSION     MODIFIEDBY          MODIFIEDDATE    HU      MODIFICATION
1           Luchin/Patty/Juan   2025-12-19      53095   DataMapping GuiasHouseDetalles
*/
DECLARE 
@BatchSize INT = 10000,
@TotalRecords INT = 0,    
@RowStart INT = 1,
@RowEnd INT = 0,
@ErrorCount INT = 0

IF OBJECT_ID('tempdb..#GuiasHouseDetallesUpdate') IS NOT NULL DROP TABLE #GuiasHouseDetallesUpdate

CREATE TABLE #GuiasHouseDetallesUpdate (
    id UNIQUEIDENTIFIER,
    BilltoConsigneeId VARCHAR(16) NULL,
    ShipToId VARCHAR(16) NULL,
    Nro INT IDENTITY(1,1)
)

CREATE CLUSTERED INDEX IDX_GuiasHouseDetalle ON #GuiasHouseDetallesUpdate (id)

INSERT INTO #GuiasHouseDetallesUpdate (id, BilltoConsigneeId, ShipToId)
SELECT 
    ghd.id,
    erf.id,
    erf.ChildEntityTypeId
FROM GuiasHouseDetalles ghd WITH (NOLOCK)
LEFT JOIN EntityRelations erf WITH (NOLOCK) ON erf.ReferenceId = ghd.idClienteFinal
WHERE
erf.id IS NOT NULL
AND (ghd.BilltoConsigneeId IS NULL OR ghd.ShipToId IS NULL) -- Solo procesar si alguno es NULL

SELECT @TotalRecords = @@ROWCOUNT

INSERT INTO administracion_db..DBA_LogDepuracion
SELECT GETDATE(),'GuiasHouseDetalles','INICIO ACTUALIZACIÓN',@TotalRecords,GETDATE()

WHILE @RowStart <= @TotalRecords
BEGIN
    SELECT @RowEnd = @RowStart + @BatchSize - 1
    
    BEGIN TRY
        BEGIN TRANSACTION
        
  UPDATE ghd WITH (ROWLOCK)
  SET ghd.BilltoConsigneeId = ISNULL(ghd.BilltoConsigneeId, tmp.BilltoConsigneeId),
            ghd.ShipToId = ISNULL(ghd.ShipToId, tmp.ShipToId)  
  FROM #GuiasHouseDetallesUpdate tmp WITH (NOLOCK)
  INNER JOIN GuiasHouseDetalles ghd WITH (ROWLOCK) ON ghd.id = tmp.id 
        WHERE tmp.Nro BETWEEN @RowStart AND @RowEnd
        
        INSERT INTO administracion_db..DBA_LogDepuracion
  SELECT GETDATE(),'GuiasHouseDetalles','Lote ' + CAST(@RowStart AS VARCHAR(8)) + '-' + CAST(@RowEnd AS VARCHAR(8)),@@ROWCOUNT,GETDATE()
        
        COMMIT TRANSACTION

        WAITFOR DELAY '00:00:00.100'
        
        SELECT @RowStart = @RowEnd + 1
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SELECT @ErrorCount = @ErrorCount + 1
        
  -- Intentar de nuevo con lote m�s peque�o progresivamente
        IF @BatchSize > 500
        BEGIN
            SELECT @BatchSize = CAST(@BatchSize * 0.8 AS INT)
            PRINT '   -> Reintentando con BatchSize: ' + CAST(@BatchSize AS VARCHAR(10))
        END
        ELSE
        BEGIN
            -- Si el lote es muy peque�o, saltar este rango
            PRINT '   -> BatchSize muy peque�o, saltando'
            SELECT @RowStart = @RowEnd + 1
        END
    END CATCH
END

IF @ErrorCount = 0
    PRINT 'Estado: ? COMPLETADO EXITOSAMENTE'
ELSE
    PRINT 'Estado: ? COMPLETADO CON ERRORES'

GO
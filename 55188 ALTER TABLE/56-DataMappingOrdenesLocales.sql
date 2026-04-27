/*
VERSION     MODIFIEDBY          MODIFIEDDATE    HU      MODIFICATION
1           Luchin/Patty/Juan   2025-12-19      53095   DataMapping OrdenesLocales
*/
DECLARE 
@BatchSize INT = 10000,
@TotalRecords INT = 0,    
@ErrorCount INT = 0,
@RowStart INT = 1,
@RowEnd INT = 0

-- OrdenesLocales.BilltoConsigneeId y ConsigneeId
IF OBJECT_ID('tempdb..#OrdenesLocalesUpdate') IS NOT NULL DROP TABLE #OrdenesLocalesUpdate

CREATE TABLE #OrdenesLocalesUpdate (
    id UNIQUEIDENTIFIER,
    BilltoConsigneeId VARCHAR(16) NULL,
    ConsigneeId VARCHAR(16) NULL,
    Nro INT IDENTITY(1,1)
)

CREATE CLUSTERED INDEX IDX_OrdenesLocales ON #OrdenesLocalesUpdate (id)

INSERT INTO #OrdenesLocalesUpdate (id, BilltoConsigneeId, ConsigneeId)
SELECT 
    ol.id,
    er.Id,
    er.ChildEntityTypeId
FROM OrdenesLocales ol WITH (NOLOCK)
LEFT JOIN EntityRelations er WITH (NOLOCK) ON er.ReferenceId = ol.idCliente
WHERE er.id IS NOT NULL
AND (ol.BilltoConsigneeId IS NULL OR ol.ConsigneeId IS NULL) -- Solo procesar si alguno es NULL

SELECT @TotalRecords = @@ROWCOUNT

INSERT INTO administracion_db..DBA_LogDepuracion
SELECT GETDATE(),'OrdenesLocales','INICIO ACTUALIZACIÓN',@TotalRecords,GETDATE()

WHILE @RowStart <= @TotalRecords
BEGIN
    SELECT @RowEnd = @RowStart + @BatchSize - 1
    
    BEGIN TRY
        BEGIN TRANSACTION
        
		UPDATE ol WITH (ROWLOCK)
		SET ol.BilltoConsigneeId = ISNULL(ol.BilltoConsigneeId, tmp.BilltoConsigneeId),
		    ol.ConsigneeId = ISNULL(ol.ConsigneeId, tmp.ConsigneeId)    		
		FROM #OrdenesLocalesUpdate tmp WITH (NOLOCK)
		INNER JOIN OrdenesLocales ol WITH (ROWLOCK) ON ol.id = tmp.id 
            WHERE tmp.Nro BETWEEN @RowStart AND @RowEnd
        
		INSERT INTO administracion_db..DBA_LogDepuracion
		SELECT GETDATE(),'OrdenesLocales','Lote ' + CAST(@RowStart AS VARCHAR(8)) + '-' + CAST(@RowEnd AS VARCHAR(8)),@@ROWCOUNT,GETDATE()
        
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

IF OBJECT_ID('tempdb..#OrdenesLocalesUpdate') IS NOT NULL DROP TABLE #OrdenesLocalesUpdate

IF @ErrorCount = 0
    PRINT 'Estado: ✓ COMPLETADO EXITOSAMENTE'
ELSE
    PRINT 'Estado: ⚠ COMPLETADO CON ERRORES'

GO

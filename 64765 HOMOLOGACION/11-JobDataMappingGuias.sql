/*
VERSION     MODIFIEDBY          MODIFIEDDATE    HU      MODIFICATION
1           Luis Campos         2026-05-14      64765   DataMapping Guias por Status (RESERVADO)
*/
DECLARE 
    @BatchSize INT = 5000,
    @TotalRecords INT = 0,    
    @ErrorCount INT = 0,
    @RowStart INT = 1,
    @RowEnd INT = 0

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
LEFT JOIN EntityRelations er WITH (NOLOCK) ON er.ReferenceId = g.idCliente
WHERE er.id IS NOT NULL
AND g.Status = 'RESERVADO' -- Filtrar solo por estos estatus

SELECT @TotalRecords = @@ROWCOUNT

INSERT INTO administracion_db..DBA_LogDepuracion
SELECT GETDATE(),'Guias','INICIO ACTUALIZACION (RESERVADO)',@TotalRecords,GETDATE()

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
        SELECT GETDATE(),'Guias','Lote ' + CAST(@RowStart AS VARCHAR(8)) + '-' + CAST(@RowEnd AS VARCHAR(8)),@@ROWCOUNT,GETDATE()

        COMMIT TRANSACTION

        WAITFOR DELAY '00:00:00.100'
        
        SELECT @RowStart = @RowEnd + 1
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SELECT @ErrorCount = @ErrorCount + 1
        
        -- Intentar de nuevo con lote mas pequeno progresivamente
        IF @BatchSize > 500
        BEGIN
            SELECT @BatchSize = CAST(@BatchSize * 0.8 AS INT)
            PRINT '   -> Reintentando con BatchSize: ' + CAST(@BatchSize AS VARCHAR(10))
        END
        ELSE
        BEGIN
            -- Si el lote es muy pequeno, saltar este rango
            PRINT '   -> BatchSize muy pequeno, saltando'
            SELECT @RowStart = @RowEnd + 1
        END
    END CATCH
END

IF @ErrorCount = 0
    PRINT 'Estado: COMPLETADO EXITOSAMENTE'
ELSE
    PRINT 'Estado: COMPLETADO CON ERRORES'

-- Limpiar tabla temporal
IF OBJECT_ID('tempdb..#GuiasUpdate') IS NOT NULL DROP TABLE #GuiasUpdate

GO

/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos			2026-05-19		AC 55188	DataMapping ContactoEmpresas for Entities
*/
DECLARE
    @TotalRecordsInserted INT = 0,    
	@TotalRecords INT = 0,
    @StartTime DATETIME = GETDATE();

PRINT '=========================================';
PRINT 'DataMapping ContactoEmpresas';
PRINT '=========================================';
PRINT 'Start: ' + CONVERT(VARCHAR(20), @StartTime, 120);

-- ========================================
-- STEP 1: Extract source data (dedup by email within Bill-to)
-- ========================================
PRINT '';
PRINT '--- STEP 1: Extracting source data ---';

DECLARE @TMP_DataToInsert TABLE (
    IdEmpresa VARCHAR(16),
    IdEntidad VARCHAR(16),
    IdContacto VARCHAR(16),
    IdUsuarioLog VARCHAR(16),
    Seq INT IDENTITY(1, 1)
);

INSERT INTO @TMP_DataToInsert (
    IdEmpresa,
    IdEntidad,
    IdContacto,
    IdUsuarioLog
)
SELECT DISTINCT
    CE.idEmpresa,
    ER.EntityTypeId,
    CE.idContacto,
    'yUJoJlBG'
FROM ContactoEmpresas CE WITH (NOLOCK)
INNER JOIN Contactos CO WITH (NOLOCK) ON CO.id = CE.idContacto
INNER JOIN EntityRelations ER WITH (NOLOCK) ON ER.ReferenceId = CE.idEntidad
INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
    AND ET.EntityType = 1 -- Bill-to only
LEFT JOIN ContactoEmpresas CE2 WITH (NOLOCK) ON CE2.idEntidad = ER.EntityTypeId
    AND CE2.idEmpresa = CE.idEmpresa
    AND CE2.idContacto = CE.idContacto
WHERE CE.[status] = 'ACTIVO'
    AND CE2.id IS NULL;

SELECT @TotalRecords = @@ROWCOUNT;

PRINT 'Records extracted: ' + CAST(@TotalRecords AS VARCHAR(10));

IF @TotalRecords = 0
BEGIN
    PRINT 'No records to insert';
END
ELSE
BEGIN
    -- ========================================
    -- STEP 2: Generate bulk IDs (capturing SP output table)
    -- ========================================
    PRINT '';
    PRINT '--- STEP 2: Generating bulk IDs ---';

    DECLARE @TMP_AllIds TABLE (
        IdEmpresa VARCHAR(16),
        Id INT,
        Unificado VARCHAR(16)
    );

    DECLARE @Companies TABLE (
        Seq INT IDENTITY(1, 1),
        IdEmpresa VARCHAR(16)
    );

    DECLARE @TMP_TempIds TABLE (
        Id INT,
        Unificado VARCHAR(16)
    );

    INSERT INTO @Companies (IdEmpresa)
    SELECT E.Id
    FROM dbo.Empresas E WITH (NOLOCK)
    WHERE E.[status] = 'ACTIVO'
        AND EXISTS (
            SELECT 1
            FROM @TMP_DataToInsert DTI
            WHERE DTI.IdEmpresa = E.Id
        );

    DECLARE
        @CompanyId VARCHAR(16),
        @CompanyCount INT,
        @CompanyRow INT = 1,
        @CompanyRows INT = 0;

    SELECT @CompanyRows = COUNT(1)
    FROM @Companies;

    WHILE @CompanyRow <= @CompanyRows
    BEGIN
        SELECT @CompanyId = C.IdEmpresa
        FROM @Companies C
        WHERE C.Seq = @CompanyRow;

        SELECT @CompanyCount = COUNT(1)
        FROM @TMP_DataToInsert
        WHERE IdEmpresa = @CompanyId;

        IF @CompanyCount > 0
        BEGIN
            DELETE FROM @TMP_TempIds;

            INSERT INTO @TMP_TempIds
            EXEC dbo.pro_GeneralGenerarIdUnicoMasivo
                @tabla = 'ContactoEmpresas',
                @cantidad = @CompanyCount,
                @idEmpresa = @CompanyId;

            INSERT INTO @TMP_AllIds (
                IdEmpresa,
                Id,
                Unificado
            )
            SELECT
                @CompanyId,
                Id,
                Unificado
            FROM @TMP_TempIds;

            PRINT '  OK ' + @CompanyId + ': ' + CAST(@CompanyCount AS VARCHAR(10)) + ' IDs generated';
        END

        SELECT @CompanyRow = @CompanyRow + 1;
    END

    DECLARE @IdsCount INT = 0;

    SELECT @IdsCount = COUNT(*)
    FROM @TMP_AllIds;

    PRINT 'Total IDs generated: ' + CAST(@IdsCount AS VARCHAR(10));

    -- ========================================
    -- STEP 3: Insert records with IDs
    -- ========================================
    PRINT '';
    PRINT '--- STEP 3: Inserting in ContactoEmpresas with IDs ---';

    INSERT INTO ContactoEmpresas (
        id,
        idEmpresa,
        idEntidad,
        idContacto,
        idUsuarioLog,
        nota,
        [status],
        fechaCambio
    )
    SELECT
        AI.Unificado,
        DT.IdEmpresa,
        DT.IdEntidad,
        DT.IdContacto,
        DT.IdUsuarioLog,
        'datamapping',
        'ACTIVO',
        GETDATE()
    FROM @TMP_DataToInsert DT
    INNER JOIN @TMP_AllIds AI ON DT.Seq = AI.Id
        AND DT.IdEmpresa = AI.IdEmpresa;

    SELECT @TotalRecordsInserted = @@ROWCOUNT;

    PRINT 'Records inserted: ' + CAST(@TotalRecordsInserted AS VARCHAR(10));
END

-- ========================================
-- FINAL SUMMARY
-- ========================================
PRINT '';
PRINT '=========================================';
PRINT 'FINAL SUMMARY';
PRINT '=========================================';
PRINT 'Records inserted: ' + CAST(@TotalRecordsInserted AS VARCHAR(10));
PRINT 'Duration: ' + CONVERT(VARCHAR(10), DATEDIFF(SECOND, @StartTime, GETDATE())) + ' seconds';

IF @TotalRecordsInserted > 0
    PRINT 'Status: COMPLETED SUCCESSFULLY';
ELSE
    PRINT 'Status: COMPLETED WITH ERRORS OR NO RECORDS';
GO



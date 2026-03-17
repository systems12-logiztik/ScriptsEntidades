/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Luis Campos			2026-03-02	    55390	Initial Code - Reusable entity resolver (V1/V2)
*/

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetClientsEntities]
(
    @EntityId VARCHAR(16) = NULL,
    @IdUsuario VARCHAR(16) = NULL
)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        DECLARE 
        @EntityType VARCHAR(32),
        @ClientId VARCHAR(16),
        @EntityIdCE VARCHAR(16),
        @SkipStep BIT = 0

        -- =============================================================================================
        -- Validate input parameters: both @EntityId and @IdUsuario cannot be NULL or empty
        -- =============================================================================================
        IF (@EntityId IS NULL OR @EntityId = '') AND (@IdUsuario IS NULL OR @IdUsuario = '')
        BEGIN
            SELECT
            CAST(NULL AS VARCHAR(16)) AS EntityId,
            CAST(NULL AS VARCHAR(16)) AS IdCliente,
            CAST(NULL AS VARCHAR(32)) AS EntityType
            WHERE 1 = 0
            RETURN
        END

        -- =============================================================================================
        -- PRE-STEP: If IdUsuario provided, resolve to EntityId from Usuarios table
        -- If has EntityTypeId: use it (will use STEP 2 with V2 model)
        -- If only has idEntidad: use it but skip STEP 2 (must use STEP 3 with V1 legacy)
        -- =============================================================================================
        IF @IdUsuario IS NOT NULL
        BEGIN
            DECLARE @UsuarioEntityTypeId VARCHAR(16),
                    @UsuarioIdEntidad VARCHAR(16)
            
            SELECT TOP 1
            @UsuarioEntityTypeId = US.EntityTypeId,
            @UsuarioIdEntidad = US.IdEntidad
            FROM Usuarios US WITH (NOLOCK)
            WHERE US.Id = @IdUsuario
            
            -- If has EntityTypeId, use it (STEP 2 path)
            IF @UsuarioEntityTypeId IS NOT NULL
            BEGIN
                SET @EntityId = @UsuarioEntityTypeId
                SET @SkipStep = 0
            END
            -- If only has idEntidad (no EntityTypeId), use it but skip STEP 2 (STEP 3 path)
            ELSE IF @UsuarioIdEntidad IS NOT NULL
            BEGIN
                SET @EntityId = @UsuarioIdEntidad
                SET @SkipStep = 1
            END
        END

        -- =============================================================================================
        -- STEP 2: Try to get from v_ClientsEntities (V2 model - EntityType)
        -- Only execute if not skipped from PRE-STEP (when user has EntityTypeId, not just idEntidad)
        -- If found, return directly without reading other tables
        -- =============================================================================================
        IF @SkipStep = 0 AND @EntityId IS NOT NULL
        BEGIN
            SELECT TOP 1
            @EntityIdCE = CE.Id,
            @ClientId = CE.IdCliente,
            @EntityType = CE.TipoCliente
            FROM v_ClientsEntities CE WITH (NOLOCK)
            WHERE CE.Id = @EntityId
        END

        IF @EntityType IS NOT NULL
        BEGIN
            -- Return table with 1 row for EntityType (BILLTO/CONSIGNEE)
            SELECT
            @EntityIdCE AS EntityId,
            @ClientId AS IdCliente,
            @EntityType AS EntityType
            RETURN
        END

        -- =============================================================================================
        -- STEP 3: If not found by Id, try searching by BillToId in v_ClientsEntities
        -- Insert results into temp table, return if found, continue to STEP 4 if not found
        -- =============================================================================================
        IF @SkipStep = 0 AND @EntityId IS NOT NULL
        BEGIN
            CREATE TABLE #TMP_ClientsEntities (
                EntityId VARCHAR(16),
                IdCliente VARCHAR(16),
                EntityType VARCHAR(32)
            )
            
            INSERT INTO #TMP_ClientsEntities
            SELECT
            CE.Id AS EntityId,
            CE.IdCliente AS IdCliente,
            CE.TipoCliente AS EntityType
            FROM v_ClientsEntities CE WITH (NOLOCK)
            WHERE CE.BillToId = @EntityId
            
            IF @@ROWCOUNT > 0
            BEGIN
                SELECT
                EntityId,
                IdCliente,
                EntityType
                FROM #TMP_ClientsEntities
                RETURN
            END
        END

        -- =============================================================================================
        -- STEP 4: If not found in v_ClientsEntities, search in DetalleEntidades (V1 legacy)
        -- =============================================================================================
        SELECT TOP 1
        @EntityIdCE = CE.Id,
        @ClientId = DE.idEntidad,
        @EntityType = CAT.Identificador
        FROM DetalleEntidades DE WITH (NOLOCK)
        INNER JOIN Catalogos CAT WITH (NOLOCK) ON CAT.id = DE.idCatalogo
        LEFT JOIN v_ClientsEntities CE WITH (NOLOCK) ON CE.IdCliente = DE.idEntidad
        WHERE DE.idEntidad = @EntityId

        IF @EntityType = 'CLIENTE'
        BEGIN
            -- Return table with 1 row for individual Client
            SELECT
            @EntityIdCE AS EntityId,
            @ClientId AS IdCliente,
            @EntityType AS EntityType
            RETURN
        END
        ELSE IF @EntityType = 'GRUPOCLIENTE'
        BEGIN
            -- Return table with MULTIPLE rows (all clients in group)
            CREATE TABLE #TMP_ClientsGroup (
                IdCliente VARCHAR(16)
            )
            
            INSERT INTO #TMP_ClientsGroup
            SELECT IdCliente
            FROM GrupoClientes WITH (NOLOCK)
            WHERE IdGrupoCliente = @EntityId
            
            SELECT
            CE.Id AS EntityId,
            CG.IdCliente AS IdCliente,
            @EntityType AS EntityType
            FROM #TMP_ClientsGroup CG
            LEFT JOIN v_ClientsEntities CE WITH (NOLOCK) ON CE.IdCliente = CG.IdCliente
            RETURN
        END

        -- Entity not found, return empty result set
        SELECT
        CAST(NULL AS VARCHAR(16)) AS EntityId,
        CAST(NULL AS VARCHAR(16)) AS IdCliente,
        CAST(NULL AS VARCHAR(32)) AS EntityType
        WHERE 1 = 0
    END TRY
    BEGIN CATCH
        EXEC pro_LogError
    END CATCH
END
GO

-- ===============================================================================================================
-- USAGE EXAMPLES
-- ===============================================================================================================
/*
-- Example 1: Single Client lookup (V1 legacy)
EXEC AC_pro_GetClientsEntities @EntityId = 'CLI012985'

-- Example 2: Group Client lookup - returns all clients in group (V1 legacy)
EXEC AC_pro_GetClientsEntities @EntityId = 'CLI013680'

-- Example 3: Entity lookup (V2 model)
EXEC AC_pro_GetClientsEntities @EntityId = 'ETY0000000012080'

-- Example 4: BillTo lookup - search by BillToId in v_ClientsEntities (V2 model)
EXEC AC_pro_GetClientsEntities @EntityId = 'ETY0000000020008'

-- Example 5: User resolution - resolves to BillTo user (V2 model)
EXEC AC_pro_GetClientsEntities @IdUsuario = 'USU011088'
*/

/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Luis Campos			2026-03-02	    55390	Initial Code - Reusable entity resolver (V1/V2)
2		    Luis Campos			2026-04-17	    55188	Added JoinKey field for GuiasHouse JOIN logic
*/

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetClientsEntities]
(
    @EntityId VARCHAR(16),
    @UserType VARCHAR(32)
)
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        -- =============================================================================================
        -- STEP 1: Validate input parameters: both @EntityId and @UserType must have values
        -- =============================================================================================
        IF (@EntityId IS NULL OR @EntityId = '') OR (@UserType IS NULL OR @UserType = '')
        BEGIN
            SELECT
            CAST(NULL AS VARCHAR(16)) AS Id,
            CAST(NULL AS VARCHAR(16)) AS IdCliente,
            CAST(NULL AS VARCHAR(16)) AS BillToConsigneeId,
            CAST(NULL AS VARCHAR(16)) AS BillToId,
            CAST(NULL AS VARCHAR(16)) AS ConsigneeId,
            CAST(NULL AS VARCHAR(256)) AS BillToName,
            CAST(NULL AS VARCHAR(256)) AS [Name],
            CAST(NULL AS VARCHAR(16)) AS JoinKey
            WHERE 1 = 0
            RETURN
        END

        -- =============================================================================================
        -- STEP 2: For CONSIGNEE type - Returns Consignees from EntityRelations + standalone EntityTypes
        --         No duplicates: if ConsigneeId exists in EntityRelations, skip it in EntityTypes
        -- =============================================================================================
        IF @UserType = 'CONSIGNEE'
        BEGIN
            -- Part 1: Consignees from EntityRelations (relationships with BillTo)
            SELECT 
            ER.Id,
            ER.ReferenceId AS IdCliente,
            ER.Id AS BillToConsigneeId,
            ER.EntityTypeId AS BillToId,
            ER.ChildEntityTypeId AS ConsigneeId,
            EN.[Name] AS BillToName,
            ER.Alias AS [Name],
            ER.Id AS JoinKey
            FROM EntityRelations ER WITH (NOLOCK)
            INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
            INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
            WHERE ET.[Status] IN (1, 3)
            AND ER.[Status] = 1
            AND ER.SubType = 1
            AND ER.ChildEntityTypeId = @EntityId

            UNION ALL

            -- Part 2: Standalone Consignees from EntityTypes (not in EntityRelations)
            SELECT
            ET.Id,
            NULL AS IdCliente,
            NULL AS BillToConsigneeId,
            NULL AS BillToId,
            ET.Id AS ConsigneeId,
            EN.[Name] AS BillToName,
            EN.[Name] AS [Name],
            ET.Id AS JoinKey
            FROM EntityTypes ET WITH (NOLOCK)
            INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
            WHERE ET.Id = @EntityId
            AND ET.EntityType = 2
            AND ET.[Status] IN (1, 3)
            AND NOT EXISTS (
                SELECT 1 FROM EntityRelations ER WITH (NOLOCK)
                WHERE ER.ChildEntityTypeId = ET.Id
                AND ER.[Status] = 1
            )
            RETURN
        END

        -- =============================================================================================
        -- STEP 3: For BILLTO type - JoinKey = Id (from f_SearchEntities)
        -- =============================================================================================
        IF @UserType = 'BILLTO'
        BEGIN
            SELECT Id, IdCliente, BillToConsigneeId, BillToId, ConsigneeId, BillToName, [Name], Id AS JoinKey
            FROM dbo.f_SearchEntities(@EntityId, 'IdBillTo')
            RETURN
        END

        -- =============================================================================================
        -- STEP 4: Handle CLIENTE type - JoinKey = IdCliente
        -- =============================================================================================
        IF @UserType = 'CLIENTE'
        BEGIN
            SELECT FSE.Id, C.id AS IdCliente, FSE.BillToConsigneeId, FSE.BillToId, FSE.ConsigneeId, FSE.BillToName, FSE.[Name], C.id AS JoinKey
            FROM Clientes C WITH (NOLOCK)
            LEFT JOIN dbo.f_SearchEntities('', 'BillTo') FSE ON C.id = FSE.IdCliente
            WHERE C.id = @EntityId
            RETURN
        END
        -- =============================================================================================
        -- STEP 5: Handle GRUPOCLIENTE type - JoinKey = IdCliente
        -- =============================================================================================
        IF @UserType = 'GRUPOCLIENTE'
        BEGIN
            SELECT FSE.Id, GC.IdCliente, FSE.BillToConsigneeId, FSE.BillToId, FSE.ConsigneeId, FSE.BillToName, FSE.[Name], GC.IdCliente AS JoinKey
            FROM GrupoClientes GC WITH (NOLOCK)
            LEFT JOIN dbo.f_SearchEntities('', 'BillTo') FSE ON GC.IdCliente = FSE.IdCliente
            WHERE GC.IdGrupoCliente = @EntityId
            RETURN
        END

        -- Entity not found, return empty result set
        SELECT
        CAST(NULL AS VARCHAR(16)) AS Id,
        CAST(NULL AS VARCHAR(16)) AS IdCliente,
        CAST(NULL AS VARCHAR(16)) AS BillToConsigneeId,
        CAST(NULL AS VARCHAR(16)) AS BillToId,
        CAST(NULL AS VARCHAR(16)) AS ConsigneeId,
        CAST(NULL AS VARCHAR(256)) AS BillToName,
        CAST(NULL AS VARCHAR(256)) AS [Name],
        CAST(NULL AS VARCHAR(16)) AS JoinKey
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
-- Returns: EntityId, IdCliente, EntityType, BillToId, ConsigneeId, JoinKey=IdCliente
EXEC AC_pro_GetClientsEntities @EntityId = 'CLI012985', @UserType = 'CLIENTE'

-- Example 2: Group Client lookup - returns all clients in group (V1 legacy)
-- JoinKey=IdCliente
EXEC AC_pro_GetClientsEntities @EntityId = 'CLI013680', @UserType = 'GRUPOCLIENTE'

-- Example 3: CONSIGNEE lookup - resolves by entity type CONSIGNEE from v_ClientsEntities
-- JoinKey=Id (EntityRelations.Id)
EXEC AC_pro_GetClientsEntities @EntityId = 'ETY0000000012080', @UserType = 'CONSIGNEE'

-- Example 4: BILLTO lookup - resolves by entity type BILLTO, searches by Id or BillToId
-- JoinKey=Id (from f_SearchEntities)
EXEC AC_pro_GetClientsEntities @EntityId = 'ETY0000000020008', @UserType = 'BILLTO'

-- Result set includes:
-- Id: Entity identifier
-- IdCliente: Client identifier
-- BillToConsigneeId: BillTo-Consignee relationship Id
-- BillToId: BillTo entity reference
-- ConsigneeId: Consignee entity reference
-- JoinKey: Common field for GuiasHouse JOIN
--   - For CLIENTE/GRUPOCLIENTE: = IdCliente
--   - For CONSIGNEE/BILLTO: = Id (EntityRelations.Id)

-- ===============================================================================================================
-- USAGE WITH GuiasHouse: Examples of JOINing with dual fallback logic
-- ===============================================================================================================

/*
-- Example A: Get consolidated status using CLIENTE
DECLARE @EntityId VARCHAR(16) = 'CLI012985'
DECLARE @UserType VARCHAR(32) = 'CLIENTE'
DECLARE @ConsolidatorStatus VARCHAR(50)
DECLARE @WildcardDestinationDate DATETIME = '2026-01-01'
DECLARE @DateTo DATETIME = '2026-12-31'

INSERT INTO #TMP_RelatedClients (Id, IdCliente, BillToConsigneeId, BilltoId, ConsigneeId, JoinKey)
EXEC [dbo].[AC_pro_GetClientsEntities]
    @EntityId = @EntityId,
    @UserType = @UserType

-- Smart JOIN: First try BillToConsigneeId, then fallback to IdCliente
SELECT TOP 1 @ConsolidatorStatus = 'CONSOLIDADOR'
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN #TMP_RelatedClients REL ON 
    REL.BillToConsigneeId = GH.BillToConsigneeId OR 
    REL.IdCliente = GH.IDCliente
WHERE GH.FechaDestino BETWEEN @WildcardDestinationDate AND @DateTo 
AND GH.House IS NULL
*/

/*
-- Example B: Using JoinKey for simplicity (if GuiasHouse search differs by type)
-- For types where JoinKey = IdCliente: match against GH.IDCliente or GH.BillToConsigneeId
-- For types where JoinKey = Id: match against GH.BillToConsigneeId or GH.IDCliente

DECLARE @EntityId VARCHAR(16) = 'ETY0000000012080'
DECLARE @UserType VARCHAR(32) = 'CONSIGNEE'

INSERT INTO #TMP_RelatedClients (Id, IdCliente, BillToConsigneeId, BilltoId, ConsigneeId, JoinKey)
EXEC [dbo].[AC_pro_GetClientsEntities]
    @EntityId = @EntityId,
    @UserType = @UserType

-- For CONSIGNEE/BILLTO: JoinKey = Id, try BillToConsigneeId first
SELECT TOP 1 @ConsolidatorStatus = 'CONSOLIDADOR'
FROM GuiasHouse GH WITH(NOLOCK)
INNER JOIN #TMP_RelatedClients REL ON 
    REL.BillToConsigneeId = GH.BillToConsigneeId OR 
    REL.JoinKey = GH.BillToConsigneeId OR
    REL.IdCliente = GH.IDCliente
WHERE GH.FechaDestino BETWEEN @WildcardDestinationDate AND @DateTo 
AND GH.House IS NULL
*/
-- EntityType: The UserType passed (CLIENTE, GRUPOCLIENTE, CONSIGNEE, BILLTO)
-- BillToId: BillTo entity reference
-- ConsigneeId: Consignee entity reference
*/

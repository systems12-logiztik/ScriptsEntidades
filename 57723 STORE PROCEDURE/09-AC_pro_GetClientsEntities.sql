/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Luis Campos			2026-03-02	    55390	Initial Code - Reusable entity resolver (V1/V2)
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
            CAST(NULL AS VARCHAR(16)) AS ConsigneeId
            WHERE 1 = 0
            RETURN
        END

        -- =============================================================================================
        -- STEP 2: For CONSIGNEE type - use f_SearchEntities function
        -- =============================================================================================
        IF @UserType = 'CONSIGNEE'
        BEGIN
            SELECT 
            ER.Id,
            ER.ReferenceId AS IdCliente,
            ER.Id AS BillToConsigneeId,
            ER.EntityTypeId AS BillToId,
            ER.ChildEntityTypeId AS ConsigneeId, 
            EN.[Name] AS BillToName,
            ER.Alias AS [Name]
            FROM EntityRelations ER WITH (NOLOCK)
            INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
            INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
            WHERE ET.[Status] IN (1, 3)
            AND ER.[Status] = 1
            AND ER.SubType = 1
            AND ER.ChildEntityTypeId = @EntityId
            RETURN
        END

        -- =============================================================================================
        -- STEP 3: For BILLTO type - use f_SearchEntities function
        -- =============================================================================================
        IF @UserType = 'BILLTO'
        BEGIN
            SELECT Id, IdCliente, BillToConsigneeId, BillToId, ConsigneeId
            FROM dbo.f_SearchEntities(@EntityId, 'IdBillTo')
            RETURN
        END

        -- =============================================================================================
        -- STEP 4: Handle CLIENTE type - JOIN Clientes with f_SearchEntities for Consignee
        -- =============================================================================================
        IF @UserType = 'CLIENTE'
        BEGIN
            SELECT FSE.Id, C.id AS IdCliente, FSE.BillToConsigneeId, FSE.BillToId, FSE.ConsigneeId
            FROM Clientes C WITH (NOLOCK)
            LEFT JOIN dbo.f_SearchEntities('', 'BillTo') FSE ON C.id = FSE.IdCliente
            WHERE C.id = @EntityId
            RETURN
        END
        -- =============================================================================================
        -- STEP 5: Handle GRUPOCLIENTE type - JOIN GrupoClientes with f_SearchEntities for Consignee
        -- =============================================================================================
        IF @UserType = 'GRUPOCLIENTE'
        BEGIN
            SELECT FSE.Id, GC.IdCliente, FSE.BillToConsigneeId, FSE.BillToId, FSE.ConsigneeId
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
        CAST(NULL AS VARCHAR(16)) AS ConsigneeId
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
-- Returns: EntityId, IdCliente, EntityType, BillToId, ConsigneeId
EXEC AC_pro_GetClientsEntities @EntityId = 'CLI012985', @UserType = 'CLIENTE'

-- Example 2: Group Client lookup - returns all clients in group (V1 legacy)
EXEC AC_pro_GetClientsEntities @EntityId = 'CLI013680', @UserType = 'GRUPOCLIENTE'

-- Example 3: CONSIGNEE lookup - resolves by entity type CONSIGNEE from v_ClientsEntities
EXEC AC_pro_GetClientsEntities @EntityId = 'ETY0000000012080', @UserType = 'CONSIGNEE'

-- Example 4: BILLTO lookup - resolves by entity type BILLTO, searches by Id or BillToId
EXEC AC_pro_GetClientsEntities @EntityId = 'ETY0000000020008', @UserType = 'BILLTO'

-- Result set includes:
-- EntityId: Entity identifier from v_ClientsEntities
-- IdCliente: Client identifier
-- EntityType: The UserType passed (CLIENTE, GRUPOCLIENTE, CONSIGNEE, BILLTO)
-- BillToId: BillTo entity reference
-- ConsigneeId: Consignee entity reference
*/

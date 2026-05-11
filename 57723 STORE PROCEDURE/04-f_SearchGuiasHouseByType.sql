/*    
VERSION		MODIFIEDBY		MODIFIEDDATE	HU		MODIFICATION
1			Luis Campos		2026-04-23		55188		Initial: Optimized GuiasHouse search by entity type (CLIENTE, GRUPOCLIENTE, CONSIGNEE, BILLTO)
*/

CREATE OR ALTER FUNCTION [dbo].[f_SearchGuiasHouseByType](
    @UserType VARCHAR(16),
    @EntityId VARCHAR(16)
)
RETURNS TABLE
AS
RETURN
(
    SELECT GH.*, EID.[Name]
    FROM GuiasHouse GH WITH(NOLOCK)
    INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID ON GH.IDCliente = EID.Id
    WHERE @UserType IN ('CLIENTE', 'GRUPOCLIENTE')

    UNION ALL

    SELECT GH.*, EID.[Name]
    FROM GuiasHouse GH WITH(NOLOCK)
    INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID ON GH.ConsigneeId = EID.Id
    WHERE @UserType = 'CONSIGNEE'

    UNION ALL

    SELECT GH.*, EID.[Name]
    FROM GuiasHouse GH WITH(NOLOCK)
    INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID ON GH.BillToConsigneeId = EID.Id
    WHERE @UserType = 'BILLTO'
)
GO

-- ===============================================================================================================
-- USAGE EXAMPLES
-- ===============================================================================================================
/*
-- Example 1: CLIENTE
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseByType('CLIENTE', 'CLI0122266')

-- Example 2: GRUPOCLIENTE
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseByType('GRUPOCLIENTE', 'CLI013680')

-- Example 3: CONSIGNEE
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseByType('CONSIGNEE', 'ETY01556')

-- Example 4: BILLTO
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseByType('BILLTO', 'ETY01272')

-- Example 5: With additional filters
SELECT TOP 20 GH.*
FROM dbo.f_SearchGuiasHouseByType('CLIENTE', 'CLI0122266') GH
WHERE GH.FechaDestino >= '2026-01-01'
ORDER BY GH.FechaDestino DESC
*/
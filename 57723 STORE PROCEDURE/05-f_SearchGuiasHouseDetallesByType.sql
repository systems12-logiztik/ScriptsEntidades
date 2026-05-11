/*    
VERSION		MODIFIEDBY		MODIFIEDDATE	HU		MODIFICATION
1			Luis Campos		2026-04-23		55188		Initial: Optimized GuiasHouseDetalles search by entity type (CLIENTE, GRUPOCLIENTE, CONSIGNEE, BILLTO)
2			Luis Campos		2026-04-27		55188		Performance: Inline TVF with dual JOIN branches for optimal index usage
3			Luis Campos		2026-04-27		55188		Performance: Added index hints to force SEEK instead of SCAN
*/

CREATE OR ALTER FUNCTION [dbo].[f_SearchGuiasHouseDetallesByType](
    @UserType VARCHAR(16),
    @EntityId VARCHAR(16)
)
RETURNS TABLE
AS
RETURN
(
    SELECT GHD.*, EID.[Name]
    FROM GuiasHouseDetalles GHD WITH(NOLOCK)
    INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID ON GHD.idClienteFinal = EID.Id
    WHERE @UserType IN ('CLIENTE', 'GRUPOCLIENTE')

    UNION ALL

    SELECT GHD.*, EID.[Name]
    FROM GuiasHouseDetalles GHD WITH(NOLOCK, INDEX(idx_GuiasHouseDetalles_ShipToId_EstadoPieza))
    INNER JOIN dbo.f_GetClientsEntities(@UserType, @EntityId) EID ON GHD.ShipToId = EID.ConsigneeId
    WHERE @UserType IN ('CONSIGNEE', 'BILLTO')
)
GO

-- ===============================================================================================================
-- USAGE EXAMPLES (Use OPTION RECOMPILE at query time if needed for optimal performance)
-- ===============================================================================================================
/*
-- Example 1: CLIENTE
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseDetallesByType('CLIENTE', 'CLI0122266')

-- Example 2: GRUPOCLIENTE
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseDetallesByType('GRUPOCLIENTE', 'CLI013680')

-- Example 3: CONSIGNEE
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseDetallesByType('CONSIGNEE', 'ETY01556')

-- Example 4: BILLTO
SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseDetallesByType('BILLTO', 'ETY01272')

-- Example 5: With additional filters
SELECT TOP 20 GHD.*
FROM dbo.f_SearchGuiasHouseDetallesByType('CLIENTE', 'CLI0122266') GHD
ORDER BY GHD.id DESC

-- Performance tip: For stale execution plans, add at query time:
-- SELECT TOP 10 * FROM dbo.f_SearchGuiasHouseDetallesByType('CONSIGNEE', 'ETY01556') OPTION (RECOMPILE)
*/

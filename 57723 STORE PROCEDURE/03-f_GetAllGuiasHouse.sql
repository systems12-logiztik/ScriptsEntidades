/*
VERSION     MODIFIEDBY      MODIFIEDDATE    HU      MODIFICATION
1           Luis Campos     2026-04-29      55188   Create function to get all GuiasHouse with client data
2           Luis Campos     2026-04-29      55188   Implement cascade JOIN logic: BillToConsigneeId > ConsigneeId > IDCliente
3           Luis Campos     2026-04-29      55188   Add optional parameter @SearchTerm for f_SearchEntities
*/

CREATE OR ALTER FUNCTION [dbo].[f_GetAllGuiasHouse](
    @SearchType VARCHAR(16) = '',
    @SearchTerm VARCHAR(MAX) = ''
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        GH.*,
        CASE 
            -- Si @SearchType está vacío, hacer cascade: BillTo > Consignee > NULL
            WHEN @SearchType = '' AND GH.BillToConsigneeId IS NOT NULL 
                THEN (SELECT TOP 1 [Name] FROM dbo.f_SearchEntities(@SearchTerm, 'BillTo') WHERE Id = GH.BillToConsigneeId)
            WHEN @SearchType = '' AND GH.ConsigneeId IS NOT NULL 
                THEN (SELECT TOP 1 [Name] FROM dbo.f_SearchEntities(@SearchTerm, 'Consignee') WHERE Id = GH.ConsigneeId)
            -- Si @SearchType especifica BillTo (Name o ID), buscar solo en BillToConsigneeId
            WHEN @SearchType IN ('BillTo', 'IdBillTo') AND GH.BillToConsigneeId IS NOT NULL
                THEN (SELECT TOP 1 [Name] FROM dbo.f_SearchEntities(@SearchTerm, @SearchType) WHERE Id = GH.BillToConsigneeId)
            -- Si @SearchType especifica Consignee (Name o ID), buscar solo en ConsigneeId
            WHEN @SearchType IN ('Consignee', 'IdConsignee') AND GH.ConsigneeId IS NOT NULL
                THEN (SELECT TOP 1 [Name] FROM dbo.f_SearchEntities(@SearchTerm, @SearchType) WHERE Id = GH.ConsigneeId)
            ELSE NULL
        END AS [Name]
    FROM GuiasHouse GH WITH (NOLOCK)
)
GO

-- =====================================================
-- EJEMPLOS DE USO
-- =====================================================

-- EJEMPLO 1: Obtener TOP 10 de TODOS los GuiasHouse (cascade: BillTo > Consignee > NULL)
/*
SELECT TOP 10 * FROM dbo.f_GetAllGuiasHouse('', '')
ORDER BY id DESC;
*/

-- EJEMPLO 1B: Con filtro de búsqueda en cascade
/*
SELECT TOP 10 * FROM dbo.f_GetAllGuiasHouse('', 'ALIANZA')
ORDER BY id DESC;
*/

-- EJEMPLO 1C: Solo BillTo por Name (Name match)
/*
SELECT TOP 10 * FROM dbo.f_GetAllGuiasHouse('BillTo', '')
ORDER BY id DESC;
*/

-- EJEMPLO 1D: Solo BillTo por ID (ID match)
/*
SELECT TOP 10 * FROM dbo.f_GetAllGuiasHouse('IdBillTo', '')
ORDER BY id DESC;
*/

-- EJEMPLO 1E: Solo Consignee por Name (Name match)
/*
SELECT TOP 10 * FROM dbo.f_GetAllGuiasHouse('Consignee', '')
ORDER BY id DESC;
*/

-- EJEMPLO 1F: Solo Consignee por ID (ID match)
/*
SELECT TOP 10 * FROM dbo.f_GetAllGuiasHouse('IdConsignee', '')
ORDER BY id DESC;
*/

-- EJEMPLO 2: Filtrar BillTo por término de búsqueda
/*
SELECT * FROM dbo.f_GetAllGuiasHouse('BillTo', 'MEXICO')
WHERE [Name] IS NOT NULL
ORDER BY id DESC;
*/

-- EJEMPLO 3: Filtrar por empresa, fecha y tipo
/*
SELECT * FROM dbo.f_GetAllGuiasHouse('Consignee', '')
WHERE idEmpresa = 'EMP014'
    AND fechaCreacion >= DATEADD(MONTH, -6, GETDATE())
    AND [Name] IS NOT NULL
ORDER BY fechaCreacion DESC;
*/

-- EJEMPLO 4: Agrupar por empresa (con cascade completo)
/*
SELECT 
    idEmpresa,
    COUNT(*) AS TotalGuias,
    COUNT(DISTINCT [Name]) AS ClientesUnicos,
    SUM(CASE WHEN [Name] IS NOT NULL THEN 1 ELSE 0 END) AS ConNombre
FROM dbo.f_GetAllGuiasHouse('', '')
GROUP BY idEmpresa
ORDER BY idEmpresa;
*/

-- EJEMPLO 5: Búsqueda con patrón en BillTo
/*
SELECT * FROM dbo.f_GetAllGuiasHouse('BillTo', 'MEXICO')
WHERE [Name] IS NOT NULL
ORDER BY [Name];
*/

-- EJEMPLO 6: Cascade completo (ambos parámetros vacíos = BillTo > Consignee)
/*
SELECT * FROM dbo.f_GetAllGuiasHouse('', '')
WHERE [Name] IS NOT NULL;
*/

-- PARÁMETROS:
-- @SearchType VARCHAR(16) = '' : Tipo de entidad a buscar
--     '' (vacío) = Cascade: intenta BillTo primero, luego Consignee
--     'BillTo' = Solo busca en BillToConsigneeId (Name match en f_SearchEntities)
--     'IdBillTo' = Solo busca en BillToConsigneeId (ID match en f_SearchEntities)
--     'Consignee' = Solo busca en ConsigneeId (Name match en f_SearchEntities)
--     'IdConsignee' = Solo busca en ConsigneeId (ID match en f_SearchEntities)
-- @SearchTerm VARCHAR(MAX) = '' : Término para buscar en f_SearchEntities (ej: 'ALIANZA', 'MEXICO')


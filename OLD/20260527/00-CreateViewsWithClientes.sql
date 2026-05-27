/*
VERSION     MODIFIEDBY      MODIFIEDDATE    HU      MODIFICATION
1           Luis Campos     2026-05-15      55188   Create unified view: Entities + Clientes (for testing)
*/

CREATE OR ALTER VIEW dbo.v_ClientsEntitiesUnified
AS
    -- PART 1: BillToConsignee relations
    SELECT 
        ER.Id,
        EN.Id                            AS EntityId,
        ER.EntityTypeId                  AS BillToId,
        ER.ChildEntityTypeId             AS ConsigneeId,
        ER.ReferenceId                   AS IdCliente,
        EN.[Name]                        AS BillToName,
        ER.SubType,
        ET.[Status],
        'BillToConsignee'                AS tipoCliente,
        EN.CountryId                     AS idPais,
        EN.SubdivisionId                 AS idEstado,
        EN.CityId                        AS idCiudad,
        CASE 
            WHEN ER.SubType = 2 THEN ER.Alias
            ELSE EN2.[Name]
        END                              AS nombre,
        EN.Address1                      AS direccion,
        EN.PostalCode                    AS codigozip,
        NULL                             AS email,
        NULL                             AS telefono,
        NULL                             AS identificacion,
        NULL                             AS tipoIdentificacion
    FROM EntityRelations ER WITH (NOLOCK)
    INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
    INNER JOIN EntityTypes ET2 WITH (NOLOCK) ON ET2.Id = ER.ChildEntityTypeId
    INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
    INNER JOIN Entities EN2 WITH (NOLOCK) ON EN2.Id = ET2.EntityId
    WHERE ET.[Status] IN (1, 3)
    AND ET.EntityType = 1
    AND ER.[Status] = 1

UNION ALL

    -- PART 2: Consignee entities (without BillToConsignee relation)
    SELECT 
        ET.Id,
        EN.Id                            AS EntityId,
        NULL                             AS BillToId,
        ET.Id                            AS ConsigneeId,
        NULL                             AS IdCliente,
        NULL                             AS BillToName,
        NULL                             AS SubType,
        ET.[Status],
        'Consignee'                      AS tipoCliente,
        EN.CountryId                     AS idPais,
        EN.SubdivisionId                 AS idEstado,
        EN.CityId                        AS idCiudad,
        EN.[Name]                        AS nombre,
        EN.Address1                      AS direccion,
        EN.PostalCode                    AS codigozip,
        NULL                             AS email,
        NULL                             AS telefono,
        NULL                             AS identificacion,
        NULL                             AS tipoIdentificacion
    FROM EntityTypes ET WITH (NOLOCK)
    INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
    WHERE ET.[Status] IN (1, 3)
    AND ET.EntityType = 2

UNION ALL

    -- PART 3: Clientes table (for backward compatibility and testing)
    SELECT 
        C.id                             AS Id,
        NULL                             AS EntityId,
        NULL                             AS BillToId,
        NULL                             AS ConsigneeId,
        C.id                             AS IdCliente,
        C.Nombre                         AS BillToName,
        NULL                             AS SubType,
        1                                AS [Status],
        'Cliente'                        AS tipoCliente,
        C.idPais                         AS idPais,
        C.idEstado                       AS idEstado,
        C.idCiudad                       AS idCiudad,
        C.Nombre                         AS nombre,
        C.Direccion                      AS direccion,
        C.CodigoZip                      AS codigozip,
        C.Email                          AS email,
        C.Telefono                       AS telefono,
        C.Identificacion                 AS identificacion,
        C.TipoIdentificacion             AS tipoIdentificacion
    FROM Clientes C WITH (NOLOCK)
    WHERE C.status = 'ACTIVO'

GO

-- ===============================================================================================================
-- TEST: Verify unified view
-- ===============================================================================================================
/*
SELECT TOP 20 * FROM dbo.v_ClientsEntitiesUnified
ORDER BY tipoCliente, nombre
*/

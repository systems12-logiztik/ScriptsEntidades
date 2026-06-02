/*
VERSION     MODIFIEDBY      MODIFIEDDATE    HU      MODIFICATION
1           Luis Campos     2026-01-22      55188   Create unified views for Entities model
*/

CREATE OR ALTER VIEW dbo.v_ClientsEntities
AS
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
		END								 AS nombre,
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
GO

CREATE OR ALTER VIEW dbo.v_ClientsEntitiesAll
AS
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
			WHEN ER.SubType = 2 
			THEN ER.Alias
			ELSE EN2.[Name]
		END								 AS nombre,
        EN.Address1                      AS direccion,
        EN.PostalCode                    AS codigozip,
        MAX(CASE WHEN MD.identifier = 'EMAIL' THEN MD.[value] END)   AS email,
        MAX(CASE WHEN MD.identifier = 'PHONE' THEN MD.[value] END)   AS telefono,
        COALESCE(
            MAX(CASE WHEN MD.identifier = 'EORI' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'IDENTIFICATIONCARD' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'PASSPORT' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'IMPORTEROFRECORD' THEN MD.[value] END)
        ) AS identificacion,
        COALESCE(
            MAX(CASE WHEN MD.identifier = 'EORI' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'IDENTIFICATIONCARD' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'PASSPORT' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'IMPORTEROFRECORD' THEN MD.identifier END)
        ) AS tipoIdentificacion
    FROM EntityRelations ER WITH (NOLOCK)
    INNER JOIN EntityTypes ET WITH (NOLOCK) ON ET.Id = ER.EntityTypeId
    INNER JOIN EntityTypes ET2 WITH (NOLOCK) ON ET2.Id = ER.ChildEntityTypeId
    INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
    INNER JOIN Entities EN2 WITH (NOLOCK) ON EN2.Id = ET2.EntityId
    CROSS APPLY OPENJSON(CASE WHEN ISJSON(ET.Metadata) = 1 THEN ET.Metadata ELSE '[]' END) WITH (identifier VARCHAR(32), [value] VARCHAR(128)) MD
    WHERE ET.[Status] IN (1, 3)
    AND ET.EntityType = 1
    AND ER.[Status] = 1
    GROUP BY ER.Id, EN.Id, ER.EntityTypeId, ER.ChildEntityTypeId, ER.ReferenceId, EN.[Name], EN2.[Name], ER.SubType, ET.[Status],
             EN.CountryId, EN.SubdivisionId, EN.CityId, ER.Alias, EN.Address1, EN.PostalCode, ER.[Status]

UNION ALL

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
        MAX(CASE WHEN MD.identifier = 'EMAIL' THEN MD.[value] END)   AS email,
        MAX(CASE WHEN MD.identifier = 'PHONE' THEN MD.[value] END)   AS telefono,
        COALESCE(
            MAX(CASE WHEN MD.identifier = 'EORI' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'IDENTIFICATIONCARD' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'PASSPORT' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN MD.[value] END),
            MAX(CASE WHEN MD.identifier = 'IMPORTEROFRECORD' THEN MD.[value] END)
        ) AS identificacion,
        COALESCE(
            MAX(CASE WHEN MD.identifier = 'EORI' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'IDENTIFICATIONCARD' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'PASSPORT' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'FISCALIDENTIFICATIONNUMBER' THEN MD.identifier END),
            MAX(CASE WHEN MD.identifier = 'IMPORTEROFRECORD' THEN MD.identifier END)
        ) AS tipoIdentificacion
    FROM EntityTypes ET WITH (NOLOCK)
    INNER JOIN Entities EN WITH (NOLOCK) ON EN.Id = ET.EntityId
     CROSS APPLY OPENJSON(CASE WHEN ISJSON(ET.Metadata) = 1 THEN ET.Metadata ELSE '[]' END) WITH (identifier VARCHAR(32), [value] VARCHAR(128)) MD
    WHERE ET.[Status] IN (1, 3)
    AND ET.EntityType = 2
    GROUP BY ET.Id, EN.Id, EN.CountryId, EN.SubdivisionId, EN.CityId, ET.[Status], 
             EN.[Name], EN.Address1, EN.PostalCode
GO
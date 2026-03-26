/*
VERSION     MODIFIEDBY      MODIFIEDDATE    HU      MODIFICATION
1           Luis Campos     2026-01-22      53095   Create unified views for Entities model
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
        CAST(NULL AS VARCHAR(16))        AS email,
        CAST(NULL AS VARCHAR(16))        AS telefono,
        CAST(NULL AS VARCHAR(16))        AS identificacion,
        CAST(NULL AS VARCHAR(16))        AS tipoIdentificacion
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
        ET.ReferenceId                   AS IdCliente,
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
        CAST(NULL AS VARCHAR(16))        AS email,
        CAST(NULL AS VARCHAR(16))        AS telefono,
        CAST(NULL AS VARCHAR(16))        AS identificacion,
        CAST(NULL AS VARCHAR(16))        AS tipoIdentificacion
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
        ET.ReferenceId                   AS IdCliente,
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
    GROUP BY ET.Id, EN.Id, ET.ReferenceId, EN.CountryId, EN.SubdivisionId, EN.CityId, ET.[Status], 
             EN.[Name], EN.Address1, EN.PostalCode, ET.[Status]
GO

CREATE OR ALTER VIEW dbo.v_GroupEntities
AS
    SELECT 
        GC.idGrupoCliente,
        GC.idCliente,
        ET.Id                           AS ConsigneeId,
        ER.Id                           AS BillToConsigneeId
    FROM GrupoClientes GC WITH (NOLOCK)
    LEFT JOIN EntityTypes ET WITH (NOLOCK) ON ET.ReferenceId = GC.idCliente AND ET.[Status] = 1 AND ET.EntityType = 2
    LEFT JOIN EntityRelations ER WITH (NOLOCK) ON ER.ReferenceId = GC.idCliente AND ER.[Status] = 1
GO
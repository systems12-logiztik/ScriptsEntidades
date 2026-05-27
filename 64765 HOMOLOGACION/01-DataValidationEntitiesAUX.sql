/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			pchicaiza		    2026-04-15      64765		Data validation for Entities - Execute on alliance_migracion
*/
SELECT Id, Address2				FROM EntitiesAUX						WHERE Address2 = 'NULL' OR Address2 = '' OR Address2 LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT Id, Address1				FROM EntitiesAUX						WHERE Address1 = 'NULL' OR Address1 = '' OR Address1 LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT Id, [Name]				FROM EntitiesAUX						WHERE [Name] = 'NULL' OR [Name] = '' OR [Name] LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT Id, CountryId			FROM EntitiesAUX						WHERE CountryId = 'NULL' OR CountryId = '' OR CountryId NOT IN (SELECT id FROM alliance_testing..Paises)
GO
SELECT Id, CityId				FROM EntitiesAUX						WHERE CityId = 'NULL' OR CityId = '' OR CityId NOT IN (SELECT id FROM alliance_testing..Ciudades)
GO
SELECT Id, SubdivisionId		FROM EntitiesAUX						WHERE SubdivisionId = 'NULL' OR SubdivisionId = '' OR SubdivisionId NOT IN (SELECT id FROM alliance_testing..Estados)
GO
SELECT Id, EntityId				FROM EntityTypesAUX						WHERE EntityId = 'NULL' OR EntityId = '' OR EntityId NOT IN (SELECT Id FROM EntitiesAUX)
GO
SELECT Id, [Status]				FROM EntityTypesAUX						WHERE [Status] <> 1
GO
SELECT Id, EntityType			FROM EntityTypesAUX						WHERE EntityType NOT IN (1,2) 
GO
SELECT Id, EntityTypeId			FROM EntityRelationsAUX					WHERE EntityTypeId = 'NULL' OR EntityTypeId = '' OR EntityTypeId NOT IN (SELECT Id FROM EntityTypesAUX WHERE EntityType = 1)
GO
SELECT Id, ChildEntityTypeId	FROM EntityRelationsAUX					WHERE ChildEntityTypeId = 'NULL' OR ChildEntityTypeId = '' OR ChildEntityTypeId NOT IN (SELECT Id FROM EntityTypesAUX WHERE EntityType = 2)
GO
SELECT Id, ReferenceId			FROM EntityRelationsAUX					WHERE ReferenceId = 'NULL' OR ReferenceId = '' OR ReferenceId NOT IN (SELECT Id FROM alliance_testing..Clientes)
GO
SELECT Id, [Status]				FROM EntityRelationsAUX					WHERE [Status] <> 1
GO
SELECT Id, SubType				FROM EntityRelationsAUX					WHERE SubType NOT IN (1,2,3)
GO
SELECT Id, Alias				FROM EntityRelationsAUX					WHERE Alias = 'NULL' OR Alias = '' OR Alias LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT ReferenceId,'Repeated'	FROM EntityRelationsAUX					GROUP BY ReferenceId HAVING COUNT(1) > 1 
GO
SELECT id, EntityTypeId			FROM CodigosClienteAUX					WHERE EntityTypeId IS NULL OR EntityTypeId NOT IN (SELECT Id FROM EntityTypesAUX WHERE EntityType = 1)
GO
SELECT id, [status]				FROM CodigosClienteAUX					WHERE [status] NOT IN ('ACTIVO') OR [status] IS NULL  
GO
SELECT id, idTipoCodigo			FROM CodigosClienteAUX					WHERE idTipoCodigo NOT IN ('TCOD004') OR idTipoCodigo IS NULL  
GO
SELECT id, idEstado				FROM CiudadesAUX						WHERE idEstado IS NULL OR idEstado NOT IN (SELECT ID FROM alliance_testing.dbo.Estados)
GO
SELECT id, CountryId			FROM CiudadesAUX						WHERE CountryId IS NULL OR CountryId NOT IN (SELECT ID FROM alliance_testing.dbo.Paises)
GO
SELECT id, [status]				FROM CiudadesAUX						WHERE [status] NOT IN ('ACTIVO') OR [status] IS NULL 
GO
SELECT Id, nombre				FROM CiudadesAUX						WHERE nombre = 'NULL' OR nombre = '' OR nombre LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT id, SyncAction			FROM CiudadesAUX						WHERE SyncAction NOT IN ('I','U')
GO
SELECT id, idPais				FROM EstadosAUX							WHERE idPais IS NULL OR idPais NOT IN (SELECT ID FROM alliance_testing.dbo.Paises)
GO
SELECT id, [status]				FROM EstadosAUX							WHERE [status] NOT IN ('ACTIVO') OR [status] IS NULL 
GO
SELECT id, nombre				FROM EstadosAUX							WHERE nombre = 'NULL' OR nombre = '' OR nombre LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT id, SyncAction			FROM EstadosAUX							WHERE SyncAction NOT IN ('I','U')
GO
SELECT id, idRegiones			FROM PaisesAUX							WHERE idRegiones IS NULL OR idRegiones NOT IN (SELECT ID FROM alliance_testing.dbo.Regiones)
GO
SELECT id, [status]				FROM PaisesAUX							WHERE [status] NOT IN ('ACTIVO') OR [status] IS NULL 
GO
SELECT id, nombre				FROM PaisesAUX							WHERE nombre = 'NULL' OR nombre = '' OR nombre LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT id, SyncAction			FROM PaisesAUX							WHERE SyncAction NOT IN ('I','U')
GO
SELECT id, idCiudad				FROM PuertosAUX							WHERE idCiudad IS NULL OR idCiudad NOT IN (SELECT ID FROM alliance_testing.dbo.Ciudades)
GO
SELECT id, [status]				FROM PuertosAUX							WHERE [status] NOT IN ('ACTIVO') OR [status] IS NULL 
GO
SELECT id, nombre				FROM PuertosAUX							WHERE nombre = 'NULL' OR nombre = '' OR nombre LIKE '%[abcdefghijklmnopqrstuvwxyz]%' COLLATE Latin1_General_CS_AS
GO
SELECT id, SyncAction			FROM PuertosAUX							WHERE SyncAction NOT IN ('I','U')
GO



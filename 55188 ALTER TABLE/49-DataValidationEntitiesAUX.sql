/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			pchicaiza		    2026-04-15      64765		Data validation for Entities - Execute on alliance_migracion
*/

SELECT Id, Address2 FROM EntitiesAUX WHERE Address2 = 'NULL' OR Address2 = '' OR Address2 LIKE '%[abcdefghijklmnopqrstuvwxyz]%' collate Latin1_General_CS_AS
GO
SELECT Id, Address1 FROM EntitiesAUX WHERE Address1 = 'NULL' OR Address1 = '' OR Address1 LIKE '%[abcdefghijklmnopqrstuvwxyz]%' collate Latin1_General_CS_AS
GO
SELECT Id, [Name] FROM EntitiesAUX WHERE [Name] = 'NULL' OR [Name] = '' OR [Name] LIKE '%[abcdefghijklmnopqrstuvwxyz]%' collate Latin1_General_CS_AS
GO
SELECT Id, CountryId FROM EntitiesAUX WHERE CountryId = 'NULL' OR CountryId = '' OR CountryId NOT IN (SELECT id FROM alliance_testing..Paises)
GO
SELECT Id, CityId FROM EntitiesAUX WHERE CityId = 'NULL' OR CityId = '' OR CityId NOT IN (SELECT id FROM alliance_testing..Ciudades)
GO
SELECT Id, SubdivisionId FROM EntitiesAUX WHERE SubdivisionId = 'NULL' OR SubdivisionId = '' OR SubdivisionId NOT IN (SELECT id FROM alliance_testing..Estados)
GO
SELECT Id, EntityId FROM EntityTypesAUX WHERE EntityId = 'NULL' OR EntityId = '' OR EntityId NOT IN (SELECT Id FROM EntitiesAUX)
GO
SELECT Id, [Status] FROM EntityTypesAUX WHERE [Status] <> 1
GO
SELECT Id, EntityType FROM EntityTypesAUX WHERE EntityType NOT IN (1,2)
GO
SELECT Id, EntityTypeId FROM EntityRelationsAUX WHERE EntityTypeId = 'NULL' OR EntityTypeId = '' OR EntityTypeId NOT IN (SELECT Id FROM EntityTypesAUX)
GO
SELECT Id, ChildEntityTypeId FROM EntityRelationsAUX WHERE ChildEntityTypeId = 'NULL' OR ChildEntityTypeId = '' OR ChildEntityTypeId NOT IN (SELECT Id FROM EntityTypesAUX)
GO
SELECT Id, ReferenceId FROM EntityRelationsAUX WHERE ReferenceId = 'NULL' OR ReferenceId = '' OR ReferenceId NOT IN (SELECT Id FROM alliance_testing..Clientes)
GO
SELECT Id, [Status] FROM EntityRelationsAUX WHERE [Status] <> 1
GO
SELECT Id, SubType FROM EntityRelationsAUX WHERE SubType NOT IN (1,2,3)
GO
SELECT Id, Alias FROM EntityRelationsAUX WHERE Alias = 'NULL' OR Alias = '' OR Alias LIKE '%[abcdefghijklmnopqrstuvwxyz]%' collate Latin1_General_CS_AS
GO
SELECT ReferenceId, COUNT(1) , 'ReferenceId repetidos'
FROM EntityRelationsAUX 
GROUP BY ReferenceId
HAVING COUNT(1) > 1 



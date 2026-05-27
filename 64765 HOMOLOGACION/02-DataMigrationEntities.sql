/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			jordonez			2026-04-15      64765		Data migration for Entities 
*/
INSERT INTO [dbo].[Entities] (
	[Id],
	[CountryId],
	[SubdivisionId],
	[CityId],
	[Name],
	[Address1],
	[Address2],
	[PostalCode],
	[Latitude],
	[Longitude],
	[CreatedDate],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy]
)
SELECT
	[Id],
	[CountryId],
	[SubdivisionId],
	[CityId],
	[Name],
	[Address1],
	[Address2],
	[PostalCode],
	[Latitude],
	[Longitude],
	[CreatedDate],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy]
FROM [alliance_migracion].[dbo].[EntitiesAUX]

UPDATE Contadores
SET contador = 1 + (SELECT MAX(CAST(STUFF(Id, 1, 5, '') AS INT))
					FROM [Entities])
WHERE tabla = 'Entities'
GO 

INSERT INTO [dbo].[EntityTypes] (
	[Id],
	[EntityId],
	[Status],
	[EntityType],
	[Metadata],
	[CreatedDate],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy]
)
SELECT
	[Id],
	[EntityId],
	[Status],
	[EntityType],
	[Metadata],
	[CreatedDate],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy]
FROM [alliance_migracion].[dbo].[EntityTypesAUX]

UPDATE Contadores
SET contador = 1 + (SELECT MAX(CAST(STUFF(Id, 1, 5, '') AS INT))
					FROM [EntityTypes])
WHERE tabla = 'EntityTypes'
GO 

INSERT INTO [dbo].[EntityRelations] (
	[Id],
	[EntityTypeId],
	[ChildEntityTypeId],
	[ReferenceId],
	[Status],
	[SubType],
	[Alias],
	[CreatedDate],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy]
)
SELECT
	[Id],
	[EntityTypeId],
	[ChildEntityTypeId],
	[ReferenceId],
	[Status],
	[SubType],
	[Alias],
	[CreatedDate],
	[CreatedBy],
	[ModifiedDate],
	[ModifiedBy]
FROM [alliance_migracion].[dbo].[EntityRelationsAUX]

UPDATE Contadores
SET contador = 1 + (SELECT MAX(CAST(STUFF(Id, 1, 5, '') AS INT))
					FROM EntityRelations)
WHERE tabla = 'EntityRelations'
GO


DECLARE @Result VARCHAR(16)
		,@NextCounter INT 
		,@CodigoEmpresa VARCHAR(8) = '05'
 
EXEC [dbo].[PRO_General_GenerarIdUnico] @tabla = 'CodigosCliente', @IdUnico = @Result OUTPUT
 
SELECT @NextCounter = CAST(STUFF(@Result, 1, 6, '') AS INT)
 
INSERT INTO CodigosCliente (
id
,idCliente
,idEmpresa
,idTipoCodigo
,valor
,idUsuarioLog
,nota
,[status]
,fechaCambio
,EntityTypeId
) 
SELECT 
CONCAT('COCL',@CodigoEmpresa,id+@NextCounter)
,idCliente
,idEmpresa
,idTipoCodigo
,valor
,idUsuarioLog
,nota
,[status]
,fechaCambio
,EntityTypeId
FROM CodigosClienteAUX;
 
UPDATE Contadores
SET contador = contador + (SELECT MAX(id) FROM CodigosClienteAUX)
WHERE tabla = 'CodigosCliente'
GO
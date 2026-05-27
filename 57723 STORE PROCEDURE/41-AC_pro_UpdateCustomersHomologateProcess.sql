/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Edwin Casa			2026-03-17		58802		Initial Code - Update tables GuiasHouse of transmission process
*/
CREATE OR ALTER PROCEDURE [dbo].[AC_pro_UpdateCustomersHomologateProcess] 
(
	@json VARCHAR(MAX),
	@dateFrom DATETIME,
	@dateTo DATETIME,
	@IdUserLog VARCHAR(16)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			
			CREATE TABLE #RelationToEntities (
				id [VARCHAR](32),
				referenceId [VARCHAR](32),
			)
			CREATE TABLE #EntitiesRelationsTemp (
				id [VARCHAR](32),
				entityTypeId [VARCHAR](32),
				ChildEntityTypeId [VARCHAR](32),
				referenceId [VARCHAR](16)
			)

			INSERT INTO #RelationToEntities
			SELECT 
				c,
				r
			FROM OPENJSON(@json)
			WITH (
				c VARCHAR(50) '$.C',
				r VARCHAR(50) '$.R'
			);

			/*UPDATE REFERENCEID IN EntityRelations TABLE */
		
			UPDATE ER
			SET
				ER.ReferenceId =  RTE.referenceId,
				ER.ModifiedDate = GETDATE(),
				ER.ModifiedBy = @IdUserLog
			FROM EntityRelations ER 
			INNER JOIN #RelationToEntities RTE ON RTE.id = ER.Id
		
			INSERT INTO #EntitiesRelationsTemp
			SELECT 
				ER.Id,
				ER.EntityTypeId,
				ER.ChildEntityTypeId,
				ER.ReferenceId
			FROM EntityRelations ER 
			INNER JOIN #RelationToEntities RTE ON RTE.id = ER.Id

			/* START Update ORIGIN HOMOLOGATE PROCESS */
			UPDATE G
			SET
				G.BillToConsigneeId = ER.Id, 
				G.fechaCambio =  GETDATE(),
				G.idUsuarioLog = @IdUserLog
			FROM Guias G
				INNER JOIN #EntitiesRelationsTemp ER ON ER.ReferenceId =  G.idCliente
			WHERE G.fechaEmbarque BETWEEN @dateFrom AND @dateTo 
				AND G.BillToConsigneeId IS NULL
			/* END Update ORIGIN HOMOLOGATE PROCESS */

			/* START Update DESTINY HOMOLOGATE PROCESS */
			UPDATE GH
				SET 
				GH.ConsigneeId =  ER.ChildEntityTypeId,
				GH.BillToConsigneeId = ER.id,
				GH.fechaCambio = GETDATE(),
				GH.idUsuarioLog =  @IdUserLog
			FROM GuiasHouse GH
				INNER JOIN #EntitiesRelationsTemp ER ON ER.ReferenceId =  GH.idCliente
			WHERE GH.fechaDestino BETWEEN @dateFrom AND @dateTo 
				AND GH.house IS NULL
				AND GH.ConsigneeId IS NULL

			UPDATE GH
			SET
				GH.ConsigneeId = ER.ChildEntityTypeId,
				GH.BillToConsigneeId = ER.Id, 
				GH.fechaCambio =  GETDATE(),
				GH.idUsuarioLog = @IdUserLog
			FROM GuiasHouse GH
				INNER JOIN #EntitiesRelationsTemp ER ON ER.ReferenceId =  GH.idCliente
			WHERE GH.fechaDestino BETWEEN @dateFrom AND @dateTo
				AND GH.house IS NOT NULL
				AND GH.BillToConsigneeId IS NULL

			UPDATE GHD
			SET 
				GHD.BilltoConsigneeId = ER1.id,
				GHD.ShipToId = ER.ChildEntityTypeId,
				GHD.fechaCambio =  GETDATE(),
				GHD.idUsuarioLog = @IdUserLog
			FROM GuiasHouse GH  
				INNER JOIN GuiasHouseDetalles GHD ON GH.Id = GHD.IdGuiaHouse
				INNER JOIN EntityRelations ER1 ON  ER1.ReferenceId =  GH.idCliente
				INNER JOIN #EntitiesRelationsTemp ER  ON ER.EntityTypeId = ER1.EntityTypeId
					AND ER.ReferenceId =  GHD.idClienteFinal
			WHERE GH.fechaDestino  BETWEEN @dateFrom AND @dateTo 
				AND CASE 
					WHEN GHD.BilltoConsigneeId IS NOT NULL AND GHD.ShipToId IS NOT NULL 
					THEN 0
					ELSE 1
				END = 1
			/* END Update DESTINY HOMOLOGATE PROCESS */
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		EXEC dbo.pro_LogError

	END CATCH
END
GO
/*

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL017804","R":"CLI012336"}]',
'20260414 00:00:00','20260428 00:00:00','PImHbTZw'

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL012936","R":"CLI0120245"}]',
'20260414 00:00:00','20260428 00:00:00','PImHbTZw'


EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL074","R":"CLI01690"}]',
'20260414 00:00:00','20260428 00:00:00','PImHbTZw'

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL012339","R":"CLI0420932"}]',
'20260409 00:00:00','20260425 00:00:00','PImHbTZw'

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL013612","R":"CLI0124011"}]',
'20260409 00:00:00','20260425 00:00:00','PImHbTZw'

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL012937","R":"CLI0119075"},{"C":"REL012936","R":"CLI0120245"},{"C":"REL012972","R":"CLI0121560"},{"C":"REL011105","R":"CLI012307"},{"C":"REL017804","R":"CLI012336"},{"C":"REL012933","R":"CLI0123980"},{"C":"REL014098","R":"CLI0129470"},{"C":"REL012458","R":"CLI0420931"},{"C":"REL012339","R":"CLI0420932"},{"C":"REL074","R":"CLI01690"}]',
'20260409 00:00:00','20260425 00:00:00','PImHbTZw'

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL011206","R":"CLI0416383"},{"C":"REL0113152","R":"CLI0116901"},{"C":"REL011669","R":"CLI0116852"},{"C":"REL014276","R":"CLI0131099"},{"C":"REL011209","R":"CLI016596"},{"C":"REL013377","R":"CLI0121652"},{"C":"REL014089","R":"CLI0129181"},{"C":"REL011130","R":"CLI012405"},{"C":"REL011640","R":"CLI0517893"},{"C":"REL011121","R":"CLI0116414"}]',
'20260513 00:00:00','20260525 00:00:00','PImHbTZw'

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL011209","R":"CLI016596"},{"C":"REL011621","R":"CLI0129075"},{"C":"REL011569","R":"CLI0120989"},{"C":"REL0114331","R":"CLI0116912"}]',
'20260513 00:00:00','20260525 00:00:00','PImHbTZw'

EXEC [dbo].[AC_pro_UpdateCustomersHomologateProcess] '[{"C":"REL011209","R":"CLI016596"},{"C":"REL011621","R":"CLI0129075"},{"C":"REL011569","R":"CLI0120989"},{"C":"REL0114331","R":"CLI0116912"},{"C":"REL011669","R":"CLI0116852"},{"C":"REL011520","R":"CLI0127260"},{"C":"REL013959","R":"CLI0128306"},{"C":"REL01258","R":"CLI0127987"},{"C":"REL011210","R":"CLI0112887"},{"C":"REL01264","R":"CLI0130780"},{"C":"REL013377","R":"CLI0121652"},{"C":"REL011496","R":"CLI0127099"},{"C":"REL011160","R":"CLI012359"},{"C":"REL014263","R":"CLI0132225"},{"C":"REL012468","R":"CLI017127"},{"C":"REL01100","R":"CLI0132853"},{"C":"REL0114883","R":"CLI0126443"},{"C":"REL01263","R":"CLI012352"},{"C":"REL011505","R":"CLI0116874"},{"C":"REL019898","R":"CLI017317"},{"C":"REL011130","R":"CLI012405"},{"C":"REL01102","R":"CLI0132855"},{"C":"REL0113152","R":"CLI0116901"},{"C":"REL014276","R":"CLI0131099"},{"C":"REL011109","R":"CLI0128275"},{"C":"REL018700","R":"CLI0126263"},{"C":"REL011642","R":"CLI0116409"},{"C":"REL011214","R":"CLI017357"}]',
'20260513 00:00:00','20260525 00:00:00','PImHbTZw'

*/
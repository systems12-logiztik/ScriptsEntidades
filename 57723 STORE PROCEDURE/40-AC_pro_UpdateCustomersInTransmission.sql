/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			Edwin Casa			2026-03-17		58802		Initial Code - Update tables, GuiasHouse - GuiasHouseDetalles of transmission process

*/
CREATE OR ALTER PROCEDURE [dbo].[AC_pro_UpdateCustomersInTransmission] 
(
	@idGuia VARCHAR(16),
	@IdUserLog VARCHAR(16)
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			/* START Update DESTINY HOMOLOGATE PROCESS */
			UPDATE GH
			SET 
				GH.ConsigneeId =  ER.ChildEntityTypeId,
				GH.fechaCambio = GETDATE(),
				GH.idUsuarioLog =  @IdUserLog
			FROM GuiasHouse GH
				LEFT JOIN EntityRelations ER ON ER.ReferenceId =  GH.idCliente
			WHERE GH.idGuia = @idGuia 
				AND GH.house IS NULL
				AND CASE 
				WHEN GH.BillToConsigneeId IS NOT NULL AND GH.BillToConsigneeId = ER.Id
				THEN  0
				ELSE 1  END  = 1
			
			UPDATE GH
			SET
				GH.ConsigneeId = ER.ChildEntityTypeId,
				GH.BillToConsigneeId = ER.Id, 
				GH.fechaCambio =  GETDATE(),
				GH.idUsuarioLog = @IdUserLog
			FROM GuiasHouse GH
				LEFT JOIN EntityRelations ER ON  ER.ReferenceId =  GH.idCliente
			WHERE GH.idGuia = @idGuia 
				AND GH.house IS NOT NULL
				AND CASE WHEN GH.BillToConsigneeId IS NOT NULL AND  GH.BillToConsigneeId = ER.Id
					THEN  0
					ELSE 1  END  = 1


			UPDATE GHD
			SET 
				GHD.BilltoConsigneeId = ER1.id, 
				GHD.ShipToId = ER.ChildEntityTypeId,
				GHD.fechaCambio =  GETDATE(),
				GHD.idUsuarioLog = @IdUserLog
			FROM GuiasHouse GH  
				INNER JOIN GuiasHouseDetalles GHD ON GH.Id = GHD.IdGuiaHouse
				LEFT JOIN EntityRelations ER1 ON ER1.ReferenceId =  GH.idCliente
				LEFT JOIN EntityRelations ER  ON ER.EntityTypeId = ER1.EntityTypeId
													AND ER.ReferenceId =  GHD.idClienteFinal
			WHERE GH.idGuia =  @idGuia
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

exec [dbo].[AC_pro_UpdateCustomersInTransmission]  'GUI072159668', 'PImHbTZw'

exec [dbo].[AC_pro_UpdateCustomersInTransmission]  'GUI072159673', 'PImHbTZw'

exec [dbo].[AC_pro_UpdateCustomersInTransmission]  'GUI072159686', 'PImHbTZw'

exec [dbo].[AC_pro_UpdateCustomersInTransmission]  'GUI072159704', 'PImHbTZw'

exec [dbo].[AC_pro_UpdateCustomersInTransmission]  'GUI072191020', 'PImHbTZw'

exec [dbo].[AC_pro_UpdateCustomersInTransmission]  'GUI012190699', 'PImHbTZw'

*/
/*
VERSION		MODIFIEDBY				MODIFIEDDATE	HU				MODIFICATION
1			Cristhian Cuichan		2026-03-03		58767			Initial code, store procedure based on pro_GestionarGuiasHoseDetallesOrdenEditada
*/

CREATE OR ALTER   PROCEDURE [dbo].[AC_pro_ManageGuiasHouseDetallesEditedOrder]
(
	@idPoDetallePivot UNIQUEIDENTIFIER,
	@idsPoDetallesActualizados VARCHAR(MAX),
	@idsPoDetallesEliminados VARCHAR(MAX),
	@agregarPiezas BIT
)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;
			--GESTIONAMOS LAS PIEZAS INSERTADAS/ELIMINADAS
			IF(@agregarPiezas = 1)
			BEGIN
			
				DECLARE @idGuiaHouse UNIQUEIDENTIFIER;

				SELECT @idGuiaHouse = GH.id 
				FROM PoDetalles POD
				JOIN PoEncabezado PE ON PE.id = POD.idPo
				JOIN GuiasHouse GH ON CAST(PE.idOrdenLocal AS VARCHAR(128)) = GH.idGuia
				WHERE POD.id = @idPoDetallePivot
				AND GH.house = 'LOCAL';

				SELECT
					PDE.id,
					PE.idCliente,
					PDE.codigoBarra,
					PDE.descripcion,
					PDE.idTipoPieza,
					PDE.idDetalleMercancia,
					PDE.largoCm,
					PDE.anchoCm,
					PDE.altoCm,
					PDE.largoIn,
					PDE.anchoIn,
					PDE.altoIn,
					PDE.unidadesPorPieza,
					PDE.precioTallo,
					PE.nroPo,
					PDE.idUsuarioLog,
					PDE.idClienteFinal,
					PD.ShipToId AS ConsigneeId,
					PDE.ShipToId
				INTO #temporalPoDetalles
				FROM PoDetalles PD
				INNER JOIN PoEncabezado PE ON PD.idPo = PE.id
				INNER JOIN PoDetalles PDE ON PD.idPo =  PDE.idPo
				LEFT JOIN GuiasHouseDetalles GHD ON PDE.id = GHD.idPoDetalle
				WHERE PD.id = @idPoDetallePivot 
					AND PDE.idExportador = PD.idExportador 
					AND PDE.idClienteFinal = PD.idClienteFinal 
					AND PDE.idDetalleMercancia = PD.idDetalleMercancia 
					AND PDE.idTipoPieza = PD.idTipoPieza 
					AND PDE.idCatalogoStatus = PD.idCatalogoStatus 
					AND ((PD.IdDimension IS NULL AND PDE.IdDimension IS NULL) OR (PD.IdDimension IS NOT NULL AND (PDE.IdDimension = PD.IdDimension)))
					AND GHD.id IS NULL;

				INSERT INTO [dbo].[GuiasHouseDetalles]
				(
					[id],
					[idGuiaHouse],
					[codigoBarra],
					[idClienteConsignee],
					[idDetalleMercancia],
					[idTipoDePieza],
					[fechaRecepcion],
					[productoDescripcion],
					[largoCm],
					[anchoCm],
					[altoCm],
					[largoIn],
					[anchoIn],
					[altoIn],
					[totalTallos],
					[precioTallo],
					[peso],
					[po],
					[recepcionEscaner],
					[estadoPieza],
					[inventarioVentas],
					[status],
					[nota],
					[idUsuarioLog],
					[fechaCreacion],
					[fechaCambio],
					[checkError],
					[scanDespacho],
					[impresion],
					[noPermitirVenta],
					[idClienteFinal],
					[idCodigoDeBarra],
					[idPoDetalle],
					[ConsigneeId],
					[ShipToId]
				)
				SELECT NEWID(),               --[id]      
					   @idGuiaHouse,          --,[idGuiaHouse]      
					   PD.codigoBarra,        --,[codigoBarra]      
					   PD.idCliente,          --,[idClienteConsignee]      
					   PD.idDetalleMercancia, --,[idDetalleMercancia]      
					   PD.idTipoPieza,        --,[idTipoDePieza]      
					   NULL,                  --,[fechaRecepcion]      
					   PD.descripcion,        --,[productoDescripcion]      
					   PD.largoCm,            --,[largoCm]      
					   PD.anchoCm,            --,[anchoCm]      
					   PD.altoCm,             --,[altoCm]      
					   PD.largoIn,            --,[largoIn]      
					   PD.anchoIn,            --,[anchoIn]      
					   PD.altoIn,             --,[altoIn]      
					   PD.unidadesPorPieza,   --,[totalTallos]      
					   PD.precioTallo,        --,[precioTallo]      
					   (PD.LargoCm * PD.AnchoCm * PD.AltoCm) / 6000,--,[peso]      
					   PD.nroPo,              --,[po]      
					   0,                     --,[recepcionEscaner]      
					   'PENDING',             --,[estadoPieza]      
					   0,                     --,[inventarioVentas]      
					   'PENDING',             --,[status]      
					   NULL,                  --,[nota]      
					   PD.idUsuarioLog,       --[idUsuarioLog]      
					   GETDATE(),             --,[fechaCreacion]      
					   GETDATE(),             --,[fechaCambio]      
					   0,                     --,[checkError]      
					   0,                     --,[scanDespacho]      
					   0,                     --,[impresion]      
					   0,                     --,[noPermitirVenta]      
					   PD.idClienteFinal,     --,[idClienteFinal]      
					   NULL,                  --[idCodigoDeBarra]      
					   PD.id,                  --,[idPoDetalle])  
					   pd.ConsigneeId,
					   pd.ShipToId
				FROM #temporalPoDetalles PD;

				DROP TABLE #temporalPoDetalles
			END
			ELSE
			BEGIN

				IF(LEN(@idsPoDetallesEliminados) > 0)
				BEGIN
					
					SELECT idPoDetalle AS idPoDetalle
					INTO #temporalPoDetallesEliminar
					FROM
					OPENJSON(@idsPoDetallesEliminados)
					WITH
					(
						idPoDetalle VARCHAR(128) '$.idPoDetalle'
					);

					 --Guardamos la programacion anterior
						INSERT INTO DatosProgramacionAnterior (id,
															   idGuiaHouseDetalle,
															   idCliente,
															   nombreCliente,
															   idCarrier,
															   nombreCarrier,
															   fechaDespacho,
															   fechaCambio,
															   idUsuarioProgramacion,
															   idUsuarioLog,
															   accion,
															   nota)
						SELECT NEWID(),
							GHD.id, 
							GHD.ConsigneeId AS idCliente,
							CASE 
								WHEN C.nombreClienteFinal is not null 
								THEN C.nombreClienteFinal
								ELSE C.nombre
								END AS nombreCliente,
							PC.idCarrier,
							T.nombre AS nombreCarrier,
							PC.fechaDespacho,
							GETDATE() AS fechaCambio,
							PC.idUsuarioLog,
							NULL,
							'E',
							'pro_GestionarGuiasHoseDetallesOrdenEditada'
						FROM #temporalPoDetallesEliminar TPD 	
						INNER JOIN GuiasHouseDetalles GHD ON GHD.idPoDetalle = TPD.idPoDetalle
						INNER JOIN ProgramacionCarrier PC ON GHD.id = PC.idGuiaHouseDetalle
						INNER JOIN Clientes C ON GHD.idClienteFinal = C.id
						INNER JOIN Transportes T ON PC.idCarrier = T.id;

					DELETE PC 
					FROM ProgramacionCarrier PC
					inner join GuiasHouseDetalles GHD on PC.idGuiaHouseDetalle = GHD.id
					INNER JOIN #temporalPoDetallesEliminar TPD ON GHD.idPoDetalle = TPD.idPoDetalle

					DELETE GHD 
					FROM GuiasHouseDetalles GHD
					INNER JOIN #temporalPoDetallesEliminar TPD ON GHD.idPoDetalle = TPD.idPoDetalle;

					DROP TABLE #temporalPoDetallesEliminar
				END
			END

			--GESTIONAMOS LOS DATOS DE LAS PIEZAS ACTUALIZADAS

			IF(LEN(@idsPoDetallesActualizados) > 0)
			BEGIN
				
				SELECT idPoDetalle AS idPoDetalle
				INTO #temporalPoDetallesActualizar
				FROM
				OPENJSON(@idsPoDetallesActualizados)
				WITH
				(
					idPoDetalle VARCHAR(128) '$.idPoDetalle'
				);

				UPDATE GHD
				SET
					[po] = PE.nroPo,
					[idClienteFinal] = PD.idClienteFinal,
					[idDetalleMercancia] = PD.idDetalleMercancia,
					[productoDescripcion] = PD.descripcion,
					[idTipoDePieza] = PD.idTipoPieza,
					[totalTallos] = PD.unidadesPorPieza,
					[largoCm] = PD.largoCm,
					[anchoCm] = PD.anchoCm,
					[altoCm] = PD.altoCm,
					[largoIn] = PD.largoIn,
					[anchoIn] = PD.anchoIn,
					[altoIn] = PD.altoIn,
					[peso] = PD.pesoNeto,
					[fechaCambio] = GETDATE(),
					[idUsuarioLog] = PD.idUsuarioLog,
					[ShipToId] = PD.ShipToId,
					[ConsigneeId] = PE.ConsigneeId
				FROM GuiasHouseDetalles GHD
				INNER JOIN PoDetalles PD ON GHD.idPoDetalle = PD.id
				INNER JOIN #temporalPoDetallesActualizar TPA ON PD.id = TPA.idPoDetalle
				INNER JOIN PoEncabezado PE ON PD.idPo = PE.id;

			DROP TABLE #temporalPoDetallesActualizar;
			END
		COMMIT TRANSACTION;
	END TRY
    BEGIN CATCH
		ROLLBACK TRANSACTION;
		EXEC [dbo].[pro_LogError] 		
    END CATCH;
END

/*
exec sp_executesql N'AC_pro_ManageGuiasHouseDetallesEditedOrder @idPoDetallePivot, @idsPoDetallesActualizados, @idsPoDetallesEliminados, @agregarPiezas',N'@idPoDetallePivot uniqueidentifier,@idsPoDetallesActualizados nvarchar(1101),@idsPoDetallesEliminados nvarchar(2),@agregarPiezas int',@idPoDetallePivot='B1688ECD-A934-4516-A274-00F662AF3A73',@idsPoDetallesActualizados=N'[{"idPoDetalle":"858ffacb-5681-4b73-9e13-3ecdb9414008"},{"idPoDetalle":"c0e012fe-074b-4b48-b627-edc1374985fb"},{"idPoDetalle":"deb334bf-0133-4f38-8353-2214e9f0af8f"},{"idPoDetalle":"74a505cf-1786-4e55-b687-de1996d4052b"},{"idPoDetalle":"00a2de8e-3c67-422d-a0af-9c5c9843a733"},{"idPoDetalle":"6cb7a4cd-a384-4c62-ab9f-59d6d2d05aa4"},{"idPoDetalle":"1a7b8a9f-9173-4e79-b95b-3f60e33b600e"},{"idPoDetalle":"27ba8bf8-c496-49e5-8ee2-b61ec17f6694"},{"idPoDetalle":"4852daa6-de0f-4b1b-80f3-63403580c773"},{"idPoDetalle":"3c6d23a4-a271-4de0-b821-c36901c0f9b9"},{"idPoDetalle":"c44e61d1-8a2c-47cc-8d5b-b5a0dc8e8dd3"},{"idPoDetalle":"e059466c-10f8-461b-b6c7-cddfb661d4a8"},{"idPoDetalle":"b1688ecd-a934-4516-a274-00f662af3a73"},{"idPoDetalle":"b329709a-c2c6-4f0d-9a86-5925f7a4883a"},{"idPoDetalle":"5b6dc1ac-f9d3-4946-9a58-ee2c611eb3d2"},{"idPoDetalle":"2ddc9442-d272-48e0-885f-234b8b582cdf"},{"idPoDetalle":"e0f436ee-9fdc-4e06-9bd2-b44c063ddde8"},{"idPoDetalle":"fd88f05b-3d37-40d9-8803-bbbfbef72449"},{"idPoDetalle":"b2ec2fbf-d015-4bdc-9528-3187a4b38b06"},{"idPoDetalle":"b0ceff55-52e0-4c36-9204-e4c167efd9ad"}]',@idsPoDetallesEliminados=N'[]',@agregarPiezas=1
*/
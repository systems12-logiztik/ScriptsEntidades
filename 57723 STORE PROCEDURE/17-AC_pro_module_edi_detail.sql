/*    
VERSION		MODIFIEDBY			MODIFIEDDATE		HU				MODIFICATION
1			Jesus Yandun		2026-02-13			57732			INITIAL CODE: based on pro_modulo_edi_detalle
*/
CREATE OR ALTER   PROCEDURE [dbo].[AC_pro_ModuleEdiDetail]
	@carrier	   VARCHAR(16),
	@bodega		   VARCHAR(16),
	@fechaDespacho DATETIME,
	@NroDocumento  VARCHAR(32)
AS
BEGIN
	SELECT 
		GHD.id AS Id,
		GH.idGuia AS IdGuia,
		GH.nroGuia AS NroGuia,
		GH.estadoGuia AS EstadoGuia,
		PG.fechaDespacho AS FechaDespacho,
		GHD.estadoPieza AS EstadoPieza,
		ISNULL(SHT.BillToName, SHT.nombre) AS Nombre,
		TR.Nombre AS NombreCarrier, 
		SHT.id AS IdCliente, 
		TR.id AS IdCarrier, 
		bode.id AS IdBodega, 
		PGE.estadoPiezaEdi AS EstadoPiezaEdi, 
		CONVERT(NVARCHAR (50), PGE.idEDI) AS IdEdi
	FROM GuiasHouse GH WITH(NOLOCK)
		INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GH.id = GHD.idGuiaHouse
		INNER JOIN ProgramacionCarrier AS PG WITH(NOLOCK) ON GHD.id = PG.idGuiaHouseDetalle
		INNER JOIN Bodegas bode ON GH.idBodega = bode.id
		INNER JOIN Transportes TR ON PG.idCarrier = TR.id
		INNER JOIN Transportes TRP ON TR.idTransportePrincipal = TRP.id
		INNER JOIN CodigosRelacionSistemas CO ON TR.id = CO.idEntidad and CO.idSistemaEntidad = 100
		INNER JOIN v_ClientsEntities SHT ON GHD.ShipToId = SHT.id
		LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PG.id = PGE.idProgramacionCarrier
	WHERE GH.nroGuia = @NroDocumento
		AND PG.fechaDespacho = @fechaDespacho
		AND PG.idCarrier = @carrier
		AND TRP.envioXML = 1
		AND bode.id = @bodega
END

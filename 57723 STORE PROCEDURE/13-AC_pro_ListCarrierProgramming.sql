/*
VERSION		MODIFIEDBY				MODIFIEDDATE	HU				MODIFICATION
1			Cristhian Cuichan		2026-03-02		58767			Initial code, store procedure based on pro_ListarProgramacionCarrier
*/

CREATE OR ALTER   PROCEDURE [dbo].[AC_pro_ListCarrierProgramming]
(
	@idGuia VARCHAR(128)
)
AS
BEGIN
	DECLARE @idCodigoRelacionSistema INT;

	BEGIN TRY

		SELECT @idCodigoRelacionSistema = (
			SELECT sis.id
			FROM SistemasEntidades sis
			WHERE sis.codigo = 'UNIFICADO'
		);
		
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS Id,
			CONVERT(VARCHAR(36), GHD.id) AS IdGuiaHouseDetalle,
			GH.idGuia,
			CONVERT(VARCHAR(36), GH.id) AS IdGuiaHouse,
			GH.idBodega,
			CDIS.id AS IdClienteDistribucion,
			CDIS.nombre AS NombreClienteDistribucion,
			CFIN.id AS IdClienteFinal,
			CFIN.nombre AS NombreClienteFinal,
			CFIN.nombre AS NombreClienteFinalAlt,
			CONVERT(VARCHAR(36), PM.idManifiestoDespacho) AS IdManifiesto,
			MD.nroManifiesto,
			PC.fechaDespacho,
			T.id AS IdCarrier,
			CC.numeroCuenta AS NumeroCuentaCarrier,
			T.nombre AS NombreCarrier,
			CRS.codigo AS CodigoMiamiCarrier,
			PC.idUsuarioLog,
			T.nombre AS NombresEmpleado,
			PC.fechaCambio
		FROM
			GuiasHouse AS GH WITH (NOLOCK)
			INNER JOIN GuiasHouseDetalles AS GHD WITH (NOLOCK) ON GHD.idGuiaHouse = GH.id AND GHD.estadoPieza <> 'DISPATCHED WH'
			INNER JOIN v_ClientsEntities AS CDIS WITH (NOLOCK) ON ISNULL(GH.BilltoConsigneeId,GH.ConsigneeId) = CDIS.id
			INNER JOIN v_ClientsEntities AS CFIN WITH (NOLOCK) ON ISNULL(GHD.ShipToId,GHD.ConsigneeId) = CFIN.id
			LEFT JOIN ProgramacionCarrier AS PC WITH (NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
			LEFT JOIN ProgramacionManifiesto AS PM WITH (NOLOCK) ON PC.id = PM.idProgramacionCarrier
			LEFT JOIN ManifiestosDespacho AS MD WITH (NOLOCK) ON PM.idManifiestoDespacho = MD.id
			LEFT JOIN Usuarios AS U WITH (NOLOCK) ON PC.idUsuarioLog = U.id
			LEFT JOIN Transportes AS T WITH (NOLOCK) ON PC.idCarrier = T.id			
			OUTER APPLY (
				SELECT cre.codigo
				FROM CodigosRelacionSistemas AS cre WITH (NOLOCK)
				WHERE cre.idSistemaEntidad = @idCodigoRelacionSistema
					AND cre.tipoEntidad = 'CARRIER'
					AND T.id = cre.idEntidad
			) AS CRS
			OUTER APPLY (
				SELECT TOP(1) clienteCuenta.numeroCuenta
				FROM ClientesCarrierCuentas AS clienteCuenta WITH (NOLOCK)
				WHERE clienteCuenta.idCarrier = T.idTransportePrincipal
					AND clienteCuenta.idCliente = CFIN.id
			) AS CC
		WHERE GH.idGuia = @idGuia

	END TRY

    BEGIN CATCH			
		EXEC [dbo].[pro_LogError] 
    END CATCH;
END

/*
EXEC [dbo].[AC_pro_ListCarrierProgramming] @idGuia = '230130WXM0RKWUAV'
EXEC [dbo].[AC_pro_ListCarrierProgramming] @idGuia = '60cd7f82-02eb-4473-92c5-a776c58ed5f4'
EXEC [dbo].[AC_pro_ListCarrierProgramming] @idGuia = 'GUI011299518'
EXEC [dbo].[AC_pro_ListCarrierProgramming] @idGuia = 'GUI011076246'
EXEC [dbo].[AC_pro_ListCarrierProgramming] @idGuia = '76B2488E-BE3A-4971-B1D5-77BC43FE04C4'
EXEC [dbo].[AC_pro_ListCarrierProgramming] @idGuia = 'e3e55129-9cf9-406c-9fa9-08040ff0b387'

*/
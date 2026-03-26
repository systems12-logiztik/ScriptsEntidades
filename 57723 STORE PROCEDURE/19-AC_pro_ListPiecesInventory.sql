/*    
VERSION		MODIFIEDBY			MODIFIEDDATE		HU				MODIFICATION
1			Jes�s Yand�n		2026-02-13			57729			Initial code: Based on pro_ListarPiezasInventarios
*/
CREATE OR ALTER PROCEDURE dbo.AC_pro_ListPiecesInventory
(
    @inventarioVentas BIT,
    @fechaFiltrar DATETIME,
    @idioma VARCHAR(16),
    @idEmpresa VARCHAR(16),
    @billTo VARCHAR(128)
)
AS
BEGIN
	DECLARE @fecha DATE = CAST(@fechaFiltrar AS DATE);

	IF(@billTo != '')
	BEGIN		
		SELECT Id
		INTO #BillTosTemp
		FROM f_SearchEntities(@billTo, 'BillTo');

		SELECT
			ROW_NUMBER() OVER (ORDER BY (SELECT 1)) id,
			[x].[id] idGuiaHouseDetalle,
			GH.[nroGuia], 
			[x].[codigoBarra], 
			PG.[fechaDespacho], 
			TR.[nombre] AS [NombreCarrier], 
			EX.[nombre] AS [NombreExportador], 
			UB.[nombre] AS [NombreubicacionBodega], 
			U.[codigo] AS [NombreUbicacion], 
			CCO.[id] AS [IdClienteConsignee], 
			CCO.BillToName AS [NombreClienteConsignee],
			COG.[id] AS IdClienteDistribucion, 
			COG.nombre AS NombreClienteDistribucion, 
			CF.id AS IdClienteFinal, 
			CF.nombre AS nombreClienteFinal, 
			CF.nombre AS NombreClienteFinalAlt,
			[x].[estadoPieza],
				CASE 
					WHEN @idioma = 'Nombre' THEN t.nombre
					ELSE t.nombreIngles
					END							AS Producto,
			PIN.[fechaCambio] AS [FechaEscaneo], 
			[CC].[cycleCountNumber] AS [TomaInv],
			ISNULL(CI.[abierto], 0) AS [Abierto], 
			CI.[id] AS [IdChequedInventario], 
			[x].[checkError], 
			SV.[nroOrden],
			ISNULL(SVD.[picking], 0) AS [Picking], 
			COALESCE(SV.[instrucionEmbarque], N'''') AS [NotaVenta],
			SVD.[poCliente], 
			M.[nroManifiesto], 
			ISNULL(CASE 
					WHEN @idioma = 'Nombre' THEN [t0].nombre
					ELSE [t0].nombreIngles
					END,'''')						AS NombreCatalogo,
			USU.[nombre] AS nombreUsuario, 
			[x].[fechaCreacion] AS [FechaCreacionGHD],
			SVD.[fechaCambio] AS [FechaCambioSolVentaDetalles], 
			CAST(COALESCE([x].[noPermitirVenta], 0) AS bit) AS [NoPermitirVenta], 
			[x].[fechaRecepcion], 
			[x].[fechaCambio] 
		FROM #BillTosTemp BT
        INNER JOIN v_ClientsEntities V ON BT.Id = V.id
		INNER JOIN [GuiasHouse] AS	GH		WITH(NOLOCK) ON V.id = GH.BillToConsigneeId
		INNER JOIN [GuiasHouseDetalles] AS [x]			WITH(NOLOCK) ON GH.id = [x].idGuiaHouse
		INNER JOIN [Exportadores] AS EX	WITH(NOLOCK) ON GH.[idExportador] = EX.[id]
		INNER JOIN [v_ClientsEntities] AS CCO		ON GH.ConsigneeId = CCO.[Id]
		INNER JOIN [v_ClientsEntities] AS CF		ON [x].ShipToId = CF.[Id]
		INNER JOIN [v_ClientsEntities] AS COG		ON [x].ConsigneeId = COG.[Id]
		INNER JOIN (
			SELECT [w].[id], [w].[nombre], [w].[nombreIngles]
			FROM [DetalleMercancias] AS [w] WITH(NOLOCK)
		) AS [t] ON [x].[idDetalleMercancia] = [t].[id]
		LEFT JOIN [ProgramacionCarrier] AS PG	WITH(NOLOCK) ON [x].[id] = PG.[idGuiaHouseDetalle]
		LEFT JOIN [Transportes] AS TR				WITH(NOLOCK) ON PG.[idCarrier] = TR.[id]
		LEFT JOIN [ProgramacionManifiesto] AS PM WITH(NOLOCK) ON PG.[id] = PM.[idProgramacionCarrier]
		LEFT JOIN [ManifiestosDespacho] AS M		WITH(NOLOCK) ON PM.[idManifiestoDespacho] = M.[id]
		LEFT JOIN [SolicitudDeVentaDetalles] AS SVD	WITH(NOLOCK) ON [x].[id] = SVD.[idGuiaHouseDetalle]
		LEFT JOIN [SolicitudDeVenta] AS SV	WITH(NOLOCK) ON SVD.[idSolicitud] = SV.[id]
		LEFT JOIN [UbicacionPiezas] AS UP	WITH(NOLOCK) ON [x].[id] = UP.[idGuiaHouseDetalle]
		LEFT JOIN [Ubicaciones] AS U			WITH(NOLOCK) ON UP.[idUbicacion] = U.[id]
		LEFT JOIN [UbicacionesBodega] AS UB WITH(NOLOCK) ON U.[idUbicacionBodega] = UB.[id]
		LEFT JOIN [PiezasInventariadas] AS PIN		WITH(NOLOCK) ON [x].[id] = PIN.[IdGuiaHouseDetalle]
		LEFT JOIN [ChequeoInventario] AS CI			WITH(NOLOCK) ON PIN.[IdChequeoInventario] = CI.[id]
		LEFT JOIN [Usuarios] AS USU					WITH(NOLOCK) ON PIN.[IdUsuarioLog] = USU.[id]
		LEFT JOIN (
			SELECT [x0].[id], [x0].[nombre], [x0].[nombreIngles]
			FROM [Catalogos] AS [x0] WITH(NOLOCK)
		) AS [t0] ON CI.[idCatalogos] = [t0].[id]
		OUTER APPLY(SELECT TOP 1 CC.cycleCountNumber 
			FROM CycleCountDetails CCD
			INNER JOIN CycleCounts CC on CC.id =  CCD.idCycleCount 
			WHERE CCD.idItem = [x].[id] AND CCD.scanned = 1
			ORDER BY CC.cycleCountNumber DESC
		) [CC]
		WHERE
			x.fechaCreacion >= @fecha
			AND GH.idEmpresa = @idEmpresa
			AND (
				(@inventarioVentas = 1 AND x.estadoPieza IN ('RECEIVED WH','STANDBY'))
				OR
				(@inventarioVentas = 0 AND x.estadoPieza = 'RECEIVED WH')
			)

		DROP TABLE #BillTosTemp;
	END
	ELSE
	BEGIN
		SELECT
			ROW_NUMBER() OVER (ORDER BY (SELECT 1)) id,
			[x].[id] idGuiaHouseDetalle,
			GH.[nroGuia], 
			[x].[codigoBarra], 
			PG.[fechaDespacho], 
			TR.[nombre] AS [NombreCarrier], 
			EX.[nombre] AS [NombreExportador], 
			UB.[nombre] AS [NombreubicacionBodega], 
			U.[codigo] AS [NombreUbicacion], 
			CCO.[id] AS [IdClienteConsignee], 
			CCO.BillToName AS [NombreClienteConsignee],
			COG.[id] AS IdClienteDistribucion, 
			COG.nombre AS NombreClienteDistribucion, 
			CF.id AS IdClienteFinal, 
			CF.nombre AS nombreClienteFinal, 
			CF.nombre AS NombreClienteFinalAlt,
			[x].[estadoPieza],
				CASE 
					WHEN @idioma = 'Nombre' THEN t.nombre
					ELSE t.nombreIngles
					END							AS Producto,
			PIN.[fechaCambio] AS [FechaEscaneo], 
			[CC].[cycleCountNumber] AS [TomaInv], 
			ISNULL(CI.[abierto], 0) AS [Abierto], 
			CI.[id] AS [IdChequedInventario], 
			[x].[checkError], 
			SV.[nroOrden],
			ISNULL(SVD.[picking], 0) AS [Picking], 
			COALESCE(SV.[instrucionEmbarque], N'''') AS [NotaVenta],
			SVD.[poCliente], 
			M.[nroManifiesto], 
			ISNULL(CASE 
					WHEN @idioma = 'Nombre' THEN [t0].nombre
					ELSE [t0].nombreIngles
					END,'''')						AS NombreCatalogo,
			USU.[nombre] AS nombreUsuario, 
			[x].[fechaCreacion] AS [FechaCreacionGHD],
			SVD.[fechaCambio] AS [FechaCambioSolVentaDetalles], 
			CAST(COALESCE([x].[noPermitirVenta], 0) AS bit) AS [NoPermitirVenta], 
			[x].[fechaRecepcion], 
			[x].[fechaCambio] 
		FROM [GuiasHouse] AS	GH		WITH(NOLOCK) 
		INNER JOIN [GuiasHouseDetalles] AS [x]			WITH(NOLOCK) ON GH.[id] = [x].[idGuiaHouse]
		INNER JOIN [Exportadores] AS EX	WITH(NOLOCK) ON GH.[idExportador] = EX.[id]
		INNER JOIN [v_ClientsEntities] AS CCO		ON GH.ConsigneeId = CCO.[Id]
		INNER JOIN [v_ClientsEntities] AS CF		ON [x].ShipToId = CF.[Id]
		INNER JOIN [v_ClientsEntities] AS COG		ON [x].ConsigneeId = COG.[Id]
		INNER JOIN (
			SELECT [w].[id], [w].[nombre], [w].[nombreIngles]
			FROM [DetalleMercancias] AS [w] WITH(NOLOCK)
		) AS [t] ON [x].[idDetalleMercancia] = [t].[id]
		LEFT JOIN [ProgramacionCarrier] AS PG	WITH(NOLOCK) ON [x].[id] = PG.[idGuiaHouseDetalle]
		LEFT JOIN [Transportes] AS TR				WITH(NOLOCK) ON PG.[idCarrier] = TR.[id]
		LEFT JOIN [ProgramacionManifiesto] AS PM WITH(NOLOCK) ON PG.[id] = PM.[idProgramacionCarrier]
		LEFT JOIN [ManifiestosDespacho] AS M		WITH(NOLOCK) ON PM.[idManifiestoDespacho] = M.[id]
		LEFT JOIN [SolicitudDeVentaDetalles] AS SVD	WITH(NOLOCK) ON [x].[id] = SVD.[idGuiaHouseDetalle]
		LEFT JOIN [SolicitudDeVenta] AS SV	WITH(NOLOCK) ON SVD.[idSolicitud] = SV.[id]
		LEFT JOIN [UbicacionPiezas] AS UP	WITH(NOLOCK) ON [x].[id] = UP.[idGuiaHouseDetalle]
		LEFT JOIN [Ubicaciones] AS U			WITH(NOLOCK) ON UP.[idUbicacion] = U.[id]
		LEFT JOIN [UbicacionesBodega] AS UB WITH(NOLOCK) ON U.[idUbicacionBodega] = UB.[id]
		LEFT JOIN [PiezasInventariadas] AS PIN		WITH(NOLOCK) ON [x].[id] = PIN.[IdGuiaHouseDetalle]
		LEFT JOIN [ChequeoInventario] AS CI			WITH(NOLOCK) ON PIN.[IdChequeoInventario] = CI.[id]
		LEFT JOIN [Usuarios] AS USU					WITH(NOLOCK) ON PIN.[IdUsuarioLog] = USU.[id]
		LEFT JOIN (
			SELECT [x0].[id], [x0].[nombre], [x0].[nombreIngles]
			FROM [Catalogos] AS [x0] WITH(NOLOCK)
		) AS [t0] ON CI.[idCatalogos] = [t0].[id]
		OUTER APPLY(SELECT TOP 1 CC.cycleCountNumber 
			FROM CycleCountDetails CCD
			INNER JOIN CycleCounts CC on CC.id =  CCD.idCycleCount 
			WHERE CCD.idItem = [x].[id] AND CCD.scanned = 1
			ORDER BY CC.cycleCountNumber DESC
		) [CC]
		WHERE
			x.fechaCreacion >= @fecha
			AND GH.idEmpresa = @idEmpresa
			AND (
				(@inventarioVentas = 1 AND x.estadoPieza IN ('RECEIVED WH','STANDBY'))
				OR
				(@inventarioVentas = 0 AND x.estadoPieza = 'RECEIVED WH')
			)
		END;
END;

/*

execute dbo.AC_pro_ListPiecesInventory 0, '12/10/2025 00:00:00', 'Nombre', 'EMP014',NULL
execute dbo.AC_pro_ListPiecesInventory 1, '12/10/2025 00:00:00', 'Nombre', 'EMP014',NULL
execute dbo.AC_pro_ListPiecesInventory 0, '12/10/2025 00:00:00', 'Nombre', 'EMP015',NULL
execute dbo.AC_pro_ListPiecesInventory 1, '12/10/2025 00:00:00', 'Nombre', 'EMP015',NULL
*/
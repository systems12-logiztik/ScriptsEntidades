/*
VERSION		MODIFIEDBY			MODIFIEDDATE	  HU			 MODIFICATION
1			Fernando Ordo�ez	2026-01-26		  57725			 Initial code base on pro_EtiquetaGrandeTempDefaul
*/
CREATE  OR ALTER PROCEDURE [dbo].[AC_pro_LargeLabelTempDefault] (
	@codigos AS XML,
	@tipo AS VARCHAR(32),
	@idUsuarioLogEnviado AS VARCHAR(64)
)
AS
BEGIN
	-- DECLARE @query AS NVARCHAR(MAX);
	DECLARE @tablaCodigos TABLE (idCodigo VARCHAR(128));
	DECLARE @usuarioImprime AS VARCHAR(128);

	CREATE TABLE [dbo].[#Etiqueta](
		carrierAccount			VARCHAR(32) NULL,
		telefonoBodega			NVARCHAR(64) NULL,
		codigoUbicacionBodega	VARCHAR(64) NULL,
		nroGuia					VARCHAR(21) NULL,
		codigoPuertoOrigen		VARCHAR(16) NULL,
		codigoPuertoDestino		VARCHAR(16) NULL,
		nombreExportador		NVARCHAR(256) NULL,
		house					VARCHAR(16) NULL,
		nombreProducto			VARCHAR(64) NULL,
		tipoPieza				VARCHAR(8) NULL,
		unidadesPiezas			INT NULL,
		nroLote					VARCHAR(64) NULL,
		descripcionProducto		VARCHAR(256) NULL,
		nroPo					VARCHAR(64) NULL,
		codigoBarra				VARCHAR(16)  NULL,
		totalPiezas				VARCHAR(16) NULL,
		nombreShipTo			NVARCHAR(512) NULL,
		direccionShipTo			NVARCHAR(512) NULL,
		nombreSubCarrierDestino	VARCHAR(128) NULL,
		diaSemanaDespacho		VARCHAR(16) NULL,
		fechaDespacho			VARCHAR(16) NULL,
		informacionCodigoQr		VARCHAR(MAX) NULL,
		nombreBodegaDestino		NVARCHAR(256) NULL,
		impresion				VARCHAR(16) NULL,
		codigoBarraGrande		VARCHAR(32)  NULL,
		nombreUsuarioCambio		NVARCHAR(65) NULL,
		fueReprogramada			BIT NOT NULL
    ) ON [PRIMARY]

	SET @usuarioImprime = (SELECT
		CASE U.tipoUsuario
		WHEN 'EMPLEADO' THEN  U.nombre
		WHEN 'AGENCIA_CARGA' THEN
			(SELECT nombre FROM v_ClientsEntities WHERE U.EntityTypeId = id)
		WHEN 'CLIENTE' THEN
			(SELECT nombre FROM v_ClientsEntities WHERE U.EntityTypeId = id)
		WHEN 'BILLTO' THEN
			(SELECT nombre FROM v_ClientsEntities WHERE U.EntityTypeId = id)
		WHEN 'CONSIGNEE' THEN
			(SELECT nombre FROM v_ClientsEntities WHERE U.EntityTypeId = id)
		WHEN 'EXPORTADOR' THEN
			(SELECT nombre FROM Exportadores WHERE U.idEntidad = id)
		ELSE
			(SELECT nombre FROM GrupoExportadores WHERE U.idEntidad = id)
		END AS usuario
	FROM Usuarios U
	WHERE U.ID = @idUsuarioLogEnviado);


	IF @tipo = 'TEMPORAL'
	BEGIN
		INSERT INTO @tablaCodigos (idCodigo)   
			SELECT codigosDeBarraXML.codigo.value('.','NVARCHAR(64)') AS idCodigoDeBarra 
			FROM @codigos.nodes('//c') AS codigosDeBarraXML(codigo);

			INSERT INTO #Etiqueta (
			carrierAccount,
			telefonoBodega,
			codigoUbicacionBodega,
			nroGuia,
			codigoPuertoOrigen,
			codigoPuertoDestino,
			nombreExportador,
			house,
			nombreProducto,
			tipoPieza,
			unidadesPiezas,
			nroLote,
			descripcionProducto,
			nroPo,
			codigoBarra,
			totalPiezas,
			nombreShipTo,
			direccionShipTo,
			nombreSubCarrierDestino,
			diaSemanaDespacho,
			fechaDespacho,
			informacionCodigoQr,
			nombreBodegaDestino,
			impresion,
			codigoBarraGrande,
			nombreUsuarioCambio,
			fueReprogramada)
			SELECT 
				ccc.numeroCuenta, 
				bd.telefono,
				'',
				CASE WHEN g.tipoGuia = 'DISTRIBUCION' THEN
				(
					SELECT guiaConsolidada.nroGuia
					FROM guias guiaConsolidada
					WHERE guiaConsolidada.id = g.idGuiaConsolidada
				) 
				ELSE 
					g.nroGuia
				END nroGuia, 
				po.codigo,
				pd.codigo,
				ex.razonSocial,
				coo.house,
				dm.nombre,
				itc.empaque,
				IIF(itc.unidades IS NOT NULL, CAST(itc.unidades AS INT ), ''),
				NULL,--[nroLote]
				itc.descripcionVariedad,
				itc.po,
				itc.codigoPieza,
				NULL, --[totalPiezas]

				IIF((SELECT TOP 1 valor FROM ParametrosCatalogos pc
						INNER JOIN ParametrosLista pl ON pc.idParametroLista = pl.id
					WHERE pc.idEntidad = g.ConsigneeId AND pl.idEmpresa = g.idEmpresa AND pl.codigo = 'TipoServicio') = 'COMERCIALIZADORA',
						vcd.nombre,
				IIF (vst.id IS NOT NULL, IIF(vst.Nombre IS NULL, vst.BillToName, vst.Nombre), IIF(vcd.Nombre IS NULL, vcd.BillToName, vcd.Nombre))),
			
				IIF((SELECT TOP 1 valor FROM ParametrosCatalogos pc
						INNER JOIN ParametrosLista pl ON pc.idParametroLista = pl.id
					WHERE pc.idEntidad = g.ConsigneeId AND pl.idEmpresa = g.idEmpresa AND pl.codigo = 'TipoServicio') = 'COMERCIALIZADORA',
			
				CONCAT(SUBSTRING(ccd.nombre, 0, 16) + ' ', ecd.codigoISO, ISNULL(', ' + vcd.codigozip, '')),
				CASE WHEN vst.id IS NOT NULL 
					THEN IIF(vst.Nombre IS NOT NULL, CONCAT(SUBSTRING(cst.Nombre, 0, 16) + ' ', est.codigoISO, ISNULL(', ' + vst.codigozip, '')), CONCAT(SUBSTRING(cst.Nombre ,0, 16) + ' ', est.codigoISO, ISNULL(', ' + vst.codigozip, '')))
					WHEN vst.id IS NULL 
					THEN IIF(vcd.Nombre IS NOT NULL, CONCAT(SUBSTRING(ccd.Nombre,0, 16)+ ' ', ecd.codigoISO, ISNULL(', ' + vcd.codigozip, '')), CONCAT(SUBSTRING(ccd.Nombre,0, 16) + ' ', ecd.codigoISO, ISNULL(', ' + vcd.codigozip,''))) END),

				subCarrier.nombre,
				IIF(itc.fecha_transportador IS NULL,'', UPPER(FORMAT(itc.fecha_transportador, 'ddd','en-us'))),
				IIF(itc.fecha_transportador IS NULL,'', UPPER(FORMAT(itc.fecha_transportador, 'dd-MMM','en-us'))),
				NULL, --[informacionCodigoQr]
				bd.Nombre,
				0,
				--obtenci�n de codigo de barra de m�s de 11 d�gitos si existe
				(SELECT TOP 1 codInfo.codigoBarraEntidad FROM CodigosDeBarrasInfoAdicional AS codInfo 
					WHERE codInfo.codigoBarra=itc.codigoPieza
					ORDER BY codInfo.fechaCreacion DESC) AS codigoBarraGrande,
				@usuarioImprime,
				0
			FROM						
				Guias g WITH (NOLOCK)
				INNER JOIN Puertos po ON po.id = g.idPuertoOrigen
				INNER JOIN Puertos pd ON pd.id = g.idPuertoDestino
				INNER JOIN v_ClientsEntities vcd ON ISNULL(g.ConsigneeId, g.BillToConsigneeId)= vcd.id
				INNER JOIN Ciudades ccd ON vcd.idCiudad = ccd.id
				INNER JOIN Estados ecd ON vcd.idEstado = ecd.id
				INNER JOIN Coordinaciones coo WITH (NOLOCK) ON g.id =coo.idGuia
				INNER JOIN Exportadores ex ON coo.idExportador = ex.id
				INNER JOIN InventarioTemporalCliente itc WITH (NOLOCK) ON coo.id = itc.idCoordinacion
				LEFT JOIN Bodegas bd ON g.idBodegaDestino = bd.id
				LEFT OUTER JOIN CodigosRelacionSistemas crsP ON (itc.codigoProducto = crsp.codigo AND crsp.idSistemaEntidad = 100 AND crsp.tipoEntidad = 'MERCANCIAS')
				LEFT OUTER JOIN DetalleMercancias dm ON crsP.idEntidad = dm.id 
				LEFT OUTER JOIN CodigosRelacionSistemas crsT ON (itc.caja_transportador = crsT.codigo AND crsT.idSistemaEntidad = 100 AND crsT.tipoEntidad = 'CARRIER')
				LEFT OUTER JOIN Transportes subCarrier ON crsT.idEntidad = subCarrier.id 
				LEFT OUTER JOIN Transportes carrier ON subCarrier.idTransportePrincipal = carrier.id
				LEFT OUTER JOIN CodigosRelacionSistemas crs ON (itc.codigoCliente = crs.codigo AND crs.idSistemaEntidad = 100 AND crs.tipoEntidad = 'BILLTOCONSIGNEE')
				LEFT OUTER JOIN v_ClientsEntities vst ON crs.EntityReferenceId = vst.id 
				LEFT OUTER JOIN Ciudades cst ON vst.idCiudad=cst.id
				LEFT OUTER JOIN Estados est ON vst.idEstado=est.id
				LEFT OUTER JOIN ClientesCarrierCuentas ccc ON vst.id = ccc.EntityTypeId AND carrier.id = ccc.idCarrier
			WHERE itc.id IN (SELECT idCodigo FROM @tablaCodigos WHERE LEN(idCodigo) = 36)
		
			UPDATE  #Etiqueta
			SET     totalPiezas = Cnt
			FROM    #Etiqueta AS ss
				INNER JOIN (SELECT house, COUNT(1) AS Cnt FROM #Etiqueta GROUP BY house) AS s
					ON ss.house = s.house 

			SELECT 
				ROW_NUMBER() OVER (PARTITION BY house ORDER BY house, nombreShipto, nombreProducto,descripcionProducto ASC) AS pagina,--CONTADOR DE ETIQUETAS
				[carrierAccount],
				[codigoUbicacionBodega],
				[nroGuia],
				[codigoPuertoOrigen],
				[codigoPuertoDestino],
				[nombreExportador],
				[house],
				[nombreProducto],
				[tipoPieza],
				[unidadesPiezas],
				[nroLote],
				[descripcionProducto],
				[nroPo],
				[codigoBarra],
				[totalPiezas],
				[nombreShipTo],
				[direccionShipTo],
				[nombreSubCarrierDestino],
				[diaSemanaDespacho],
				[fechaDespacho],
				('BARCODE: ' + ISNULL([codigoBarraGrande],[codigoBarra]) +
				'; HAWB: ' + [house] + 
				'; ORIGIN: ' + [codigoPuertoOrigen] +
				'; PO: ' + ISNULL([nroPo],'') + 
				'; LOT: ' + ISNULL([nroLote],'') + 
				'; SUPPLIER: ' + [nombreExportador] + 
				'; PRODUCT: ' + [nombreProducto] + 
				'; DESCRIPTION: ' + ISNULL([descripcionProducto],'') + 
				'; SIZE: ' + [tipoPieza] + 
				'; PACK: ' + ISNULL(CAST([unidadesPiezas] AS VARCHAR(16)),'') + 
				'; SHIP-TO: ' + [nombreShipTo] + 
				'; ADDRESS: ' + [direccionShipTo] + 
				'; SHIPPING: ' + ISNULL([fechaDespacho],'')) AS informacionCodigoQr,
				[nombreBodegaDestino],
				[nombreTelefonoConcatenado] = IIF([nombreBodegaDestino] IS NOT NULL, CONCAT(SUBSTRING([nombreBodegaDestino],0, 35),' (',IIF([telefonoBodega] IS NULL OR LEN([telefonoBodega]) <= 0,' ',SUBSTRING([telefonoBodega],1,3) + '-' + SUBSTRING([telefonoBodega],4,3) + ' ' + SUBSTRING([telefonoBodega],7,64)),')'),''),
				IIF(impresion>0,'R*','') AS impresion,
				[nombreUsuarioCambio]
			FROM #Etiqueta
		END;
		IF @tipo = 'CODIGOBARRAS'
		BEGIN
			INSERT INTO @tablaCodigos (idCodigo)   
			SELECT codigosDeBarraXML.codigo.value('.','NVARCHAR(16)') AS idCodigoDeBarra 
			FROM @codigos.nodes('//c') AS codigosDeBarraXML(codigo);

			INSERT INTO #Etiqueta (
			[carrierAccount],
			[telefonoBodega],
			[codigoUbicacionBodega],
			[nroGuia],
			[codigoPuertoOrigen],
			[codigoPuertoDestino],
			[nombreExportador],
			[house],
			[nombreProducto],
			[tipoPieza],
			[unidadesPiezas],
			[nroLote],
			[descripcionProducto],
			[nroPo],
			[codigoBarra],
			[totalPiezas],
			[nombreShipTo],
			[direccionShipTo],
			[nombreSubCarrierDestino],
			[diaSemanaDespacho],
			[fechaDespacho],
			[informacionCodigoQr],
			[nombreBodegaDestino],
			[impresion],
			[codigoBarraGrande],
			[nombreUsuarioCambio],
			[fueReprogramada])
			SELECT 
				ccc.numeroCuenta, 
				bd.telefono,
				'',
				CASE WHEN g.tipoGuia = 'DISTRIBUCION' THEN
					(SELECT       guiaConsolidada.nroGuia
					FROM            guias guiaConsolidada
					WHERE        guiaConsolidada.id = g.idGuiaConsolidada) ELSE g.nroGuia
				END AS nroGuia, 
				po.codigo,
				pd.codigo,
				ex.razonSocial,
				co.house,
				dm.nombre,
				cb.tipoPiezaInventario,
				IIF(cb.unidades IS NOT NULL, CAST(cb.unidades AS INT ), ''),
				NULL,--[nroLote]
				cb.descripcionVariedad,
				cb.po,
				cb.codigoBarra,
				NULL, --[totalPiezas]
				IIF (vst.id IS NOT NULL, IIF(vst.Nombre IS NULL, vst.BillToName, vst.Nombre), IIF (vcd.Nombre IS NULL, vcd.BillToname, vcd.Nombre)),
			
				CASE WHEN vst.id IS NOT NULL 
					THEN IIF(vst.Nombre IS NOT NULL, CONCAT(SUBSTRING(cst.Nombre, 0, 16) + ' ', est.codigoISO, ISNULL(', ' + vst.codigozip, '')), CONCAT(SUBSTRING(cst.Nombre, 0, 16) + ' ', est.codigoISO, ISNULL(', ' + vst.codigozip, '')))
					WHEN vst.id IS NULL 
					THEN IIF(vcd.Nombre IS NOT NULL, CONCAT(SUBSTRING(ccd.Nombre, 0, 16) + ' ', ecd.codigoISO, ISNULL(', ' + vcd.codigozip ,'')), CONCAT(SUBSTRING(ccd.Nombre, 0, 16) + ' ', ecd.codigoISO, ISNULL(', ' + vcd.codigozip, ''))) END,
				sc.nombre,
				IIF(cb.caja_fecha_transportador IS NULL,'', UPPER(FORMAT(cb.caja_fecha_transportador,'ddd','en-us'))),
				IIF(cb.caja_fecha_transportador IS NULL,'', UPPER(FORMAT(cb.caja_fecha_transportador,'dd-MMM','en-us'))),
				NULL, --[informacionCodigoQr]
				bd.nombre,
				0,
				--obtenci�n de codigo de barra de m�s de 11 d�gitos si existe
				(SELECT TOP 1 codInfo.codigoBarraEntidad FROM CodigosDeBarrasInfoAdicional AS codInfo 
					WHERE codInfo.codigoBarra=cb.codigoBarra
					ORDER BY codInfo.fechaCreacion DESC) AS codigoBarraGrande,
				@usuarioImprime,
				0	
			FROM						
				Guias g WITH (NOLOCK)
				INNER JOIN Puertos po ON g.idPuertoOrigen = po.id
				INNER JOIN Puertos pd ON g.idPuertoDestino = pd.id
				INNER JOIN v_ClientsEntities vcd ON ISNULL(g.ConsigneeId, g.BillToConsigneeId) = vcd.id
				INNER JOIN Ciudades ccd ON vcd.idCiudad = ccd.id
				INNER JOIN Estados ecd ON vcd.idEstado = ecd.id
				INNER JOIN Coordinaciones co WITH (NOLOCK) ON g.id = co.idGuia
				INNER JOIN Exportadores ex ON co.idExportador = ex.id
				INNER JOIN CodigosDeBarra cb WITH (NOLOCK) ON co.id = cb.idCoordinacion
				LEFT JOIN Bodegas bd ON g.idBodegaDestino = bd.id
				LEFT OUTER JOIN CodigosRelacionSistemas crsP ON (cb.codigoProducto = crsP.codigo AND crsP.idSistemaEntidad = 100 AND crsP.tipoEntidad = 'MERCANCIAS')
				LEFT OUTER JOIN DetalleMercancias dm ON crsP.idEntidad = dm.id 
				LEFT OUTER JOIN CodigosRelacionSistemas crsSubCarrier ON (cb.caja_transportador = crsSubCarrier.codigo AND crsSubCarrier.idSistemaEntidad = 100 AND crsSubCarrier.tipoEntidad = 'CARRIER')
				LEFT OUTER JOIN Transportes sc ON crsSubCarrier.idEntidad = sc.id 
				LEFT OUTER JOIN Transportes carrier  ON sc.idTransportePrincipal = carrier.id
				LEFT OUTER JOIN CodigosRelacionSistemas crs ON (cb.codigoCliente = crs.codigo AND crs.idSistemaEntidad = 100 AND crs.tipoEntidad = 'BILLTOCONSIGNEE')
				LEFT OUTER JOIN v_ClientsEntities vst ON crs.EntityReferenceId = vst.id 
				LEFT OUTER JOIN Ciudades cst ON vst.idCiudad = cst.id 
				LEFT OUTER JOIN Estados est ON vst.idEstado = est.id
				LEFT OUTER JOIN ClientesCarrierCuentas ccc ON vst.id = ccc.EntityTypeId AND carrier.id = ccc.idCarrier
			WHERE cb.id IN (SELECT idCodigo FROM @tablaCodigos WHERE LEN(idCodigo) < 36)

			UPDATE  #Etiqueta
			SET     totalPiezas = Cnt
			FROM    #Etiqueta AS ss
				INNER JOIN (SELECT house, COUNT(1) AS Cnt FROM #Etiqueta GROUP BY house) AS s
					ON ss.house = s.house 

			SELECT 
				ROW_NUMBER() OVER (PARTITION BY house ORDER BY house, nombreShipto,nombreProducto,descripcionProducto ASC) AS pagina,--CONTADOR DE ETIQUETAS
			
				[carrierAccount],
				[codigoUbicacionBodega],
				[nroGuia],
				[codigoPuertoOrigen],
				[codigoPuertoDestino],
				[nombreExportador],
				[house],
				[nombreProducto],
				[tipoPieza],
				[unidadesPiezas],
				[nroLote],
				[descripcionProducto],
				[nroPo],
				[codigoBarra],
				[totalPiezas],
				[nombreShipTo],
				[direccionShipTo],
				[nombreSubCarrierDestino],
				[diaSemanaDespacho],
				[fechaDespacho],
				('BARCODE: ' + ISNULL([codigoBarraGrande],[codigoBarra]) +
				'; HAWB: ' + [house] + 
				'; ORIGIN: ' + [codigoPuertoOrigen] + 
				'; PO: ' + ISNULL([nroPo],'') + 
				'; LOT: ' + ISNULL([nroLote],'') + 
				'; SUPPLIER: ' + [nombreExportador] + 
				'; PRODUCT: ' + [nombreProducto] + 
				'; DESCRIPTION: ' + ISNULL([descripcionProducto],'') + 
				'; SIZE: ' + [tipoPieza] + 
				'; PACK: ' + ISNULL(CAST([unidadesPiezas] AS VARCHAR(16)),'') + 
				'; SHIP-TO: ' + [nombreShipTo] + 
				'; ADDRESS: ' + [direccionShipTo] + 
				'; SHIPPING: ' + ISNULL([fechaDespacho],'')) AS informacionCodigoQr,
				[nombreBodegaDestino],
				[nombreTelefonoConcatenado] = IIF([nombreBodegaDestino] IS NOT NULL, CONCAT(SUBSTRING([nombreBodegaDestino], 0, 35),' (',IIF([telefonoBodega] IS NULL OR LEN([telefonoBodega]) <= 0, ' ', SUBSTRING([telefonoBodega], 1, 3) + '-' + SUBSTRING([telefonoBodega], 4, 3) + ' ' + SUBSTRING([telefonoBodega], 7, 64)), ')'), ''),
				IIF(impresion>0, 'R*', '') AS impresion,
				[nombreUsuarioCambio]
			FROM #Etiqueta
		END;
		IF @tipo = 'REAL'
		BEGIN
			INSERT INTO @tablaCodigos (idCodigo)   
			SELECT codigosDeBarraXML.codigo.value('.','NVARCHAR(64)') AS idCodigoDeBarra 
			FROM @codigos.nodes('//c') AS codigosDeBarraXML(codigo);

			INSERT INTO #Etiqueta (
				carrierAccount,
				telefonoBodega,
				codigoUbicacionBodega,
				nroGuia,
				codigoPuertoOrigen,
				codigoPuertoDestino,
				nombreExportador,
				house,
				nombreProducto,
				tipoPieza,
				unidadesPiezas,
				nroLote,
				descripcionProducto,
				nroPo,
				codigoBarra,
				totalPiezas,
				nombreShipTo,
				direccionShipTo,
				nombreSubCarrierDestino,
				diaSemanaDespacho,
				fechaDespacho,
				informacionCodigoQr,
				nombreBodegaDestino,
				impresion,
				codigoBarraGrande,
				nombreUsuarioCambio,
				fueReprogramada)
			SELECT 
				ccc.numeroCuenta, 
				b.telefono,
				u.codigo,
				gh.nroGuia,
				co.codigoISO,
				cd.codigoISO,
				ex.razonSocial,
				gh.house,
				dm.nombre,
				tp.tipoPieza,
				IIF(ghd.totalTallos IS NOT NULL, CAST(ghd.totalTallos AS INT ), ''), 
				NULL,--[nroLote]
				ghd.productoDescripcion,
				ghd.po,
				ghd.codigoBarra,
				NULL, --[totalPiezas]
				IIF (vcd.id IS NOT NULL, IIF(vst.Nombre IS NULL, vst.BillToName, vst.Nombre), IIF(vcd.Nombre IS NULL, vcd.BillToName,vcd.Nombre)),
				CASE WHEN vst.id IS NOT NULL 
					THEN IIF(vst.Nombre IS NOT NULL, CONCAT(SUBSTRING(cst.nombre, 0, 16) + ' ', est.codigoISO, ISNULL(', ' + vst.codigozip, '')), CONCAT(SUBSTRING(cst.Nombre,0, 16) + ' ', est.codigoISO, ISNULL(', ' + vst.codigozip, '')))
					WHEN vst.id IS NULL 
					THEN IIF(vcd.Nombre IS NOT NULL, CONCAT(SUBSTRING(ccd.Nombre, 0, 16) + ' ', ecd.codigoISO, ISNULL(', ' + vcd.codigozip, '')), CONCAT(SUBSTRING(ccd.Nombre,0, 16) + ' ', ecd.codigoISO, ISNULL(', ' + vcd.codigozip, ''))) END,
				sc.nombre,
				IIF(pc.fechaDespacho IS NULL, '', UPPER(FORMAT(pc.fechaDespacho, 'ddd', 'en-us'))),
				IIF(pc.fechaDespacho IS NULL, '', UPPER(FORMAT(pc.fechaDespacho, 'dd-MMM', 'en-us'))),
				NULL, --[informacionCodigoQr]
				b.nombre,
				ghd.impresion,
				--obtenci�n de codigo de barra de m�s de 11 d�gitos si existe
				(SELECT TOP 1 codInfo.codigoBarraEntidad FROM CodigosDeBarrasInfoAdicional codInfo 
					WHERE codInfo.codigoBarra=ghd.codigoBarra
					ORDER BY codInfo.fechaCreacion DESC) AS codigoBarraGrande,
				@usuarioImprime,
				IIF (pc.esProgramacionCliente IS NOT NULL, pc.esProgramacionCliente, 0) fueReprogramada			 
			FROM GuiasHouseDetalles ghd WITH (NOLOCK)
				INNER JOIN DetalleMercancias dm ON ghd.idDetalleMercancia = dm.id
				INNER JOIN TiposDePieza tp ON ghd.idTipoDePieza=tp.id
				INNER JOIN GuiasHouse gh WITH (NOLOCK) ON ghd.idGuiaHouse= gh.id
				INNER JOIN Ciudades co ON gh.idCiudadPuertoOrigen=co.id
				INNER JOIN Ciudades cd ON gh.idCiudadPuertoDestino=cd.id
				INNER JOIN Exportadores ex ON gh.idExportador=ex.id
				INNER JOIN Bodegas b ON gh.idBodega=b.id
				INNER JOIN v_ClientsEntities vcd ON ISNULL(gh.ConsigneeId, gh.BilltoConsigneeId) = vcd.id
				INNER JOIN Ciudades ccd ON vcd.idCiudad=ccd.id
				INNER JOIN Estados ecd ON vcd.idEstado=ecd.id
				LEFT OUTER JOIN ProgramacionCarrier pc WITH (NOLOCK) ON ghd.id=pc.idGuiaHouseDetalle
				LEFT OUTER JOIN Transportes sc ON pc.idCarrier=sc.id
				LEFT OUTER JOIN Transportes t  ON sc.idTransportePrincipal = t.id
				LEFT OUTER JOIN v_ClientsEntities vst ON ghd.shipToId=vst.id
				LEFT OUTER JOIN Ciudades cst ON vst.idCiudad = cst.id
				LEFT OUTER JOIN Estados est ON vst.idEstado = est.id
				LEFT OUTER JOIN UbicacionPiezas up ON ghd.id = up.idGuiaHouseDetalle
				LEFT OUTER JOIN Ubicaciones u ON up.idUbicacion = u.id
				LEFT OUTER JOIN ClientesCarrierCuentas ccc ON vst.id = ccc.EntityTypeId AND t.id = ccc.idCarrier
			WHERE ghd.id IN (SELECT idCodigo FROM @tablaCodigos WHERE LEN(idCodigo) = 36)
		
			UPDATE  #Etiqueta
			SET     totalPiezas = Cnt
			FROM    #Etiqueta AS ss
				INNER JOIN (SELECT house, COUNT(1) AS Cnt FROM #Etiqueta GROUP BY house) AS s
					ON ss.house = s.house 

			SELECT 
				ROW_NUMBER() OVER (PARTITION BY house ORDER BY house, nombreShipto, nombreProducto,descripcionProducto ASC) AS pagina,--CONTADOR DE ETIQUETAS
				[carrierAccount],
				[codigoUbicacionBodega],
				[nroGuia],
				[codigoPuertoOrigen],
				[codigoPuertoDestino],
				[nombreExportador],
				[house],
				[nombreProducto],
				[tipoPieza],
				[unidadesPiezas],
				[nroLote],
				[descripcionProducto],
				[nroPo],
				[codigoBarra],
				[totalPiezas],
				[nombreShipTo],
				[direccionShipTo],
				[nombreSubCarrierDestino],
				[diaSemanaDespacho],
				[fechaDespacho],
				('BARCODE: ' + ISNULL([codigoBarraGrande],[codigoBarra]) + 
				'; HAWB: ' + [house] + 
				'; ORIGIN: ' + [codigoPuertoOrigen] + 
				'; PO: ' + ISNULL([nroPo],'') + 
				'; LOT: ' + ISNULL([nroLote],'') + 
				'; SUPPLIER: ' + [nombreExportador] + 
				'; PRODUCT: ' + [nombreProducto] + 
				'; DESCRIPTION: ' + ISNULL([descripcionProducto],'') + 
				'; SIZE: ' + [tipoPieza] + 
				'; PACK: ' + ISNULL(CAST([unidadesPiezas] AS VARCHAR(16)),'') + 
				'; SHIP-TO: ' + [nombreShipTo] + 
				'; ADDRESS: ' + [direccionShipTo] + 
				'; SHIPPING: ' + ISNULL([fechaDespacho],'')) AS informacionCodigoQr,
				[nombreBodegaDestino],
				[nombreTelefonoConcatenado] = IIF([nombreBodegaDestino] IS NOT NULL, CONCAT(SUBSTRING([nombreBodegaDestino],0, 35),' (',IIF([telefonoBodega] IS NULL OR LEN([telefonoBodega]) <= 0,' ',SUBSTRING([telefonoBodega],1,3) + '-' + SUBSTRING([telefonoBodega],4,3) + ' ' + SUBSTRING([telefonoBodega],7,64)),')'),''),
				IIF(fueReprogramada > 0, 'C*',IIF(impresion>1,'R*', '')) AS impresion,
				[nombreUsuarioCambio]
			FROM #Etiqueta
		END;
	DROP TABLE #Etiqueta
END

/*

declare @p1 xml
set @p1=convert(xml,N'<codigos><c>3F3472E3-1151-4134-A3A3-D37C511B4771</c></codigos>')
exec dbo.AC_pro_LargeLabelTempDefault @codigos=@p1,@tipo='REAL',@idUsuarioLogEnviado='iUQ5sJFD'


declare @p1 xml
set @p1=convert(xml,N'<codigos><c>B88E6AD4-584E-45BA-BA20-CC5688A7673B</c><c>F65FBF12-4EF0-47B8-BBDD-DCF7D7D36AC5</c><c>761A8398-BD2C-4DC2-A104-0BF52A775030</c></codigos>')
exec dbo.AC_pro_LargeLabelTempDefault @codigos=@p1,@tipo='TEMPORAL',@idUsuarioLogEnviado='iUQ5sJFD'


declare @p1 xml
set @p1=convert(xml,N'<codigos><c>CDB0325300617</c><c>CDB0325300616</c><c>CDB0925326680</c></codigos>')
exec dbo.AC_pro_LargeLabelTempDefault @codigos=@p1,@tipo='CODIGOBARRAS',@idUsuarioLogEnviado='iUQ5sJFD'

*/


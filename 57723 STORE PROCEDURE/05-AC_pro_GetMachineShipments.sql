/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU			MODIFICATION
1			José Ganchozo		2026-01-04		53095		Add BillToName filter and Change table Clientes to v_ClientsEntities. SP based on pro_ListaEmbarqueMaquina
*/

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetMachineShipments]
(
	@fechaInicio		DATE,
	@fechaFinal			DATE,
	@idEmpresa			VARCHAR(16),
	@idClienteFinal		VARCHAR(16),
	@idGuia				VARCHAR(128),
	@nombreClienteFinal	NVARCHAR(MAX),
	@house				NVARCHAR(MAX),
	@estado				XML,
	@nombreExportador	NVARCHAR(MAX),
	@station			VARCHAR(16),
	@soloEstacion		BIT,
	@nombreBillTo		VARCHAR(128)
)
AS
BEGIN 

	DECLARE @prefijo VARCHAR(32),
			@sql_script NVARCHAR(MAX),
			@parametros NVARCHAR(MAX) = N'@fechaInicio DATETIME, @fechaFinal DATETIME, @idClienteFinal VARCHAR(16),
										 @idGuia VARCHAR(128), @nombreClienteFinal VARCHAR(512), @house VARCHAR(32),
										 @nombreExportador VARCHAR(512), @station VARCHAR(32), @prefijo VARCHAR(32), 
										 @idEmpresa VARCHAR(16), @nombreBillTo VARCHAR(128)'

	SELECT @prefijo = pg.Valor 
	FROM ParametrosGenerales pg
    WHERE pg.Codigo ='UbicacionSortingMachine'
	  AND pg.IdEmpresa = @idEmpresa
		
	/*almacena la consulta con los campos minimos*/
	CREATE TABLE #tmpBasico (
		idRow				INT,
		idClienteFinal		VARCHAR(16),
		codigoBarra			VARCHAR(32),
		idGuiaHouseDetalle	UNIQUEIDENTIFIER,
		estadoPieza			VARCHAR(64),
		station				VARCHAR(8),
		fechaRecepcion		DATETIME,
		fechaDestino		DATETIME,
		nroGuia				VARCHAR(32),
		totalPcsHouse		INT,
		nota				VARCHAR(256),
		idGuia				VARCHAR(128),
		house				VARCHAR(32),
		idGuiaHouse			UNIQUEIDENTIFIER,
		idExportador		VARCHAR(16),
		idBodega			VARCHAR(16)
	)
	
	CREATE TABLE #estados (
		estado VARCHAR (32)
	)

	IF(@estado IS NOT NULL)
		BEGIN
			INSERT INTO #estados
			SELECT [Value] 
			FROM [dbo].fnObtenerValoresXML(@estado)
		END
	
	SELECT @sql_script = CONCAT(N'SELECT 
        ROW_NUMBER() OVER(ORDER BY ghd.ShipToId) as fila,
        ghd.ShipToId idClienteFinal, 
        ghd.codigoBarra,        
        ghd.id,
        ghd.estadoPieza,
        ghd.station,
        ghd.fechaRecepcion,
        gh.fechaDestino, 
        gh.nroGuia,
        gh.totalPcsHouse,
        gh.notaHouse,
        gh.idGuia,
        gh.house,
        gh.id,        
        gh.idExportador,
        gh.idBodega
    FROM GuiasHouse gh WITH (NOLOCK)
        INNER JOIN GuiasHouseDetalles ghd (NOLOCK) ON gh.id = ghd.idGuiaHouse',
        CASE WHEN @nombreClienteFinal <> '' THEN ' INNER JOIN f_SearchEntities(@nombreClienteFinal, ''Consignee'') cl ON ghd.ShipToId = cl.id' END,
        CASE WHEN @nombreBillTo <> '' THEN ' INNER JOIN f_SearchEntities(@nombreBillTo, ''BillTo'') bt ON gh.BillToConsigneeId = bt.id' END,
        CASE WHEN @nombreExportador <> '' THEN ' LEFT JOIN Exportadores e (NOLOCK) ON gh.idExportador = e.id' END,
    '
    WHERE gh.fechaDestino BETWEEN @fechaInicio AND @fechaFinal AND gh.idEmpresa = @idEmpresa',
         CASE WHEN @idGuia <> '' THEN ' AND gh.idGuia = @idGuia' END,
         CASE WHEN @house <> '' THEN ' AND gh.house LIKE CONCAT(''%'', @house, ''%'')' END,
         CASE WHEN @idClienteFinal <> '' THEN ' AND ghd.ShipToId = @idClienteFinal' END,
         CASE WHEN @nombreExportador <> '' THEN ' AND e.nombre LIKE CONCAT(''%'', @nombreExportador, ''%'')' END,
         CASE WHEN EXISTS(SELECT 1 FROM #estados) THEN ' AND ghd.estadoPieza IN (SELECT estado FROM #estados)' END)

	INSERT INTO #tmpBasico
	EXEC SP_EXECUTESQL @sql_script, @parametros, @fechaInicio = @fechaInicio, @fechaFinal = @fechaFinal,
		@idClienteFinal = @idClienteFinal, @idGuia = @idGuia, @nombreClienteFinal = @nombreClienteFinal,
		@house = @house, @nombreExportador = @nombreExportador, @station = @station, @prefijo = @prefijo, 
		@idEmpresa = @idEmpresa, @nombreBillTo = @nombreBillTo
	
	SELECT 
		tm.idRow id, 
		tm.idClienteFinal, 
		fechaDestino ETA,
		fechaDespacho,
		t.station, 
		ubicacionEstacion,
		idGuia,
		tm.nota,
		nroGuia,
		idCarrier,
		t.codigoMiami,
		house,
		idGuiaHouse,
		pcsPending,
		pcsReceivedWh,
		pcsShort,
		pcsStandby,
		pcsHold,
		pcsDispatchedWh,
		pcsReceivedDr,
		t.totalPcsHouse,
		cntPiezas,
		cl.nombre nombreCliente,
		es.codigoISO codigoEstado,
		es.nombre estado,
		pa.codigoISO codigoPais,
		pa.nombre nombrePais,
		pa.nombreIngles nombreInglesPais,
		tr.nombre nombreCarrier,
		ISNULL(b.nombre, bg.nombre) nombreBodega,
		ISNULL(b.id, bg.id) idBodega,
		'' claseCssEstado,
		0 ordenStatus,
		'' [status],
		CONVERT(BIT, CASE WHEN (pcsReceivedWh > 0 OR t.piezasRecibidas > 0 OR t.piezasTransmitidas > 0 OR t.pcsDispatchedWh > 0) THEN 1 ELSE 0 END) piezasRecibidas
	FROM (
			SELECT	
			idClienteFinal,
			pc.fechaDespacho,
			crs.codigo codigoMiami,
			pc.idCarrier,
			CASE 
				WHEN estadoPieza = 'RECEIVED WH' THEN ISNULL(tb.station, 0) 
				ELSE ISNULL(ISNULL(tb.station, i.station), 0) 
			END station, 
			CASE 
				WHEN estadoPieza = 'RECEIVED WH' THEN  
					CASE 
						WHEN ISNULL(tb.station, '0') = 0 THEN  '-' 
						ELSE CONCAT(@prefijo,' ', FORMAT(CAST(tb.station AS INT),'0#'))
					END
				ELSE
					CASE 
						WHEN ISNULL(tb.station, ISNULL(i.station,0)) = 0 THEN  '-' 
						ELSE CONCAT(@prefijo,' ', FORMAT(CAST(ISNULL(ISNULL(tb.station, ISNULL(i.station,0)), 0)  AS INT),'0#'))
					END
			END ubicacionEstacion, 
			SUM(CASE 
					WHEN fechaRecepcion IS NOT NULL THEN 1
					ELSE 0
				END) piezasRecibidas,
			SUM(CASE 
				WHEN o.transmissionDate IS NOT NULL THEN 1
				ELSE 0
			END) piezasTransmitidas,
			MAX(tb.idRow) idRow, 
			SUM(CASE
					WHEN estadoPieza = 'PENDING' THEN 1
					ELSE 0
				END) pcsPending,
			SUM(CASE
					WHEN estadoPieza = 'RECEIVED WH' THEN 1
					ELSE 0
				END ) pcsReceivedWh,
			SUM(CASE
					WHEN estadoPieza = 'SHORT' THEN 1
					WHEN estadoPieza = 'LOST' THEN 1
					ELSE 0
				END ) pcsShort,
			SUM(CASE
					WHEN estadoPieza = 'STANDBY' THEN 1
					ELSE 0
				END ) pcsStandby,
			SUM(CASE
					WHEN estadoPieza = 'HOLD' THEN 1
					ELSE 0
				END ) pcsHold,
			SUM(CASE
					WHEN estadoPieza = 'DISPATCHED WH' THEN 1
					ELSE 0
				END ) pcsDispatchedWh,
			SUM(CASE
					WHEN estadoPieza = 'RECEIVED DR' THEN 1
					ELSE 0
				END ) pcsReceivedDr,
			SUM(1) totalPcsHouse,
			SUM(1) cntPiezas
		FROM #tmpBasico tb
				LEFT JOIN ProgramacionCarrier pc ON  tb.idGuiaHouseDetalle = pc.idGuiaHouseDetalle  
				LEFT JOIN CodigosRelacionSistemas crs (NOLOCK) ON (pc.idCarrier = crs.idEntidad AND crs.tipoEntidad = 'CARRIER' AND crs.idSistemaEntidad = 100) 
				LEFT JOIN machine_test..Input i ON tb.codigoBarra = i.BarCode AND tb.idGuia = i.IdAWB   
				LEFT JOIN machine_test..[Output] o ON tb.codigoBarra = o.BarCode
				LEFT JOIN UbicacionPiezas up (NOLOCK) ON tb.idGuiaHouseDetalle = up.idGuiaHouseDetalle
				LEFT JOIN Ubicaciones u (NOLOCK) ON up.idUbicacion = u.id
				LEFT JOIN UbicacionesBodega ub (NOLOCK) ON u.idUbicacionBodega = ub.id
				LEFT JOIN Bodegas b (NOLOCK) ON ub.idBodega = b.id
				LEFT JOIN Bodegas bg (NOLOCK) ON tb.idBodega = bg.id	
				GROUP BY			
					idClienteFinal, 
					fechaDestino,
					pc.fechaDespacho,
					CASE 
						WHEN estadoPieza = 'RECEIVED WH' THEN ISNULL(tb.station, 0) 
						ELSE ISNULL(ISNULL(tb.station, i.station), 0) 
					END,
					idGuia,
					nroGuia,
					ISNULL(b.id, bg.id),
					pc.idCarrier,
					crs.codigo,
					CASE 
					WHEN estadoPieza = 'RECEIVED WH' THEN  
						CASE 
							WHEN ISNULL(tb.station, '0') = 0 THEN  '-' 
							ELSE CONCAT(@prefijo,' ', FORMAT(CAST(tb.station AS INT),'0#'))
						END
					ELSE
						CASE 
							WHEN ISNULL(tb.station, ISNULL(i.station,0)) = 0 THEN  '-' 
							ELSE CONCAT(@prefijo,' ', FORMAT(CAST(ISNULL(ISNULL(tb.station, ISNULL(i.station,0)), 0)  AS INT),'0#'))
						END
				END
				) t
			INNER JOIN #tmpBasico tm ON t.idRow = tm.idRow
			INNER JOIN v_ClientsEntities cl ON tm.idClienteFinal = cl.id
			LEFT JOIN Estados es (NOLOCK) ON cl.idEstado = es.id
			LEFT JOIN Paises pa (NOLOCK) ON es.idPais = pa.id
			LEFT JOIN Transportes tr (NOLOCK) ON t.idCarrier = tr.id
			LEFT JOIN UbicacionPiezas up (NOLOCK) ON tm.idGuiaHouseDetalle = up.idGuiaHouseDetalle
			LEFT JOIN Ubicaciones u (NOLOCK) ON up.idUbicacion = u.id
			LEFT JOIN UbicacionesBodega ub (NOLOCK) ON u.idUbicacionBodega = ub.id
			LEFT JOIN Bodegas b (NOLOCK) ON ub.idBodega = b.id
			LEFT JOIN Bodegas bg (NOLOCK) ON tm.idBodega = bg.id	
		WHERE (@station = '' OR ubicacionEstacion LIKE CONCAT('%', @station, '%'))
		AND (@soloEstacion = 0 OR t.station > 0)
END
GO

/*
dbo.AC_pro_GetMachineShipments 
@fechaInicio='2025-10-24 00:00:00',
@fechaFinal='2025-11-08 00:00:00',
@idEmpresa=N'EMP014',
@idClienteFinal=NULL,
@idGuia=N'GUI012009323',
@nombreClienteFinal=NULL,
@house=NULL,
@estado=NULL,
@nombreExportador=NULL,
@station=NULL,
@soloEstacion=0, 
@nombreBillTo=N''
*/


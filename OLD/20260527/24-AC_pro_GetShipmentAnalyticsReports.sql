/*
VERSION     MODIFIEDBY			MODIFIEDDATE    HU      MODIFICATION
1           Ian Ortega			2026-02-11      57745   Based on dbo.pro_ReportesAnaliticaEmbarques
*/

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetShipmentAnalyticsReports]
(
	@IdsConsignees VARCHAR(MAX),
	@StartDate DATETIME,
	@EndDate DATETIME
)
AS
BEGIN
	CREATE TABLE #ConsigneesSelected (
		id VARCHAR(16) PRIMARY KEY,
		nombre NVARCHAR(512)
	)

	CREATE TABLE #Preliminar (
		origin VARCHAR(16),
		destination VARCHAR(16),
		[date] DATE,
		shipmentNr VARCHAR(32),
		carrier VARCHAR(1024),
		house VARCHAR(32),
		idConsignee VARCHAR(16),
		consignee VARCHAR(1024),
		importer VARCHAR(1024),
		supplier VARCHAR(1024),
		product VARCHAR(256),
		boxType VARCHAR(8),
		unitsPerBox INT,
		boxes INT,
		equivalencia DECIMAL(18,5),
		totalPcsHouse INT,
		totalFullHouse DECIMAL(18,3),
		pesoVolumenHouse DECIMAL(18,3),
		pesoCargableHouse DECIMAL(18,3),
		pesoDetalleHouse DECIMAL(18,3),
		pesoNetoCB DECIMAL(18,3),
		pesoVolumenCB DECIMAL(18,3),
		boxDimmCms VARCHAR(50),
		boxDimmInches VARCHAR(50),
		temp DECIMAL(18,2),
		codigoEmpresa VARCHAR(8),
		idGuia VARCHAR(128),
		idGuiaHouse UNIQUEIDENTIFIER,
		idGuiaHouseDetalle UNIQUEIDENTIFIER,
		idCodigoDeBarra VARCHAR(16),
		idDetalleIngreso VARCHAR(16)
	)

	CREATE TABLE #Final (
		origin VARCHAR(16),
		destination VARCHAR(16),
		[date] DATE,
		shipmentNr VARCHAR(32),
		carrier VARCHAR(1024),
		house VARCHAR(32),
		idConsignee VARCHAR(16),
		consignee VARCHAR(1024),
		importer VARCHAR(1024),
		supplier VARCHAR(1024),
		product VARCHAR(256),
		boxType VARCHAR(8),
		unitsPerBox INT,
		pieces INT,
		fb DECIMAL(18,3),
		grossWeight DECIMAL(18,2),
		volumeWeight DECIMAL(18,2),
		chargableWeight DECIMAL(18,2),
		grossWeightFB DECIMAL(18,2),
		volumeWeightFB DECIMAL(18,2),
		chargableWeightFB DECIMAL(18,2),
		boxDimmCms VARCHAR(50),
		boxDimmInches VARCHAR(50),
		temp DECIMAL(18,1),
		idGuia VARCHAR(128),
		idGuiaHouse VARCHAR(128)
	)

	INSERT INTO #ConsigneesSelected (id)
	SELECT TRIM(VALUE) FROM STRING_SPLIT(@IdsConsignees, ',')

	UPDATE #ConsigneesSelected
	SET nombre = VCE.nombre
	FROM #ConsigneesSelected CS
	INNER JOIN v_ClientsEntities VCE WITH (NOLOCK) ON VCE.ConsigneeId = CS.id

	INSERT INTO #Preliminar 
	SELECT
		origin = CO.codigoIATA,
		destination = CD.codigoIATA,
		[date] = GU.fechaEmbarque,
		shipmentNr = HE.nroGuia,
		carrier = TR.nombre,
		house = HE.house,
		idConsignee = CS.id,
		consignee = CS.nombre,
		importer = CS.nombre,
		supplier = EX.nombre,
		product = DM.nombreIngles,
		boxType = TP.tipoPieza,
		unitsPerBox = HD.totalTallos,
		boxes = 1,
		equivalencia = TP.equivalencia,
		totalPcsHouse = HE.totalPcsHouse,
		totalFullHouse = HE.totalFullHouse,
		pesoVolumenHouse = HE.pesoVolumenHouse,
		pesoCargableHouse = HE.pesoCargable,
		pesoDetalleHouse = HD.peso,
		pesoNetoCB = CB.pesoNeto,
		pesoVolumenCB = CB.pesoVolumen,
		boxDimmCms = LTRIM(STR(HD.largoCm,10,0)) + 'x' + LTRIM(STR(HD.anchoCm,10,0)) + 'x' + LTRIM(STR(HD.altoCm,10,0)),
		boxDimmInches = LTRIM(STR(HD.largoIn,10,1)) + 'x' + LTRIM(STR(HD.anchoIn,10,1)) + 'x' + LTRIM(STR(HD.altoIn,10,1)),
		temp = EI.temperatura,
		codigoEmpresa = EM.codigoEmpresa,
		HE.idGuia,
		idGuiaHouse = HE.id,
		idGuiaHouseDetalle = HD.id,
		idCodigoDeBarra = HD.idCodigoDeBarra,
		CB.idDetalleIngreso
	FROM #ConsigneesSelected CS
	INNER JOIN GuiasHouse HE WITH (NOLOCK) ON HE.ConsigneeId = CS.id
	INNER JOIN GuiasHouseDetalles HD WITH (NOLOCK) ON HD.idGuiaHouse = HE.id
	INNER JOIN DetalleMercancias DM WITH (NOLOCK) ON DM.id = HD.idDetalleMercancia
	INNER JOIN Exportadores EX WITH (NOLOCK) ON EX.id = HE.idExportador
	INNER JOIN Ciudades CO WITH (NOLOCK) ON CO.id = HE.idCiudadPuertoOrigen
	INNER JOIN Ciudades CD WITH (NOLOCK) ON CD.id = HE.idCiudadPuertoDestino
	INNER JOIN TiposDePieza TP WITH (NOLOCK) ON TP.id = HD.idTipoDePieza
	INNER JOIN Guias GU WITH (NOLOCK) ON GU.id = HE.idGuia
	LEFT JOIN Transportes TR WITH (NOLOCK) ON TR.id = HE.idTransporteOrigen
	LEFT JOIN CodigosDeBarra CB WITH (NOLOCK) ON CB.id = HD.idCodigoDeBarra
	LEFT JOIN DetalleIngresos DI WITH (NOLOCK) ON DI.id = CB.idDetalleIngreso
	LEFT JOIN EncabezadoIngresos EI WITH (NOLOCK) ON EI.id = DI.idEncabezadoIngreso
	LEFT JOIN Empresas EM WITH (NOLOCK) ON EM.id = DI.idEmpresa
	WHERE GU.fechaEmbarque BETWEEN @StartDate AND @EndDate

	INSERT INTO #Preliminar 
	SELECT
		origin = CO.codigoIATA,
		destination = CD.codigoIATA,
		[date] = HE.fechaOrigen,
		shipmentNr = HE.nroGuia,
		carrier = TR.nombre,
		house = HE.house,
		idConsignee = CS.id,
		consignee = CS.nombre,
		importer = CS.nombre,
		supplier = EX.nombre,
		product = DM.nombreIngles,
		boxType = TP.tipoPieza,
		unitsPerBox = HD.totalTallos,
		boxes = 1,
		equivalencia = TP.equivalencia,
		totalPcsHouse = HE.totalPcsHouse,
		totalFullHouse = HE.totalFullHouse,
		pesoVolumenHouse = HE.pesoVolumenHouse,
		pesoCargableHouse = HE.pesoCargable,
		pesoDetalleHouse = HD.peso,
		pesoNetoCB = CB.pesoNeto,
		pesoVolumenCB = CB.pesoVolumen,
		boxDimmCms = LTRIM(STR(HD.largoCm,10,0)) + 'x' + LTRIM(STR(HD.anchoCm,10,0)) + 'x' + LTRIM(STR(HD.altoCm,10,0)),
		boxDimmInches = LTRIM(STR(HD.largoIn,10,1)) + 'x' + LTRIM(STR(HD.anchoIn,10,1)) + 'x' + LTRIM(STR(HD.altoIn,10,1)),
		temp = EI.temperatura,
		codigoEmpresa = EM.codigoEmpresa,
		HE.idGuia,
		idGuiaHouse = HE.id,
		idGuiaHouseDetalle = HD.id,
		idCodigoDeBarra = HD.idCodigoDeBarra,
		CB.idDetalleIngreso
	FROM #ConsigneesSelected CS
	INNER JOIN GuiasHouse HE WITH (NOLOCK) ON HE.ConsigneeId = CS.id
	INNER JOIN GuiasHouseDetalles HD WITH (NOLOCK) ON HD.idGuiaHouse = HE.id
	INNER JOIN DetalleMercancias DM WITH (NOLOCK) ON DM.id = HD.idDetalleMercancia
	INNER JOIN Exportadores EX WITH (NOLOCK) ON EX.id = HE.idExportador
	INNER JOIN Ciudades CO WITH (NOLOCK) ON CO.id = HE.idCiudadPuertoOrigen
	INNER JOIN Ciudades CD WITH (NOLOCK) ON CD.id = HE.idCiudadPuertoDestino
	INNER JOIN TiposDePieza TP WITH (NOLOCK) ON TP.id = HD.idTipoDePieza
	LEFT JOIN Guias GU WITH (NOLOCK) ON GU.id = HE.idGuia
	LEFT JOIN Transportes TR WITH (NOLOCK) ON TR.id = HE.idTransporteOrigen
	LEFT JOIN CodigosDeBarra CB WITH (NOLOCK) ON CB.id = HD.idCodigoDeBarra
	LEFT JOIN DetalleIngresos DI WITH (NOLOCK) ON DI.id = CB.idDetalleIngreso
	LEFT JOIN EncabezadoIngresos EI WITH (NOLOCK) ON EI.id = DI.idEncabezadoIngreso
	LEFT JOIN Empresas EM WITH (NOLOCK) ON EM.id = DI.idEmpresa
	WHERE GU.id IS NULL
		AND HE.fechaOrigen BETWEEN @StartDate AND @EndDate

	-- Eliminando temperatura para embarques que no vienen de Ecuador (ALIANZA LOGISTIKA TDGE S.A.)
	UPDATE #Preliminar
	SET temp = NULL
	WHERE ISNULL(codigoEmpresa, '') <> 'UIO'

	INSERT INTO #Final
	SELECT
		origin,
		destination,
		[date],
		shipmentNr,
		carrier,
		house,
		idConsignee,
		consignee,
		importer,
		supplier,
		product,
		boxType,
		unitsPerBox,
		pieces = SUM(boxes),
		fb = SUM(equivalencia * boxes),
		grossWeight = IIF(MAX(idDetalleIngreso) IS NULL, SUM(ISNULL(pesoDetalleHouse, 0)), SUM(ISNULL(pesoNetoCB, 0))),
		volumeWeight = IIF(MAX(idDetalleIngreso) IS NULL, SUM(ISNULL(pesoDetalleHouse, 0)), SUM(ISNULL(pesoVolumenCB, 0))),
		chargableWeight = NULL,
		grossWeightFB = NULL,
		volumeWeightFB = NULL,
		chargableWeightFB = NULL,
		boxDimmCms,
		boxDimmInches,
		temp = AVG(temp),
		idGuia,
		idGuiaHouse = CONVERT(VARCHAR(128), idGuiaHouse)
	FROM #Preliminar
	GROUP BY
		origin,
		destination,
		[date],
		shipmentNr,
		carrier,
		house,
		idConsignee,
		consignee,
		importer,
		supplier,
		product,
		boxType,
		unitsPerBox,
		boxDimmCms,
		boxDimmInches,
		idGuia,
		idGuiaHouse

	UPDATE #Final
	SET chargableWeight = IIF(grossWeight > volumeWeight, grossWeight, volumeWeight)

	-- Calculando los pesos por FB
	UPDATE #Final
	SET
		grossWeightFB = grossWeight / fb,
		volumeWeightFB = volumeWeight / fb,
		chargableWeightFB = chargableWeight / fb,
		shipmentNr = CASE 
			WHEN LEN(shipmentNr) = 11 THEN SUBSTRING(shipmentNr, 1, 3) + '-' + SUBSTRING(shipmentNr, 4, 4) + ' ' + SUBSTRING(shipmentNr, 8, 4)
			ELSE shipmentNr
			END,
		boxDimmInches = CASE
			WHEN boxDimmInches IN('0.0x0.0x0.0','0,0x0,0x0,0') THEN NULL
			ELSE boxDimmInches
			END,
		boxDimmCms = CASE
			WHEN boxDimmCms = '0x0x0' THEN NULL
			ELSE boxDimmCms
			END

	SELECT 
		id = CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY [date], shipmentNr, house)),
		[year] = YEAR([date]),
		[week] = DATEPART(wk, [date]),
		[month] = FORMAT([date], 'MMMM', 'en-US'),
		*
	FROM #Final
	ORDER BY 
		[date],
		shipmentNr,
		house

END

/*
===== EJEMPLOS DE USO =====

-- 1. Prueba básica con un consignatario (28 rows)

EXEC AC_pro_GetShipmentAnalyticsReports 
	'ETY0000000008142', 
	'2026-01-01 00:00:00.000', 
	'2026-10-01 00:00:00.000'

EXEC pro_ReportesAnaliticaEmbarques 
	'CLI0119075', 
	'2026-01-01 00:00:00.000', 
	'2026-10-01 00:00:00.000'

-- 2. Prueba con multiples consignatarios

EXEC AC_pro_GetShipmentAnalyticsReports 
	'ETY0000000008683,ETY0000000008142', 
	'2026-01-01 00:00:00', 
	'2026-10-01 00:00:00'

EXEC pro_ReportesAnaliticaEmbarques 
	'CLI0120245,CLI0119075', 
	'2026-01-01 00:00:00.000', 
	'2026-10-01 00:00:00.000'
*/
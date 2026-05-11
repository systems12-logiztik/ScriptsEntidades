/*  
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION  
1			Juan Yanza			2026-02-22		57744	Based on pro_reportes_analiticadespacho 
*/  

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetDispatchReports]
(
	@IdsConsignees				VARCHAR(MAX),
	@StartDate					DATETIME,
	@EndDate					DATETIME
)
AS
BEGIN
	CREATE TABLE #ConsigneesSelected (
		id					VARCHAR(16) PRIMARY KEY,
		nombre				VARCHAR(512)
	)

	CREATE TABLE #Preliminar (
		idConsignee			VARCHAR(16),
		consignatario		VARCHAR(512),
		shipper				VARCHAR(1024),
		[status]			VARCHAR(64),
		awb					VARCHAR(32),
		origin				NVARCHAR(128),
		poNumber			VARCHAR(64),
		[type]				VARCHAR(8),
		equivalencia		DECIMAL(18,5),
		alto				DECIMAL(18,3),
		largo				DECIMAL(18,3),
		ancho				DECIMAL(18,3),
		boxes				INT,
		totalPcsHouse		INT,
		totalFullHouse		DECIMAL(18,3),
		fechaDespacho		DATETIME,
		idGuiaHouse			UNIQUEIDENTIFIER,
		idGuiaHouseDetalle	UNIQUEIDENTIFIER,
		idPo				UNIQUEIDENTIFIER,
		idPoDetalle			UNIQUEIDENTIFIER
	)

	INSERT INTO #ConsigneesSelected (id)
	SELECT TRIM(RTRIM(VALUE))
	FROM STRING_SPLIT(@IdsConsignees, ',')
	WHERE LTRIM(RTRIM(VALUE)) <> ''

	UPDATE	#ConsigneesSelected
	SET		nombre	= VCE.nombre
	FROM	#ConsigneesSelected		CS
	INNER JOIN	v_ClientsEntities	VCE WITH(NOLOCK) ON VCE.ConsigneeId = CS.id

	INSERT INTO #Preliminar 
	SELECT
			idConsignee			= CS.id,
			consignatario		= CS.nombre,
			shipper				= EX.nombre,
			[status]			= HE.estadoGuia,
			awb					= HE.nroGuia,
			origin				= CD.nombre,
			poNumber			= CASE WHEN HD.po = '' THEN NULL ELSE HD.po END,
			[type]				= TP.tipoPieza,
			equivalencia		= TP.equivalencia,
			alto				= HD.altoIn,
			largo				= HD.largoIn,
			ancho				= HD.anchoIn,
			boxes				= 1,
			totalPcsHouse		= HE.totalPcsHouse,
			totalFullHouse		= HE.totalFullHouse,
			fechaDespacho		= PC.fechaDespacho,
			idGuiaHouse			= HE.id,
			idGuiaHouseDetalle	= HD.id,
			idPo				= NULL,
			idPoDetalle			= HD.idPoDetalle
	FROM	#ConsigneesSelected		CS
	INNER JOIN GuiasHouse			HE WITH(NOLOCK) ON	HE.ConsigneeId = CS.id
	INNER JOIN GuiasHouseDetalles	HD WITH(NOLOCK) ON	HD.idGuiaHouse = HE.id
	INNER JOIN ProgramacionCarrier	PC WITH(NOLOCK) ON	PC.idGuiaHouseDetalle = HD.id
	INNER JOIN Exportadores			EX WITH(NOLOCK) ON	EX.id = HE.idExportador
	INNER JOIN TiposDePieza			TP WITH(NOLOCK) ON	TP.id = HD.idTipoDePieza
	INNER JOIN Ciudades				CD WITH(NOLOCK) ON	CD.id = HE.idCiudadPuertoOrigen
	WHERE PC.fechaDespacho BETWEEN	@StartDate AND @EndDate

	DELETE PRE 
	FROM #Preliminar PRE 
	INNER JOIN	PoDetalles			PD WITH(NOLOCK) ON	PD.id = PRE.idPoDetalle
	INNER JOIN	PoEncabezado		PE WITH(NOLOCK) ON	PE.id = PD.idPo
	INNER JOIN	OrdenesLocales		OL WITH(NOLOCK) ON	OL.id = PE.idOrdenLocal
	INNER JOIN	Catalogos			CA WITH(NOLOCK) ON	CA.id = OL.idCatalogoStatus
	WHERE CA.codigoRelacion = 'CANCELADO'

	UPDATE	#Preliminar
	SET		[status]	= UPPER(CA.nombreIngles),
			idPo		= PE.id,
			awb			= 'LOCAL'
	FROM	#Preliminar				PRE
	INNER JOIN	PoDetalles			PD WITH(NOLOCK) ON	PD.id = PRE.idPoDetalle
	INNER JOIN	PoEncabezado		PE WITH(NOLOCK) ON	PE.id = PD.idPo
	INNER JOIN	OrdenesLocales		OL WITH(NOLOCK) ON	OL.id = PE.idOrdenLocal
	INNER JOIN	Catalogos			CA WITH(NOLOCK) ON	CA.id = OL.idCatalogoStatus

	UPDATE	#Preliminar
	SET		origin		= CD.nombre
	FROM	#Preliminar				PRE
	INNER JOIN PoDetalles			PD WITH(NOLOCK) ON	PD.id = PRE.idPoDetalle
	INNER JOIN PoEncabezado			PE WITH(NOLOCK) ON	PE.id = PD.idPo
	INNER JOIN Empresas				EM WITH(NOLOCK) ON	EM.id = PE.idEmpresa
	INNER JOIN Ciudades				CD WITH(NOLOCK) ON	CD.id = EM.idCiudad

	SELECT
			id				= CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY consignatario, poNumber, shipper)),
			idConsignee,
			consignatario,
			shipper,
			boxes			= SUM(boxes),
			[type],
			fb				= ROUND(SUM(equivalencia), 2),
			cubic			= ROUND(SUM(alto * largo * ancho / 1728), 2),
			[status],
			awb,
			origin,
			poNumber
	FROM	#Preliminar
	GROUP BY
			idConsignee,
			consignatario,
			shipper,
			[type],
			[status],
			awb,
			origin,
			poNumber
	ORDER BY consignatario, poNumber, shipper
END

/*
-- TEST 1: ANTES/DESPUES "ETY0000000046573,ETY0000000008707,ETY0000000008162" ->  NARANJO FARMS IN OUT, NARANJO FARMS INVENTORY -> 573
EXEC pro_reportes_analiticadespacho 'CLI0120245,CLI0119075', '20251201', '20260210'
EXEC AC_pro_GetDispatchReports 'ETY0000000008683,ETY0000000008142', '20251201', '20260210'


-- TEST 2: ANTES/DESPUES "ETY0000000012947, ETY0000000013037, ETY0000000015439,ETY0000000015422" DEST GOMEZ BV / INVENTORY, DEST GOMEZ BV IN & OUT, GOMEZ BV IN & OUT, GOMEZ BV INVENTORY -> 189
EXEC pro_reportes_analiticadespacho 'CLI0125831,CLI0128253,CLI0128238,CLI0125728', '20251201', '20260210'
EXEC AC_pro_GetDispatchReports 'ETY0000000012871, ETY0000000012961, ETY0000000015334,ETY0000000015317', '20251201', '20260210'
*/
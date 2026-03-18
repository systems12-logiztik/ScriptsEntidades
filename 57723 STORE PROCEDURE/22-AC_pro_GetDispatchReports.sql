/*  
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION  
1			Juan Yanza			29/01/2025		57744	Based on pro_reportes_analiticadespacho 
*/  

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetDispatchReports]
(
	@IdsConsignees				varchar(max),
	@StartDate					datetime,
	@EndDate					datetime
)
AS
BEGIN
	-- Tabla de Consignatarios Seleccionados
	DECLARE @ConsigneesSelected TABLE(
		id					varchar(16) PRIMARY KEY,
		nombre				nvarchar(512)
	)

	-- Tabla de resultados preliminares
	DECLARE @Preliminar TABLE(
		idConsignee			varchar(16),
		consignatario		varchar(512),
		shipper				varchar(1024),
		[status]			varchar(64),
		awb					varchar(32),
		origin				nvarchar(128),
		poNumber			varchar(64),
		[type]				varchar(8),
		equivalencia		decimal(18,5),
		alto				decimal(18,3),
		largo				decimal(18,3),
		ancho				decimal(18,3),
		boxes				int,
		totalPcsHouse		int,
		totalFullHouse		decimal(18,3),
		fechaDespacho		datetime,
		idGuiaHouse			uniqueidentifier,
		idGuiaHouseDetalle	uniqueidentifier,
		idPo				uniqueidentifier,
		idPoDetalle			uniqueidentifier
	)

	-- Separar la lista de consignatarios en una tabla
	INSERT INTO @ConsigneesSelected (id)
	SELECT TRIM(RTRIM(value))
	FROM STRING_SPLIT(@IdsConsignees, ',')
	WHERE LTRIM(RTRIM(value)) <> ''

	-- Obtener los nombres de los consignatarios enviados usando la vista v_ClientsEntities
	UPDATE	@ConsigneesSelected
	SET		nombre	= VCE.nombre
	FROM	@ConsigneesSelected			CS
		INNER JOIN	v_ClientsEntities	VCE WITH(NOLOCK) ON VCE.ConsigneeId = CS.id

	-- Información preliminar para el reporte (Guias House)
	INSERT INTO @Preliminar 
	SELECT
			idConsignee			= CS.id,
			consignatario		= CS.nombre,
			shipper				= EX.nombre,
			[status]			= HE.estadoGuia,
			awb					= HE.nroGuia,
			origin				= CD.nombre,
			poNumber			= HD.po,
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
	FROM	@ConsigneesSelected		CS
		INNER JOIN GuiasHouse			HE WITH(NOLOCK) ON	HE.ConsigneeId = CS.id
		INNER JOIN GuiasHouseDetalles	HD WITH(NOLOCK) ON	HD.idGuiaHouse = HE.id
		INNER JOIN ProgramacionCarrier	PC WITH(NOLOCK) ON	PC.idGuiaHouseDetalle = HD.id
		INNER JOIN Exportadores			EX WITH(NOLOCK) ON	EX.id = HE.idExportador
		INNER JOIN TiposDePieza			TP WITH(NOLOCK) ON	TP.id = HD.idTipoDePieza
		INNER JOIN Ciudades				CD WITH(NOLOCK) ON	CD.id = HE.idCiudadPuertoOrigen
	WHERE
			PC.fechaDespacho	>=	@StartDate
		AND	PC.fechaDespacho	<=	@EndDate

	-- Excluye las ordenes locales que tienen estado CANCELADO
	DELETE PRE 
	FROM @Preliminar PRE 
		INNER JOIN	PoDetalles			PD WITH(NOLOCK) ON	PD.id = PRE.idPoDetalle
		INNER JOIN	PoEncabezado		PE WITH(NOLOCK) ON	PE.id = PD.idPo
		INNER JOIN	OrdenesLocales		OL WITH(NOLOCK) ON	OL.id = PE.idOrdenLocal
		INNER JOIN	Catalogos			CA WITH(NOLOCK) ON	CA.id = OL.idCatalogoStatus
	WHERE CA.codigoRelacion = 'CANCELADO'

	-- Se actualiza el status para las POs en base al status de la orden local
	UPDATE	@Preliminar
	SET		[status]	= UPPER(CA.nombreIngles),
			idPo		= PE.id,
			awb			= 'LOCAL'
	FROM	@Preliminar					PRE
		INNER JOIN	PoDetalles			PD WITH(NOLOCK) ON	PD.id = PRE.idPoDetalle
		INNER JOIN	PoEncabezado		PE WITH(NOLOCK) ON	PE.id = PD.idPo
		INNER JOIN	OrdenesLocales		OL WITH(NOLOCK) ON	OL.id = PE.idOrdenLocal
		INNER JOIN	Catalogos			CA WITH(NOLOCK) ON	CA.id = OL.idCatalogoStatus

	-- Se actualiza la ciudad para las POs en base a la ciudad de la empresa
	UPDATE	@Preliminar
	SET		origin		= CD.nombre
	FROM	@Preliminar					PRE
		INNER JOIN PoDetalles			PD WITH(NOLOCK) ON	PD.id = PRE.idPoDetalle
		INNER JOIN PoEncabezado			PE WITH(NOLOCK) ON	PE.id = PD.idPo
		INNER JOIN Empresas				EM WITH(NOLOCK) ON	EM.id = PE.idEmpresa
		INNER JOIN Ciudades				CD WITH(NOLOCK) ON	CD.id = EM.idCiudad

	UPDATE	@Preliminar
	SET		poNumber	= NULL
	WHERE	poNumber	= ''

	-- Resultado final
	SELECT
			id				= CONVERT(varchar(64), NEWID()),
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
	FROM	@Preliminar
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

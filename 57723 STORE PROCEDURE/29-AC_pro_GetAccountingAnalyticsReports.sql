/*
VERSION     MODIFIEDBY			MODIFIEDDATE    HU      MODIFICATION
1           Ian Ortega			2026-02-24      57743   Based on dbo.pro_reportes_analiticacontabilidad
*/

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetAccountingAnalyticsReports]
(
	@IdsConsignees VARCHAR(MAX),
	@StartDate DATE,
	@EndDate DATE
)
AS
BEGIN
	DECLARE
		@TipoCargoFlete VARCHAR(16),
		@TipoCargoGuia VARCHAR(16),
		@TipoServLocal VARCHAR(16)

	CREATE TABLE #ConsigneesSelected (
		id VARCHAR(16) PRIMARY KEY,
		nombre VARCHAR(512),
		BillToConsigneeId VARCHAR(16)
	)

	CREATE TABLE #ParametrosInvoice (
		valor VARCHAR(64),
		referencia VARCHAR(16),
		id VARCHAR(16)
	)

	CREATE TABLE #ChargPorCodBarr (
		idCoordinacion VARCHAR(16),
		coordCBPesoNeto DECIMAL(18,3),
		coordCBPesoVolumen DECIMAL(18,3)
	)

	CREATE TABLE #SumChargPorCodBarr (
		invoice VARCHAR(64),
		invoiceCBPesoNeto DECIMAL(18,3),
		invoiceCBPesoVolumen DECIMAL(18,3),
		invoiceCBMaxCharg DECIMAL(18,3)
	)

	CREATE TABLE #ChargPorWarehouse  (
		idCoordinacion VARCHAR(16),
		coordWHPesoNeto DECIMAL(18,3),
		coordWHPesoVolumen DECIMAL(18,3)
	)

	CREATE TABLE #SumChargPorWarehouse (
		invoice VARCHAR(64),
		invoiceWHPesoNeto DECIMAL(18,3),
		invoiceWHPesoVolumen DECIMAL(18,3),
		invoiceWHMaxCharg DECIMAL(18,3)
	)

	CREATE TABLE #DescuadreInvoice (
		idGuiaDistribucion VARCHAR(16),
		idConsignatario VARCHAR(16),
		invoice VARCHAR(64),
		sumCharg DECIMAL(23,13),
		diffCharg DECIMAL(23,13),
		sumtotalbyhawb DECIMAL(23,13),
		diffTotalbyhawb DECIMAL(23,13),
		maxhawb VARCHAR(64)
	)

	CREATE TABLE #Final (
		tipoRegistro VARCHAR(16),
		invoiceDate DATE,
		invoice VARCHAR(64),
		idConsignatario VARCHAR(16),
		consignatario VARCHAR(1024),
		origin VARCHAR(128),
		mawb VARCHAR(128),
		hawb VARCHAR(64),
		shipper VARCHAR(512),
		fb DECIMAL(18,2),
		charg DECIMAL(23,13),
		chargTmp DECIMAL(18,3),
		sumChargTmp DECIMAL(18,3),
		invoiceCharg DECIMAL(18,3),
		coordCBPesoNeto DECIMAL(18,3),
		coordCBPesoVolumen DECIMAL(18,3),
		invoiceCBPesoNeto DECIMAL(18,3),
		invoiceCBPesoVolumen DECIMAL(18,3),
		invoiceCBMaxCharg DECIMAL(18,3),
		coordWHPesoNeto DECIMAL(18,3),
		coordWHPesoVolumen DECIMAL(18,3),
		invoiceWHPesoNeto DECIMAL(18,3),
		invoiceWHPesoVolumen DECIMAL(18,3),
		invoiceWHMaxCharg DECIMAL(18,3),
		rate DECIMAL(18,3),
		totalByHAWB DECIMAL(23,13),
		invoiceAmount NUMERIC(10,3),
		idGuiaConsolidada VARCHAR(16),
		idGuiaDistribucion VARCHAR(16),
		idCoordinacion VARCHAR(16),
		idAsignacionServicioLocal UNIQUEIDENTIFIER
	)

	SELECT @TipoCargoFlete = '1-CARGO-FLETE', 
		@TipoCargoGuia = '2-CARGOS-GUIA',
		@TipoServLocal = '3-SERV-LOCALES'

	INSERT INTO #ConsigneesSelected(id)
	SELECT TRIM(VALUE) FROM STRING_SPLIT(@IdsConsignees, ',')

	UPDATE #ConsigneesSelected
	SET nombre = VCE.nombre,
		BillToConsigneeId = VCE.Id
	FROM #ConsigneesSelected CS
	INNER JOIN v_ClientsEntities VCE WITH (NOLOCK) ON VCE.ConsigneeId = CS.id

	INSERT INTO #ParametrosInvoice
	SELECT valor, referencia, id
	FROM ParametrosInvoice
	GROUP BY valor, referencia, id

	INSERT INTO #Final (
		tipoRegistro,
		invoiceDate,
		invoice,
		idConsignatario,
		consignatario,
		origin,
		mawb,
		hawb,
		shipper,
		fb,
		rate,
		totalByHAWB,
		invoiceAmount,
		idGuiaConsolidada,
		idGuiaDistribucion,
		idCoordinacion
	)
	SELECT
		tipoRegistro = @TipoCargoFlete,
		invoiceDate = GC.fechaEmbarque,
		invoice = IV.verifiedInvoice,
		idConsignatario = CS.id,
		consignatario = CS.nombre,
		origin = CI.nombre,
		mawb = GC.nroGuia,
		hawb = CO.house,
		shipper = EX.nombre,
		fb = CO.totalCajasRecepcion,
		rate = IV.unitp,
		totalByHAWB = CO.pesoVolumen * IV.unitp,
		invoiceAmount = -IV.amount,
		idGuiaConsolidada = GC.id,
		idGuiaDistribucion = GD.id,
		idCoordinacion = CO.id
	FROM Guias GC WITH (NOLOCK)
	INNER JOIN Guias GD WITH (NOLOCK) ON GC.id = GD.idGuiaConsolidada
	INNER JOIN InvoicesPeachtree IV WITH (NOLOCK) ON IV.idGuiaDistribucion = GD.id
	INNER JOIN #ParametrosInvoice PA ON PA.id = IV.idParametroInvoice
	INNER JOIN #ConsigneesSelected CS ON CS.BillToConsigneeId = GD.BillToConsigneeId
	INNER JOIN Coordinaciones CO WITH (NOLOCK) ON CO.idGuia = GD.id
	INNER JOIN Exportadores EX WITH (NOLOCK) ON EX.id = CO.idExportador
	INNER JOIN Puertos PU WITH (NOLOCK) ON PU.id = GD.idPuertoOrigen
	INNER JOIN Ciudades CI WITH (NOLOCK) ON CI.id = PU.idCiudad
	WHERE GC.fechaEmbarque BETWEEN @StartDate AND @EndDate
		AND IV.verifiedInvoice IS NOT NULL
		AND PA.referencia = 'FLETENETO'
	
	INSERT INTO #Final(
		tipoRegistro,
		invoiceDate,
		invoice,
		idConsignatario,
		consignatario,
		origin,
		mawb,
		shipper,
		rate,
		totalByHAWB,
		invoiceAmount,
		idGuiaConsolidada,
		idGuiaDistribucion
	)
	SELECT
		tipoRegistro = @TipoCargoGuia,
		invoiceDate = GC.fechaEmbarque,
		invoice = IV.verifiedInvoice,
		idConsignatario = CS.id,
		consignatario = CS.nombre,
		origin = CI.nombre,
		mawb = GC.nroGuia,
		shipper = PA.referencia,
		rate = -IV.amount,
		totalByHAWB = -IV.amount,
		invoiceAmount = -IV.amount,
		idGuiaConsolidada = GC.id,
		idGuiaDistribucion = GD.id
	FROM Guias GC WITH (NOLOCK)
	INNER JOIN InvoicesPeachtree IV WITH (NOLOCK) ON IV.idGuia = GC.id
	INNER JOIN #ParametrosInvoice PA WITH (NOLOCK) ON PA.id = IV.idParametroInvoice
	INNER JOIN Guias GD WITH (NOLOCK) ON IV.idGuiaDistribucion = GD.id
	INNER JOIN #ConsigneesSelected CS ON CS.BillToConsigneeId = GD.BillToConsigneeId
	INNER JOIN Puertos PU WITH (NOLOCK) ON PU.id = GD.idPuertoOrigen
	INNER JOIN Ciudades CI WITH (NOLOCK) ON CI.id = PU.idCiudad
	WHERE GC.fechaEmbarque BETWEEN @StartDate AND @EndDate
		AND IV.verifiedInvoice IS NOT NULL
		AND PA.referencia <> 'FLETENETO'

	INSERT INTO #Final (
		tipoRegistro,
		invoiceDate,
		invoice,
		idConsignatario,
		consignatario,
		origin,
		mawb,
		shipper,
		rate,
		totalByHAWB,
		invoiceAmount,
		idAsignacionServicioLocal
	)
	SELECT
		tipoRegistro = @TipoServLocal,
		invoiceDate = LE.fechaRequerida,
		invoice = IV.verifiedInvoice,
		idConsignatario = LE.ConsigneeId,
		consignatario = CS.nombre,
		origin = CI.nombre,
		mawb = LE.nroReferencia,
		shipper = SL.nombre,
		rate = LE.valorTotal,
		totalByHAWB = LE.valorTotal,
		invoiceAmount = -IV.amount,
		idAsignacionServicioLocal = LE.id
	FROM AsignacionServiciosLocales LE WITH (NOLOCK)
	INNER JOIN #ConsigneesSelected CS ON CS.id = LE.ConsigneeId
	INNER JOIN InvoicesPeachtree IV WITH (NOLOCK) ON IV.idAsignacionServicioLocal = LE.id
	INNER JOIN ServiciosLocales SL WITH (NOLOCK) ON SL.id = LE.idServicioLocal
	INNER JOIN Bodegas BO WITH (NOLOCK) ON BO.id = LE.idBodega
	INNER JOIN Ciudades CI WITH (NOLOCK) ON CI.id = BO.idCiudad
	WHERE 
		LE.fechaRequerida BETWEEN @StartDate AND @EndDate
		AND IV.verifiedInvoice IS NOT NULL

	-- En caso que el servicio local este atado a una guia se toma la ciudad de origen de la guia
	UPDATE #Final
	SET origin = CI.nombre
	FROM #Final RF
	INNER JOIN Guias GM WITH (NOLOCK) ON GM.nroGuia = RF.mawb
	INNER JOIN Puertos PU WITH (NOLOCK) ON PU.id = GM.idPuertoOrigen
	INNER JOIN Ciudades CI WITH (NOLOCK) ON CI.id = PU.idCiudad
	WHERE RF.tipoRegistro = @TipoServLocal

	-- Inicio de obtencion de charg para distribucion
		-- Por CodigosDeBarra 
		-- Obtener la suma de Charg por coordinacion desde codigos de barras
		INSERT INTO #ChargPorCodBarr
		SELECT
			RF.idCoordinacion,
			coordCBPesoNeto = SUM(CB.pesoNeto),
			coordCBPesoVolumen = SUM(CB.pesoVolumen)
		FROM #Final RF
		INNER JOIN CodigosDeBarra CB ON CB.idCoordinacion = RF.idCoordinacion
		GROUP BY
			RF.idCoordinacion

		-- Guardando la suma de Charg por codigo de barras en la tabla final
		UPDATE #Final
		SET
			coordCBPesoNeto = PP.coordCBPesoNeto,
			coordCBPesoVolumen = PP.coordCBPesoVolumen
		FROM #Final RF
		INNER JOIN #ChargPorCodBarr PP ON PP.idCoordinacion = RF.idCoordinacion

		-- Obtener la suma de Charg por factura desde codigos de barras
		INSERT INTO #SumChargPorCodBarr
		SELECT
			RF.invoice,
			invoiceCBPesoNeto = SUM(CC.coordCBPesoNeto),
			invoiceCBPesoVolumen = SUM(CC.coordCBPesoVolumen),
			invoiceCBMaxCharg = SUM(IIF(CC.coordCBPesoNeto > CC.coordCBPesoVolumen, CC.coordCBPesoNeto, CC.coordCBPesoVolumen))
		FROM #Final RF
		INNER JOIN #ChargPorCodBarr CC ON CC.idCoordinacion = RF.idCoordinacion
		GROUP BY
			RF.invoice

		-- Guardando la suma de Charg por codigo de barras en la tabla final
		UPDATE #Final
		SET
			invoiceCBPesoNeto = PP.invoiceCBPesoNeto,
			invoiceCBPesoVolumen = PP.invoiceCBPesoVolumen,
			invoiceCBMaxCharg = PP.invoiceCBMaxCharg
		FROM #Final RF
		INNER JOIN #SumChargPorCodBarr PP ON PP.invoice = RF.invoice

		-- Por CoordinacionesWarehouse
		-- Obtener el Charg por Warehouse en caso que exista
		INSERT INTO #ChargPorWarehouse 
		SELECT
			RF.idCoordinacion,
			coordWHPesoNeto = SUM(CW.pesoBruto),
			coordWHPesoVolumen = SUM(CW.pesoVolumen)
		FROM #Final RF
		INNER JOIN CoordinacionesWarehouse CW ON CW.idCoordinacion = RF.idCoordinacion
		GROUP BY
			RF.idCoordinacion

		-- Guardando la suma de Charg por warehouse en la tabla final
		UPDATE #Final
		SET
			coordWHPesoNeto = PP.coordWHPesoNeto,
			coordWHPesoVolumen = PP.coordWHPesoVolumen
		FROM #Final RF
		INNER JOIN #ChargPorWarehouse  PP ON PP.idCoordinacion = RF.idCoordinacion

		-- Obtener la suma de Charg por factura desde warehouse
		INSERT INTO #SumChargPorWarehouse
		SELECT
			RF.invoice,
			invoiceWHPesoNeto = SUM(CC.coordWHPesoNeto),
			invoiceWHPesoVolumen = SUM(CC.coordWHPesoVolumen),
			invoiceWHMaxCharg = SUM(IIF(CC.coordWHPesoNeto > CC.coordWHPesoVolumen, CC.coordWHPesoNeto, CC.coordWHPesoVolumen))
		FROM #Final RF
		INNER JOIN #ChargPorWarehouse  CC ON CC.idCoordinacion = RF.idCoordinacion
		GROUP BY
			RF.invoice

		-- Guardando la suma de Charg por warehouse en la tabla final
		UPDATE #Final
		SET
			invoiceWHPesoNeto = PP.invoiceWHPesoNeto,
			invoiceWHPesoVolumen = PP.invoiceWHPesoVolumen,
			invoiceWHMaxCharg = PP.invoiceWHMaxCharg
		FROM #Final RF
		INNER JOIN #SumChargPorWarehouse PP ON PP.invoice = RF.invoice

	-- Fin de obtencion de charg para distribucion

	-- Inicio de redistribucion del charg y calculo de total por exportador
		-- Obtener el charg temporal a usarse para el calculo de distribucion
		-- Logica de chargTmp: Si tiene valores en Warehouse (viene de Colombia) usar el mayor entre peso volumen y peso neto de warehouse,
		-- si no existe valor de warehouse tomar el mayor entre peso volumen y peso neto de codigo de barras (viene de Ecuador)
		UPDATE #Final
		SET
			chargTmp = IIF(invoiceWHMaxCharg IS NULL,
							IIF(coordCBPesoNeto > coordCBPesoVolumen, coordCBPesoNeto, coordCBPesoVolumen),
							IIF(coordWHPesoNeto > coordWHPesoVolumen, coordWHPesoNeto, coordWHPesoVolumen)),
			sumChargTmp = IIF(invoiceWHMaxCharg IS NULL, invoiceCBMaxCharg, invoiceWHMaxCharg),
			invoiceCharg = invoiceAmount / rate
		WHERE tipoRegistro = @TipoCargoFlete

		UPDATE #Final
		SET charg = CONVERT(DECIMAL(23,13),(invoiceCharg * chargTmp))/CONVERT(DECIMAL(23,13),(sumChargTmp))
		WHERE tipoRegistro = @TipoCargoFlete

		-- Recalculando el totalByHAWB
		UPDATE #Final
		SET totalByHAWB = charg * rate
		WHERE tipoRegistro = @TipoCargoFlete

		-- Fin de redistribucion del charg y calculo de total por exportador

		-- Inicio de ajuste de charg y totalbyhawb de decimales finales por redondeo
		INSERT INTO #DescuadreInvoice
		SELECT
			idGuiaDistribucion,
			idConsignatario,
			invoice,
			sumCharg = SUM(charg),
			diffCharg = (invoiceAmount/rate) - SUM(charg),
			sumTotalByHAWB = SUM(totalByHAWB),
			diffTotalByHAWB = invoiceAmount - SUM(totalByHAWB),
			maxhawb = MAX(hawb)
		FROM #Final
		WHERE tipoRegistro = @TipoCargoFlete
		GROUP BY idGuiaDistribucion, idConsignatario, invoice, invoiceAmount, rate
		HAVING invoiceAmount - SUM(totalByHAWB) <> 0

		UPDATE #Final
		SET
			[charg] = RF.charg + DE.diffCharg,
			[totalByHAWB] = RF.totalByHAWB + DE.diffTotalbyhawb
		FROM #Final RF
		INNER JOIN #DescuadreInvoice DE ON DE.idGuiaDistribucion = RF.idGuiaDistribucion
			AND DE.maxhawb = RF.hawb
			AND DE.invoice = RF.invoice
	-- Fin de ajuste de charg y totalbyhawb de decimales finales por redondeo

	SELECT
		id = CONVERT(VARCHAR(10), ROW_NUMBER() OVER (ORDER BY invoiceDate, mawb, consignatario, invoice, tipoRegistro, hawb)),
		invoiceDate = CONVERT(DATETIME, invoiceDate),
		invoice,
		idConsignatario,
		consignatario,
		origin,
		mawb,
		hawb,
		shipper,
		fb,
		charg,
		rate = CONVERT(DECIMAL(18,2), rate),
		totalByHAWB
	FROM #Final
	ORDER BY
		invoiceDate,
		mawb,
		consignatario,
		invoice,
		tipoRegistro,
		hawb
END

/*
===== EJEMPLOS DE USO =====

-- 1. Prueba básica con un consignatario

EXEC AC_pro_GetAccountingAnalyticsReports
	'ETY0000000008142',
	'2026-01-01', 
	'2026-01-10'

EXEC pro_reportes_analiticacontabilidad 
	'CLI0119075', 
	'2026-01-01', 
	'2026-01-10'

-- 2. Prueba con multiples consignatarios

EXEC AC_pro_GetAccountingAnalyticsReports 
	'ETY013489,ETY013490',
	'2026-03-29', 
	'2026-03-31'
	
EXEC pro_reportes_analiticacontabilidad 
	'CLI0120245,CLI0119075', 
	'2026-01-01', 
	'2026-01-10'
*/
/*
VERSION     MODIFIEDBY			MODIFIEDDATE		HU				MODIFICATION
1			Jesús Yandún		2026-03-02			58766			Initial code: Based on pro_documentosDespachoNuevoPODClientes360
*/

CREATE OR ALTER PROCEDURE [dbo].[AC_pro_ShippingDocumentsPODClient360]
(
    @fechaDespachoDesde DATETIME,
    @fechaDespachoHasta DATETIME,
    @nroManifiesto VARCHAR(32) = NULL,
    @nroGuia  VARCHAR(32)= NULL,
    @PO  VARCHAR(64)= NULL,
    @idCarrier  VARCHAR(16)= NULL,
    @codigoDeBarra  VARCHAR(32)= NULL,
    @entityId  VARCHAR(16) = NULL,
    @shipTo VARCHAR(128) = NULL
)
AS
BEGIN
	BEGIN TRY

		DECLARE @fechaDestinoComodin DATETIME = DATEADD(DAY,-15,@fechaDespachoDesde);

		CREATE TABLE #ClientesRelacionados
		(
			EntityId VARCHAR(16),
			IdCliente VARCHAR(16),
			TipoCliente VARCHAR(32)
		);

		CREATE TABLE #ShipTosTemp 
		(
			Id VARCHAR(16)
		);

		CREATE TABLE #temporalPods
		(
			IdGuiasHouseDetalles UNIQUEIDENTIFIER,
			idProgramacionCarrier UNIQUEIDENTIFIER,
			IdGuia VARCHAR(64),
			FechaDespacho DATETIME,
			IdClienteFinal VARCHAR(16),
			IdCarrier VARCHAR(16),
			po VARCHAR(64),
			nroGuia VARCHAR(32),
			codigoBarra VARCHAR(32),
			idBodega VARCHAR(16),
			idEmpresa VARCHAR(16)
		);

		CREATE TABLE #DocumentosPod
		(
			IdGuiaHouse UNIQUEIDENTIFIER,
			Id VARCHAR(64) ,
			NombreDocumento VARCHAR(128) ,
			MailEnviado BIT,
			Procesado VARCHAR(16),
			FechaDespacho DATETIME,
			IdManifiesto VARCHAR(64),
			NroManifiesto VARCHAR(32),
			IdClienteFinal VARCHAR(16),
			NombreClienteFinal VARCHAR(128),
			NombreCliente VARCHAR(128),
			IdCarrier VARCHAR(16),
			NombreCarrier VARCHAR(128),
			IdBodega VARCHAR(16),
			CodigoDocumento VARCHAR(32),
			Estado VARCHAR(16),
			idEmpresa VARCHAR(16)
		)

		IF NULLIF(@shipTo,'') IS NOT NULL
		BEGIN
			INSERT INTO #ShipTosTemp
			SELECT Id
			FROM f_SearchEntities(@shipTo,'Consignee');
		END

		INSERT INTO #ClientesRelacionados
			EXEC AC_pro_GetClientsEntities @EntityId = @entityId;

		INSERT INTO #temporalPods
		SELECT 
			DISTINCT
			GHD.id,
			T.id,
			GH.idGuia,
			T.fechaDespacho,
			GHD.ShipToId,
			T.idCarrier,
			GHD.po,
			GH.nroGuia,
			GHD.codigoBarra,
			GH.idBodega,
			GH.idEmpresa
		FROM ProgramacionCarrier T WITH (NOLOCK)
			INNER JOIN GuiasHouseDetalles GHD WITH (NOLOCK) ON GHD.id = T.idGuiaHouseDetalle
			INNER JOIN GuiasHouse GH WITH (NOLOCK) ON GH.id = GHD.idGuiaHouse
			INNER JOIN v_ClientsEntities CEV ON GHD.ShipToId = CEV.ConsigneeId
			INNER JOIN #ClientesRelacionados CR ON CEV.id = CR.EntityId
		WHERE
			T.fechaDespacho BETWEEN @fechaDespachoDesde AND @fechaDespachoHasta
			AND GHD.fechaCreacion BETWEEN @fechaDestinoComodin AND @fechaDespachoHasta
			AND (@idCarrier IS NULL OR T.idCarrier = @idCarrier)
			AND (@PO IS NULL OR GHD.po LIKE '%' + @PO + '%')
			AND (@codigoDeBarra IS NULL OR GHD.codigoBarra LIKE '%' + @codigoDeBarra + '%')
			AND (@nroGuia IS NULL OR GH.nroGuia LIKE '%' + @nroGuia + '%')
    
		INSERT INTO #temporalPods
		SELECT DISTINCT
			GHD.id,
			T.id,
			GH.idGuia,
			T.fechaDespacho,
			GHD.ShipToId,
			T.idCarrier,
			GHD.po,
			GH.nroGuia,
			GHD.codigoBarra,
			GH.idBodega,
			GH.idEmpresa
		FROM GuiasHouse GH WITH (NOLOCK)
			INNER JOIN GuiasHouseDetalles GHD WITH (NOLOCK) ON GHD.idGuiaHouse = GH.id
			INNER JOIN v_ClientsEntities CEV ON GH.ConsigneeId = CEV.ConsigneeId
			INNER JOIN #ClientesRelacionados CR ON CEV.id = CR.EntityId
			INNER JOIN ProgramacionCarrier T WITH (NOLOCK) ON T.idGuiaHouseDetalle = GHD.id
		WHERE GH.house IS NOT NULL
			AND T.fechaDespacho BETWEEN @fechaDespachoDesde AND @fechaDespachoHasta
			AND GH.fechaDestino BETWEEN @fechaDestinoComodin AND @fechaDespachoHasta
			AND (@idCarrier IS NULL OR T.idCarrier = @idCarrier)
			AND (@PO IS NULL OR GHD.po LIKE '%' + @PO + '%')
			AND (@codigoDeBarra IS NULL OR GHD.codigoBarra LIKE '%' + @codigoDeBarra + '%')
			AND (@nroGuia IS NULL OR GH.nroGuia LIKE '%' + @nroGuia + '%');

		INSERT INTO #temporalPods
		SELECT DISTINCT
			GHD.id,
			T.id,
			GH.idGuia,
			T.fechaDespacho,
			GHD.ShipToId,
			T.idCarrier,
			GHD.po,
			GH.nroGuia,
			GHD.codigoBarra,
			GH.idBodega,
			GH.idEmpresa
		FROM GuiasHouse GH1 WITH (NOLOCK)
			INNER JOIN GuiasHouse GH WITH (NOLOCK) ON GH.idGuia = GH1.idGuia
			INNER JOIN GuiasHouseDetalles GHD WITH (NOLOCK) ON GHD.idGuiaHouse = GH.id
			INNER JOIN v_ClientsEntities CEV ON GH1.ConsigneeId = CEV.ConsigneeId
			INNER JOIN #ClientesRelacionados CR ON CEV.id = CR.EntityId
			INNER JOIN ProgramacionCarrier T WITH (NOLOCK) ON T.idGuiaHouseDetalle = GHD.id
		WHERE GH1.house IS NULL
			AND T.fechaDespacho BETWEEN @fechaDespachoDesde AND @fechaDespachoHasta
			AND GH1.fechaDestino BETWEEN @fechaDestinoComodin AND @fechaDespachoHasta
			AND (@idCarrier IS NULL OR T.idCarrier = @idCarrier)
			AND (@PO IS NULL OR GHD.po LIKE '%' + @PO + '%')
			AND (@codigoDeBarra IS NULL OR GHD.codigoBarra LIKE '%' + @codigoDeBarra + '%')
			AND (@nroGuia IS NULL OR GH1.nroGuia LIKE '%' + @nroGuia + '%');
    
		INSERT INTO #DocumentosPod
		SELECT DISTINCT 
			temp.IdGuiasHouseDetalles,
			DD.id AS IdDocumentosDespacho,
			DD.nombreArchivo AS NombreDocumento,
			ISNULL(DD.mailEnviado,0) AS  MailEnviado,
			CASE
				WHEN  DD.mailEnviado IS NULL
				THEN 'NO' 
				ELSE 'SI' 
			END AS Procesado,
			temp.FechaDespacho,
			M.id AS IdManifiesto,
			M.nroManifiesto,
			IdClienteFinal,
			ce.nombre AS [NombreClienteFinal],
			ce.nombre AS [NombreCliente],
			IdCarrier,
			[TR].[nombre] AS [NombreCarrier],
			ISNULL(UB.idBodega, temp.idBodega) AS idBodega,
			documento.codigo AS CodigoDocumento,
			ce.idEstado,
			temp.idEmpresa
		FROM #temporalPods temp
			INNER JOIN v_ClientsEntities CE ON temp.IdClienteFinal = CE.id
			INNER JOIN Transportes AS TR  WITH (NOLOCK) ON temp.idCarrier = TR.id
			LEFT JOIN ProgramacionManifiesto AS PM  WITH (NOLOCK) ON temp.idProgramacionCarrier = PM.idProgramacionCarrier
			LEFT JOIN ManifiestosDespacho AS M  WITH (NOLOCK) ON PM.idManifiestoDespacho = M.id
			LEFT JOIN DocumentosDespacho AS DD  WITH (NOLOCK) ON M.id = DD.idManifiesto
			LEFT JOIN Documentos AS documento  WITH (NOLOCK) ON DD.idDocumento = documento.id
			LEFT JOIN UbicacionPiezas AS UP WITH (NOLOCK) ON temp.IdGuiasHouseDetalles = UP.idGuiaHouseDetalle
			LEFT JOIN Ubicaciones AS U WITH (NOLOCK) ON UP.idUbicacion = U.id
			LEFT JOIN UbicacionesBodega AS UB WITH (NOLOCK) ON U.idUbicacionBodega = UB.id
			LEFT JOIN #ShipTosTemp ST ON temp.IdClienteFinal = ST.Id
		WHERE (@nroManifiesto IS NULL OR M.nroManifiesto LIKE '%' + @nroManifiesto + '%')
		AND (
			ST.Id IS NOT NULL
			OR NOT EXISTS (SELECT 1 FROM #ShipTosTemp)
		)
        
		SELECT 
			NEWID() AS Id,
			ISNULL(CAST(RE.Id AS VARCHAR(64)),'') AS IdReal,
			ISNULL(NombreDocumento,'') AS NombreDocumento,
			ISNULL(Estado, '-') AS estado,
			MailEnviado,
			Procesado ,
			ISNULL(CAST(IdManifiesto  AS VARCHAR(64)) ,'') AS IdManifiesto,
			ISNULL(NroManifiesto,'') AS NroManifiesto,
			IdClienteFinal ,
			NombreClienteFinal ,
			NombreCliente ,
			IdCarrier ,
			NombreCarrier ,
			FechaDespacho,
			ISNULL(IdBodega,'') AS  IdBodega,
			ISNULL(CodigoDocumento ,'') AS CodigoDocumento,
			COUNT(1) AS numeroPiezas,
			idEmpresa
		FROM #DocumentosPod RE
		WHERE RE.Id IS NULL Or RE.CodigoDocumento = 'MANIFEST'
		GROUP BY  
			RE.Id,
			RE.IdClienteFinal, 
			RE.IdCarrier,
			RE.FechaDespacho,
			RE.NombreDocumento,
			RE.MailEnviado,
			RE.Procesado,
			RE.IdBodega,
			RE.IdManifiesto,
			RE.NroManifiesto,
			RE.Estado,
			RE.CodigoDocumento,
			RE.NombreCliente,
			RE.NombreClienteFinal,
			NombreCarrier,
			RE.idEmpresa
		ORDER BY NombreClienteFinal

		DROP TABLE #ClientesRelacionados
		DROP TABLE #ShipTosTemp
		DROP TABLE #temporalPods
		DROP TABLE #DocumentosPod

	END TRY
		BEGIN CATCH
			EXEC [dbo].[pro_LogError];
			THROW;
	END CATCH

END;

/*

exec sp_executesql N'dbo.AC_pro_ShippingDocumentsPODClient360 @fechaDespachoDesde, @fechaDespachoHasta, @nroManifiesto, @nroGuia, @PO, @idCarrier, @codigoDeBarra, @entityId, @shipTo
',N'@fechaDespachoDesde date,@fechaDespachoHasta date,@nroManifiesto varchar(32),@nroGuia varchar(32),@PO varchar(32),@idCarrier varchar(32),@codigoDeBarra varchar(64),@entityId varchar(32), @shipTo VARCHAR(128)',
@fechaDespachoDesde='2026-02-01',
@fechaDespachoHasta='2026-02-01',
@nroManifiesto=NULL,
@nroGuia=NULL,
@PO=NULL,
@idCarrier=NULL,
@codigoDeBarra=NULL,
@entityId='ETY0000000020555',
@shipTo=NULL

exec sp_executesql N'dbo.AC_pro_ShippingDocumentsPODClient360 @fechaDespachoDesde, @fechaDespachoHasta, @idClienteFinal, @nroManifiesto, @nroGuia, @PO, @idCarrier, @codigoDeBarra, @entityId, @shipTo
',N'@fechaDespachoDesde date,@fechaDespachoHasta date,@idClienteFinal varchar(16),@nroManifiesto varchar(32),@nroGuia varchar(32),@PO varchar(64),@idCarrier varchar(16),@codigoDeBarra varchar(32),@entityId varchar(16),@shipTo varchar(128)',
@fechaDespachoDesde='2026-02-01',
@fechaDespachoHasta='2026-02-01',
@idClienteFinal=NULL,
@nroManifiesto=NULL,
@nroGuia=NULL,
@PO=NULL,
@idCarrier=NULL,
@codigoDeBarra=NULL,
@entityId='ETY0000000020555',
@shipTo='ALF VALLEY FLORAL / FLOW #228'

exec sp_executesql N'dbo.AC_pro_ShippingDocumentsPODClient360 @fechaDespachoDesde, @fechaDespachoHasta, @nroManifiesto, @nroGuia, @PO, @idCarrier, @codigoDeBarra, @entityId, @shipTo
',N'@fechaDespachoDesde date,@fechaDespachoHasta date,@nroManifiesto varchar(32),@nroGuia varchar(32),@PO varchar(64),@idCarrier varchar(16),@codigoDeBarra varchar(32),@entityId varchar(16),@shipTo varchar(128)',
@fechaDespachoDesde='2026-02-01',
@fechaDespachoHasta='2026-02-01',
@nroManifiesto='5476',
@nroGuia=NULL,
@PO=NULL,
@idCarrier=NULL,
@codigoDeBarra=NULL,
@entityId='ETY0000000020555',
@shipTo=NULL
*/
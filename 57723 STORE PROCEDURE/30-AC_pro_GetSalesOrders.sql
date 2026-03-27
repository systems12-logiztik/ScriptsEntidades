/*     
VERSION		AUTOR				FECHA			HU			CAMBIO    
01			Jean Martillo       2026-01-28		57727		Initial code - store procedure based on pro_ObtenerOrdenesDeVenta
*/    
CREATE OR ALTER PROCEDURE [dbo].[AC_pro_GetSalesOrders]    
 @FechaIni DATETIME,    
 @FechaFin DATETIME,    
 @IdSistema INT,    
 @TipoEntidad VARCHAR(16),    
 @IdEmpresa VARCHAR(16),
 @BillToId VARCHAR(16) 
AS    
BEGIN    
 BEGIN TRY  

  SELECT  PC.idCarrier,    
  PC.fechaDespacho,    
  PC.IdGuiaHouseDetalle IdGuiasHouseDetalle,    
  SVD.fechaCambio FechaCambioSolicitudVenta,    
  CASE WHEN SVD.Picking = 1 THEN 1 ELSE 0 END PzasPicking,    
  SVD.idSolicitud,  
  SVD.tipoPieza,  
  SVD.printed  
  INTO #tmp_solicitudes    
  FROM ProgramacionCarrier PC WITH (NOLOCK)     
  INNER JOIN SolicitudDeVentaDetalles SVD WITH (NOLOCK) ON PC.idGuiaHouseDetalle = SVD.idGuiaHouseDetalle    
  WHERE PC.fechaDespacho BETWEEN @FechaIni AND @FechaFin  

  SELECT 
  SOL.IdGuiasHouseDetalle,    
  SOL.fechaDespacho,    
  SOL.IdCarrier,    
  SOL.printed AS impresion,    
  GHD.estadoPieza,    
  GHD.FechaCambio,    
  GHD.IdUsuarioLog,    
  SOL.FechaCambioSolicitudVenta,    
  SOL.PzasPicking,    
  SOL.idSolicitud,    
  SOL.tipoPieza,  
  UBP.nombre,   
  UBP.id,
  GHD.ShipToId,
  CI.BillToId
  INTO #tmp_solicitudes2
  FROM #tmp_solicitudes SOL    
  INNER JOIN GuiasHouseDetalles GHD WITH (NOLOCK,INDEX=PK_GuiasHouseDetalles) ON GHD.id = SOL.idGuiasHouseDetalle    
  INNER JOIN GuiasHouse GH WITH(NOLOCK) ON GHD.idGuiaHouse = GH.id AND GH.idEmpresa = @IdEmpresa  
  LEFT JOIN v_ClientsEntities CI ON GH.ConsigneeId = CI.id  
  OUTER APPLY  (  SELECT TOP 1 BD.nombre, BD.id    
	  FROM UbicacionPiezas UP    
	  INNER JOIN Ubicaciones UB WITH(NOLOCK) ON UP.idUbicacion = UB.id    
	  INNER JOIN UbicacionesBodega UBB WITH(NOLOCK) ON UB.idUbicacionBodega = UBB.id    
	  INNER JOIN Bodegas BD ON UBB.idBodega = BD.id    
	  WHERE UP.idGuiaHouseDetalle = GHD.id    
	  ORDER BY UP.fechaCambio DESC ) UBP

  IF @BillToId IS NOT NULL
  BEGIN
	select * 
	INTO #tmp_solicitudes3
	FROM #tmp_solicitudes2 
	WHERE BillToId = @BillToId 

	SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS Id,    
    SV.id AS IdOrdenVenta,    
    SOL.IdGuiasHouseDetalle,    
    '' EstatusImpresion,    
    '' ClaseCssEstatusImpresion,    
    '' TraduccionEstatusImpresion,    
    CASE WHEN SOL.impresion > 0 THEN 1 ELSE 0 END PzasImpresas,    
    0 OrdenEstatus,    
    '' Estatus,    
    '' ClaseCssEstatus,    
    SV.NroOrden NroOrdenVenta,    
    IIF(SV.TipoVenta = 2, UV.nombre, SE.Nombre) SistemaClientePosteoVenta,    
    CLI.Id IdClienteFinal,    
    CLI.nombre AS ClienteFinal,  
    ISNULL(P.nombre,'') Pais,    
    ISNULL(P.codigoISO,'') CodigoPais,    
    ISNULL(E.nombre,'') Estado,    
    ISNULL(E.codigoISO,'') CodigoEstado,    
    T.Id IdCarrier,    
    T.nombre Carrier,    
    ISNULL(CRS.Codigo,'') CodigoCarrier,    
    COALESCE(ECO.CutOff,HT.HoraMaximaVenta) CutOff,    
    SOL.fechaDespacho,    
    '' FechaDespachoString,    
    1 PzasRequeridas,    
    CASE WHEN SOL.estadoPieza = 'DISPATCHED WH' THEN 1 ELSE 0 END PzasDespachadas,    
    CASE WHEN SOL.estadoPieza = 'RECEIVED WH' THEN 1 ELSE 0 END PzasRecivedWh,    
    0 PzasNoPicked,    
    SV.fechaSolicitud FechaVenta,    
    CAST(SV.fechaSolicitud AS DATE) FechaVentaSinHora,    
    '' FechaVentaString,    
    CASE WHEN EM.nombres IS NOT NULL AND EM.nombres != '' THEN EM.nombres ELSE CL.nombre END NombresUsuario,    
    CASE WHEN EM.Apellidos IS NOT NULL AND EM.Apellidos != '' THEN EM.Apellidos ELSE CL.nombre END ApellidosUsuario,    
    SOL.FechaCambio,    
    SOL.fechaCambio FechaCambioSolicitudVenta,    
    '' UsuarioFechaCambio,     
    CASE WHEN (SELECT TOP 1 1 FROM SolicitudDeVentaNotificaciones sdvn WHERE sdvn.idSolicitudDeVenta = SV.id) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END TieneNotificaciones,           
    SOL.PzasPicking,    
    0 PzasNoDespachadas,    
    CAST(SV.impresion AS BIT) Impresion,    
    SOL.nombre AS Bodega,    
    SOL.id IdBodega  
    FROM #tmp_solicitudes3 SOL    
    INNER JOIN SolicitudDeVenta SV WITH (NOLOCK) ON SV.id = SOL.idSolicitud  
    INNER JOIN SistemasEntidades SE WITH (NOLOCK) on SV.IdSistemaEntidad = SE.Id
    INNER JOIN v_ClientsEntities CLI WITH (NOLOCK) on SOL.ShipToId = CLI.Id    
    INNER JOIN Usuarios U WITH (NOLOCK) on SOL.IdUsuarioLog = U.Id    
    INNER JOIN Usuarios UV WITH (NOLOCK) on SV.IdUsuarioLog = UV.Id    
    INNER JOIN Transportes T WITH (NOLOCK) ON SOL.IdCarrier = T.Id     
    INNER JOIN DiasSemana DS WITH (NOLOCK) ON (CASE WHEN DATEPART(WEEKDAY, SOL.FechaDespacho)=7 THEN 0 ELSE DATEPART(WEEKDAY, SOL.FechaDespacho) END) = DS.Numero    
    LEFT JOIN CodigosRelacionSistemas CRS WITH (NOLOCK) ON CRS.TipoEntidad = @TipoEntidad AND CRS.idSistemaEntidad = @IdSistema    
    AND T.id = CRS.idEntidad    
    LEFT JOIN HorarioTransportes HT WITH (NOLOCK) ON T.Id = HT.IdTransporte AND DS.Id = HT.IdDiaSemana    
    LEFT JOIN ExcepcionesCutOff ECO WITH (NOLOCK) ON SOL.IdCarrier = ECO.IdCarrier AND SOL.FechaDespacho = ECO.FechaExcepcion      
    LEFT JOIN Paises P WITH (NOLOCK) ON CLI.IdPais = P.Id    
    LEFT JOIN Estados E WITH (NOLOCK) ON CLI.IdEstado = E.Id    
    LEFT JOIN Empleados EM WITH (NOLOCK) ON U.IdEntidad = EM.Id    
    LEFT JOIN v_ClientsEntities CL WITH (NOLOCK) ON U.EntityTypeId = CL.Id
    WHERE SOL.IdCarrier IS NOT NULL   
    AND ( SV.tipoVenta < 4   
    OR (SV.tipoVenta = 5 AND SOL.tipoPieza = 1))  

	DROP TABLE #tmp_solicitudes3 

 END
 ELSE
 BEGIN
   SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS Id,    
    SV.id AS IdOrdenVenta,    
    SOL.IdGuiasHouseDetalle,    
    '' EstatusImpresion,    
    '' ClaseCssEstatusImpresion,    
    '' TraduccionEstatusImpresion,    
    CASE WHEN SOL.impresion > 0 THEN 1 ELSE 0 END PzasImpresas,    
    0 OrdenEstatus,    
    '' Estatus,    
    '' ClaseCssEstatus,    
    SV.NroOrden NroOrdenVenta,    
    IIF(SV.TipoVenta = 2, UV.nombre, SE.Nombre) SistemaClientePosteoVenta,    
    CLI.Id IdClienteFinal,    
    CLI.nombre AS ClienteFinal,  
    ISNULL(P.nombre,'') Pais,    
    ISNULL(P.codigoISO,'') CodigoPais,    
    ISNULL(E.nombre,'') Estado,    
    ISNULL(E.codigoISO,'') CodigoEstado,    
    T.Id IdCarrier,    
    T.nombre Carrier,    
    ISNULL(CRS.Codigo,'') CodigoCarrier,    
    COALESCE(ECO.CutOff,HT.HoraMaximaVenta) CutOff,    
    SOL.fechaDespacho,    
    '' FechaDespachoString,    
    1 PzasRequeridas,    
    CASE WHEN SOL.estadoPieza = 'DISPATCHED WH' THEN 1 ELSE 0 END PzasDespachadas,    
    CASE WHEN SOL.estadoPieza = 'RECEIVED WH' THEN 1 ELSE 0 END PzasRecivedWh,    
    0 PzasNoPicked,    
    SV.fechaSolicitud FechaVenta,    
    CAST(SV.fechaSolicitud AS DATE) FechaVentaSinHora,    
    '' FechaVentaString,    
    CASE WHEN EM.nombres IS NOT NULL AND EM.nombres != '' THEN EM.nombres ELSE CL.nombre END NombresUsuario,    
    CASE WHEN EM.Apellidos IS NOT NULL AND EM.Apellidos != '' THEN EM.Apellidos ELSE CL.nombre END ApellidosUsuario,    
    SOL.FechaCambio,    
    SOL.fechaCambio FechaCambioSolicitudVenta,    
    '' UsuarioFechaCambio,     
    CASE WHEN (SELECT TOP 1 1 FROM SolicitudDeVentaNotificaciones sdvn WHERE sdvn.idSolicitudDeVenta = SV.id) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END TieneNotificaciones,           
    SOL.PzasPicking,    
    0 PzasNoDespachadas,    
    CAST(SV.impresion AS BIT) Impresion,    
    SOL.nombre AS Bodega,    
    SOL.id IdBodega  
    FROM #tmp_solicitudes2 SOL    
    INNER JOIN SolicitudDeVenta SV WITH (NOLOCK) ON SV.id = SOL.idSolicitud  
    INNER JOIN SistemasEntidades SE WITH (NOLOCK) on SV.IdSistemaEntidad = SE.Id
    INNER JOIN v_ClientsEntities CLI WITH (NOLOCK) on SOL.ShipToId = CLI.Id    
    INNER JOIN Usuarios U WITH (NOLOCK) on SOL.IdUsuarioLog = U.Id    
    INNER JOIN Usuarios UV WITH (NOLOCK) on SV.IdUsuarioLog = UV.Id    
    INNER JOIN Transportes T WITH (NOLOCK) ON SOL.IdCarrier = T.Id     
    INNER JOIN DiasSemana DS WITH (NOLOCK) ON (CASE WHEN DATEPART(WEEKDAY, SOL.FechaDespacho)=7 THEN 0 ELSE DATEPART(WEEKDAY, SOL.FechaDespacho) END) = DS.Numero    
    LEFT JOIN CodigosRelacionSistemas CRS WITH (NOLOCK) ON CRS.TipoEntidad = @TipoEntidad AND CRS.idSistemaEntidad = @IdSistema    
    AND T.id = CRS.idEntidad    
    LEFT JOIN HorarioTransportes HT WITH (NOLOCK) ON T.Id = HT.IdTransporte AND DS.Id = HT.IdDiaSemana    
    LEFT JOIN ExcepcionesCutOff ECO WITH (NOLOCK) ON SOL.IdCarrier = ECO.IdCarrier AND SOL.FechaDespacho = ECO.FechaExcepcion      
    LEFT JOIN Paises P WITH (NOLOCK) ON CLI.IdPais = P.Id    
    LEFT JOIN Estados E WITH (NOLOCK) ON CLI.IdEstado = E.Id    
    LEFT JOIN Empleados EM WITH (NOLOCK) ON U.IdEntidad = EM.Id    
    LEFT JOIN v_ClientsEntities CL WITH (NOLOCK) ON U.EntityTypeId = CL.Id
    WHERE SOL.IdCarrier IS NOT NULL   
    AND ( SV.tipoVenta < 4   
    OR (SV.tipoVenta = 5 AND SOL.tipoPieza = 1))
 END
 
  DROP TABLE #tmp_solicitudes    
  DROP TABLE #tmp_solicitudes2   
  
 END TRY    
 BEGIN CATCH    
  EXEC [dbo].[pro_LogError]     
 END CATCH    
END      

/*    
execute dbo.AC_pro_GetSalesOrders '25/01/2026 00:00:00', '10/02/2026 00:00:00', 100, 'CARRIER', 'EMP014';
execute dbo.AC_pro_GetSalesOrders '22/02/2026 00:00:00', '24/02/2026 00:00:00', 100, 'CARRIER', 'EMP014', 'ETY0000000008684';
execute dbo.AC_pro_GetSalesOrders '22/02/2026 00:00:00', '24/02/2026 00:00:00', 100, 'CARRIER', 'EMP014', null;
*/ 
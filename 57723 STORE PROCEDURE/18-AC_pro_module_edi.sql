/*    
VERSION     MODIFIEDBY			MODIFIEDDATE		HU				MODIFICATION
1		    Jesús Yandún	    2026-02-13	        57732		    INITIAL CODE: based on pro_modulo_edi
*/
CREATE OR ALTER PROCEDURE [dbo].[AC_pro_Module_Edi]
    @fechaDesde DATETIME,
    @fechaHasta DATETIME,
    @carrier VARCHAR(16) = NULL,
    @NroDocumento VARCHAR(32) = NULL,
    @consulta INT,
    @Billto VARCHAR(128) = NULL
AS
BEGIN
    DECLARE @idEntidadSystem INT = 100;

    CREATE TABLE #BillTosTemp
    (
        Id VARCHAR(16)
    );

    IF(@Billto != '')
	BEGIN		
		INSERT INTO #BillTosTemp
		SELECT Id FROM f_SearchEntities(@billTo, 'BillTo');
    END;

    IF (@consulta = 1)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM ProgramacionCarrier PC  WITH(NOLOCK)
			INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN GuiasHouse GH  WITH(NOLOCK) ON GHD.idGuiaHouse = GH.id
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id =  CRS.idEntidad AND  CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
              AND PC.idCarrier = @carrier
			  AND CA.codigo = 'EstadosGuiasWareHose'
              AND TRP.envioXML = 1;
    END;
    ELSE IF (@consulta = 2)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM ProgramacionCarrier PC  WITH(NOLOCK)
			INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN GuiasHouse GH  WITH(NOLOCK) ON GHD.idGuiaHouse = GH.id
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id =  CRS.idEntidad AND  CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
              AND TRP.envioXML = 1
			  AND CA.codigo = 'EstadosGuiasWareHose'
              AND GH.nroGuia LIKE '%' + @NroDocumento + '%';
    END;
    ELSE IF (@consulta = 3)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM ProgramacionCarrier PC  WITH(NOLOCK)
			INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN GuiasHouse GH  WITH(NOLOCK) ON GHD.idGuiaHouse = GH.id
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id =  CRS.idEntidad AND  CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
			  AND CA.codigo = 'EstadosGuiasWareHose'
              AND TRP.envioXML = 1;
    END;
    ELSE IF (@consulta = 4)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM ProgramacionCarrier PC  WITH(NOLOCK)
			INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN GuiasHouse GH  WITH(NOLOCK) ON GHD.idGuiaHouse = GH.id
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id = CRS.idEntidad AND CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
              AND TRP.envioXML = 1
              AND PC.idCarrier = @carrier
			  AND CA.codigo = 'EstadosGuiasWareHose'
              AND GH.nroGuia LIKE '%' + @NroDocumento + '%';
    END;
    ELSE IF (@consulta = 5)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM #BillTosTemp BT
            INNER JOIN GuiasHouse GH WITH(NOLOCK) ON BT.Id = GH.BillToConsigneeId
            INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GH.id = GHD.idGuiaHouse
            INNER JOIN ProgramacionCarrier PC WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id = CRS.idEntidad AND CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
              AND TRP.envioXML = 1
              AND PC.idCarrier = @carrier
			  AND CA.codigo = 'EstadosGuiasWareHose'
              AND GH.nroGuia LIKE '%' + @NroDocumento + '%'
    END;
    ELSE IF (@consulta = 6)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM #BillTosTemp BT
            INNER JOIN GuiasHouse GH WITH(NOLOCK) ON BT.Id = GH.BillToConsigneeId
            INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GH.id = GHD.idGuiaHouse
            INNER JOIN ProgramacionCarrier PC WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id = CRS.idEntidad AND CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
              AND TRP.envioXML = 1
              AND PC.idCarrier = @carrier
			  AND CA.codigo = 'EstadosGuiasWareHose'
    END;
    ELSE IF (@consulta = 7)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM #BillTosTemp BT
            INNER JOIN GuiasHouse GH WITH(NOLOCK) ON BT.Id = GH.BillToConsigneeId
            INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GH.id = GHD.idGuiaHouse
            INNER JOIN ProgramacionCarrier PC WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id = CRS.idEntidad AND CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
              AND TRP.envioXML = 1
			  AND CA.codigo = 'EstadosGuiasWareHose'
              AND GH.nroGuia LIKE '%' + @NroDocumento + '%'
    END;
    ELSE IF (@consulta = 8)
    BEGIN
        SELECT GHD.id AS Id,
               GH.idGuia AS IdGuia,
               GH.estadoGuia AS EstadoGuia,
               GH.nroGuia AS NroGuia,
               GH.fechaDestino AS FechaDestino,
               PC.fechaDespacho AS FechaDespacho,
               CRS.codigo AS Codigo,
               TR.nombre AS Nombre,
               GHD.estadoPieza AS EstadoPieza,
               BD.nombre AS Bodega,
               PC.idCarrier AS IdCarrier,
               GHD.ShipToId AS IdClienteFinal,
               BD.id AS IdBodega,
               PGE.estadoPiezaEdi AS EstadoPiezaEdi,
			   CONVERT(NVARCHAR (50), PGE.idEDI) as IdEdi,
			   CA.orden AS Orden
        FROM #BillTosTemp BT
            INNER JOIN GuiasHouse GH WITH(NOLOCK) ON BT.Id = GH.BillToConsigneeId
            INNER JOIN GuiasHouseDetalles GHD WITH(NOLOCK) ON GH.id = GHD.idGuiaHouse
            INNER JOIN ProgramacionCarrier PC WITH(NOLOCK) ON GHD.id = PC.idGuiaHouseDetalle
            INNER JOIN Bodegas BD ON GH.idBodega = BD.id
            INNER JOIN Transportes TR WITH(NOLOCK) ON PC.idCarrier = TR.id
            INNER JOIN Transportes TRP WITH(NOLOCK) ON TR.idTransportePrincipal = TRP.id
			INNER JOIN Catalogos CA ON GH.estadoGuia = CA.codigoRelacion
            INNER JOIN CodigosRelacionSistemas CRS WITH(NOLOCK) ON TR.id = CRS.idEntidad AND CRS.idSistemaEntidad = @idEntidadSystem
            LEFT JOIN ProgramacionEDI PGE WITH(NOLOCK) ON PC.id = PGE.idProgramacionCarrier
        WHERE PC.fechaDespacho
              BETWEEN @fechaDesde AND @fechaHasta
              AND TRP.envioXML = 1
			  AND CA.codigo = 'EstadosGuiasWareHose'
    END;
END;

/*
exec sp_executesql N'AC_pro_Module_Edi @fechaDesde, @fechaHasta, @carrier, @NroDocumento, @consulta, @Billto
',N'@fechaDesde datetime,@fechaHasta datetime,@carrier varchar(16),@NroDocumento varchar(16),@consulta int,@Billto varchar(128)',
@fechaDesde='19-02-2026 00:00:00',
@fechaHasta='26-02-2026 00:00:00',
@carrier=NULL,
@NroDocumento=NULL,
@consulta=8,
@Billto='GARDENS AMERICA INC GROUP';

exec sp_executesql N'AC_pro_Module_Edi @fechaDesde, @fechaHasta, @carrier, @NroDocumento, @consulta, @Billto  ',N'
@fechaDesde datetime,@fechaHasta datetime,@carrier varchar(16),@NroDocumento varchar(32),@consulta int,@Billto varchar(128)',
@fechaDesde='01-12-2025 00:00:00',
@fechaHasta='06-01-2026 00:00:00',
@carrier=NULL,
@NroDocumento=NULL,
@consulta=3,
@Billto=NULL;
*/
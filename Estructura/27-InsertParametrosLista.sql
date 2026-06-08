/* 
VERSION		MODIFIEDBY			MODIFIEDDATE	HU					MODIFICATION
1			Jorge Ortiz			2025-04-22		55188				Initial Code - Add new ParametersList for all companies
2			Jorge Ortiz			2025-11-10		LAG-CT-013 53071	Initial Code - Add new ParametersList for all companies
3			Oscar Yunda			2026-06-01		LAG-CT-036 66043	Initial Code - Add new ParametersList for all TarifaServicioLocal
*/
IF NOT EXISTS(
    SELECT TOP 1 1
    FROM ParametrosLista pl
    WHERE pl.codigo IN (
        'TipoServicioBrindaCliente', 'NombreExportadorParaManifiestos', 'RepeticionCodigosBarraCliente', 
        'UsarCodigoBarraCliente', 'PermitirCambiosNumeroHouse', 'NivelVisualizacionCoordinaciones','GuardarDimensionesDesdeXMLCliente',
        'EnvioDocumentosArchivosAdjuntos', 'AgrupacionParaFacturarServiciosLocales', 'AgrupacionParaFacturarProcesosConsolidados',
		'TipoDeManifiesto'
    ) 
    AND pl.tipo IN('DESPACHO', 'CODIGOBARRA', 'COORDINACION', 'INTEGRACION', 'DOCUMENTACION', 'FACTURACION')
)
BEGIN 
    DECLARE @idEmpresa VARCHAR(16);
    DECLARE @newId VARCHAR(16);

	--==============================EnvioDocumentosArchivosAdjuntos GLOBAL===============================
 	EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
	INSERT INTO dbo.ParametrosLista
	(
		id, 
		codigo, 
		descripcion, 
		tipo, 
		actor, 
		nota, 
		fechaCambio, 
		[status], 
		idEmpresa, 
		tipoActor, 
		enumerador,
		detailDescription
	)
	VALUES
	(
		@newId,
		'EnvioDocumentosArchivosAdjuntos',
		'Envío de documentos como archivos adjuntos',
		'DOCUMENTACION',
		'BILLTO',
		'This parameter determines whether the documents sent to the customer will be attached directly to the email or if a link will be provided for the customer to download them.',
		GETDATE(),
		'ACTIVO',
		NULL,
		NULL,
		'SiNoTipo',
	    '{"description":{"es-US":"Envío de documentos como archivos adjuntos","en-US":"Sending documents as attachments"},"detail":{"es-US":"Este parámetro determina si los documentos enviados al cliente serán adjuntados directamente al correo electrónico o si se enviará un enlace para que el cliente los descargue. Tiene dos opciones:<br><br>Sí: Los archivos se enviarán como adjuntos al correo electrónico.<br>No: Los documentos se enviarán mediante una URL o enlace que redirige al cliente para que los descargue según la necesidad.","en-US":"This parameter determines whether the documents sent to the customer will be attached directly to the email or if a link will be provided for the customer to download them. There are two options:<br><br>Yes: The files will be sent as attachments to the email.<br>No: The documents will be sent via a URL or link that redirects the customer to download them as needed."}}'
 	);

    DECLARE empresa_cursor CURSOR FOR
    SELECT E.id 
    FROM Empresas E

    OPEN empresa_cursor;
    FETCH NEXT FROM empresa_cursor INTO @idEmpresa;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'TipoServicioBrindaCliente', 
				'Tipo de servicio que brinda el cliente', 
				'COORDINACION', 
				'BILLTO', 
				'This parameter defines the type of service provided by the customer', 
				GETDATE(), 
				'ACTIVO',
				@idEmpresa, 
				NULL, 
				'TipoServicioBrindaCliente',
				'{"description":{"es-US":"Tipo de servicio que brinda el cliente","en-US":"Type of service provided by the customer"},"detail":{"es-US":"Este parámetro determina el tipo de servicio que ofrece el cliente (por ejemplo, si es una comercializadora) y, con base en eso, modifica cómo se presenta la información en las etiquetas generadas dentro del módulo de coordinaciones. El sistema valida esta configuración jerárquicamente. Primero revisa la opción escogida en el \"Consignatario\", en caso de estar vacío, busca la opción a nivel del \"Bill-To\".<br><br>El Bill-To se puede definir como \"Comercializadora\", en este caso el sistema hace lo siguiente: En el módulo de coordinaciones, en la etiqueta generada, en lugar de imprimir el nombre del \"ship-to\" o destinatario final, imprime el nombre del consignatario.","en-US":"This parameter defines the type of service provided by the customer (for example, if they are a distributor) and, based on that, modifies how information is displayed on the labels generated within the coordination module. The system validates this configuration hierarchically. It first checks the option selected for the Consignee, and if it''s not set, it looks for the setting at the Bill-To level.<br><br>The Bill-To can be defined as a \"Distributor\". In this case, the system behaves as follows: In the coordination module, on the generated label, instead of printing the name of the Ship-To or final recipient, it prints the name of the consignee."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'NombreExportadorParaManifiestos', 
				'Nombre de exportador para manifiestos', 
				'DESPACHO', 
				'BILLTO', 
				'When generating the manifest, if this parameter contains information, it will be the value displayed in the \"Supplier\" field of the manifest for the End Customer', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				NULL, 
				'{"description":{"es-US":"Nombre de exportador para manifiestos","en-US":"Exporter name for manifest"},"detail":{"es-US":"Al generar el manifiesto, sí este parámetro contiene información, será el valor que se muestra en el campo \"Supplier\" del manifiesto por Cliente Final. Si el parámetro es vacío toma el mismo nombre del campo Exportador.","en-US":"When generating the manifest, if this parameter contains information, it will be the value displayed in the \"Supplier\" field of the manifest for the End Customer. If the parameter is empty, it will take the same name as the Exporter field"}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'RepeticionCodigosBarraCliente', 
				'Repetición de códigos de barra del cliente', 
				'CODIGOBARRA', 
				'BILLTO',
				'This parameter defines whether the barcodes provided by the client are allowed to be repeated or must be unique within the system', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				'SiNoTipo',
				'{"description":{"es-US":"Repetición de códigos de barra del cliente","en-US":"Client Barcode Duplication"},"detail":{"es-US":"Este parámetro define si se permite que los códigos de barras proporcionados por el cliente puedan repetirse o si deben ser únicos en el sistema.","en-US":"This parameter defines whether the barcodes provided by the client are allowed to be repeated or must be unique within the system."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'UsarCodigoBarraCliente', 
				'Usar solo código de barra del cliente', 
				'CODIGOBARRA', 
				'BILLTO',
				'This parameter defines whether the system allows the use of barcodes generated by the system, or if only the barcodes generated and provided by the client are permitted.', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				'SiNoTipo',
				'{"description":{"es-US":"Usar solo código de barra del cliente","en-US":"Use only client barcode"},"detail":{"es-US":"Este parámetro determina en el sistema si se pueden utilizar códigos de barras generados por el sistema o si únicamente se permiten aquellos códigos de barras generados y enviados por el cliente.","en-US":"This parameter defines whether the system allows the use of barcodes generated by the system, or if only the barcodes generated and provided by the client are permitted."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'PermitirCambiosNumeroHouse', 
				'Permitir cambios en el número de House', 
				'COORDINACION', 
				'BILLTO',
				'This parameter determines whether it is possible to make changes to the House number or if only the number automatically generated by the system should be used', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				'SiNoTipo',
				'{"description":{"es-US":"Permitir cambios en el número de House","en-US":"Allow changes to the House number"},"detail":{"es-US":"Este parámetro determina si es posible realizar cambios en el número de la House o si se únicamente se debe utilizar el número generado automáticamente por el sistema.","en-US":"This parameter determines whether it is possible to make changes to the House number or if only the number automatically generated by the system should be used."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'NivelVisualizacionCoordinaciones', 
				'Nivel de visualización en coordinaciones', 
				'COORDINACION', 
				'BILLTO',
				'This parameter defines whether, when there is a group of suppliers, each supplier can only view their own coordination requests in the menu', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL,
				'NivelVisualizacionCoordinaciones',
				'{"description":{"es-US":"Nivel de visualización en coordinaciones","en-US":"Coordination visibility level"},"detail":{"es-US":"Este parámetro define si, al tener un grupo de proveedores, cada proveedor puede visualizar únicamente sus propias coordinaciones en el menú o si, por el contrario, puede ver también las coordinaciones de todos los proveedores pertenecientes al mismo grupo.","en-US":"This parameter defines whether, when there is a group of suppliers, each supplier can only view their own coordination requests in the menu, or if they can also see the coordination requests of all other suppliers within the same group."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador, 
				detailDescription
			)
			VALUES
			(
				@newId, 
				'GuardarDimensionesDesdeXMLCliente', 
				'Guardar dimensiones desde el XML del cliente', 
				'INTEGRACION', 
				'BILLTO',
				'When an XML file sent by a client is received for the creation of a coordination request through a purchase order (PO)', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				'SiNoTipo',
				'{"description":{"es-US":"Guardar dimensiones desde el XML del cliente","en-US":"Save dimensions from client XML"},"detail":{"es-US":"Cuando se recibe un XML enviado por un cliente para la creación de una solicitud de coordinaciones mediante una orden de compra (PO), este parámetro determina si se deben guardar o no las dimensiones proporcionadas por código de barra incluidos en dicho XML.","en-US":"When an XML file sent by a client is received for the creation of a coordination request through a purchase order (PO), this parameter determines whether the dimensions provided via barcode included in the XML should be saved or not."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion, 
				tipo, 
				actor, 
				nota, 
				fechaCambio, 
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'AgrupacionParaFacturarServiciosLocales', 
				'Agrupación para facturar servicios locales', 
				'FACTURACION', 
				'BILLTO', 
				'This parameter defines the grouping method for invoicing of local services', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				'AgrupacionParaFacturarServiciosLocales', 
				'{"description":{"es-US":"Agrupación para facturar servicios locales","en-US":"Grouping for billing local services"},"detail":{"es-US":"Este parámetro define la forma de agrupar una factura de servicios locales. <br><br> El primer criterio de agrupación será el código contable registrado en el catálogo del Bill-to, como segundo criterio, se puede seleccionar entre las siguientes opciones: <br><br>1. Servicio: La factura se generará según el tipo de servicio prestado. Por ejemplo, si se incluyen servicios como Inventario, Pallet y Flete, se creará una línea en la factura por cada uno de ellos.<br>2. Fecha de ejecución: La factura se generará de acuerdo con la fecha de ejecución del servicio. Por ejemplo, si se realizaron 3 servicios en 3 fechas distintas, se crearán 3 líneas en la factura, una por cada fecha.<br>3. Número de referencia: La factura se generará en función del número de referencia del servicio local. Por ejemplo, si existen 3 referencias distintas, se crearán 3 líneas en la factura, una por cada referencia.","en-US":"This parameter defines the grouping method for invoicing of local services.<br><br>The first grouping criterion is the accounting code registered in the Bill-to catalog. As a second criterion, one of the following options can be selected:<br><br>1. Service: The invoice will be generated based on the type of service provided. For example, if services such as Inventory, Pallet and Freight are included, 3 lines will be created in the invoice, one for each service.<br>2. Execution Date: The invoice will be generated based on the service execution date. For example, if 3 services were performed on 3 different dates, 3 lines will be created in the invoice, one for each date.<br>3. Reference Number: The invoice will be generated based on the local service reference number. For example, if there are 3 different references, 3 lines will be created in the invoice, one for each reference."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion,
				tipo, 
				actor, 
				nota, 
				fechaCambio,
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'AgrupacionParaFacturarProcesosConsolidados', 
				'Agrupación para facturar procesos consolidados', 
				'FACTURACION', 
				'BILLTO', 
				'This parameter defines the grouping method for a booking generated from the origin', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				'AgrupacionParaFacturarProcesosConsolidados', 
				'{"description":{"es-US":"Agrupación para facturar procesos consolidados","en-US":"Grouping for billing consolidated processes"},"detail":{"es-US":"Este parámetro define la forma de agrupación de un booking generado desde el origen (es decir, un consolidado), para estructurar la información que se utilizará en la generación del archivo de facturación (formato .CSV), el cual será posteriormente cargado en el sistema contable SAGE para emitir la factura.<br><br>El primer criterio de agrupación será el código contable registrado en el catálogo del Bill-to, como segundo criterio, se puede seleccionar entre las siguientes opciones:<br><br>1. 1 Factura para Fletes y 1 Factura para Duties: Los Fletes y los Cargos (Duties) se agrupan en números de factura separados: Un número de factura para los Fletes y otro número de factura para los Cargos:<br>     Por ejemplo: Sí son 3 reservas, se genera 1 número de factura para Fletes y 1 número de factura para Cargos.<br><br>2. 1 Factura para Fletes y Duties: Los Fletes y los Cargos (Duties) se agrupan en un único número de factura.<br>     Por ejemplo: Sí son 3 reservas, se genera 1 solo número de factura agrupando Fletes y Cargos (Duties).<br><br>3. 1 Factura para Fletes y 1 Factura para Duties por cada reserva: Los Fletes y los Cargos (Duties) se agrupan en números de factura separados, pero organizados por número de reserva: Un número de factura para los Fletes de cada reserva y otro número de factura para los Cargos por cada reserva.<br>   Por ejemplo: Sí son 3 reservas, se generan 3 números de factura para Fletes y 3 números de facturas para Cargos.<br><br>4. 1 Factura para Fletes y Duties por reserva: Los Fletes y los Cargos (Duties) se agrupan en un único número de factura, por cada número de reserva.<br>     Por ejemplo: Sí son 3 reservas, se generan 3 números de factura agrupando Fletes y Cargos (Duties).","en-US":"This parameter defines the grouping method for a booking generated from the origin (i.e., a consolidation), to structure the information used in the creation of the invoicing file (.CSV format), which will later be uploaded to the SAGE accounting system for invoice generation.<br><br>The first grouping criterion is the accounting code registered in the Bill-to catalog. As a second criterion, one of the following options can be selected:<br><br>1. 1 invoice for Freight and 1 invoice for Duties: Freight charges and duties are grouped into separate invoice numbers — one invoice for freight and another for duties.<br>Example: If there are 3 bookings, one invoice will be generated for freight and one invoice for duties.<br><br>2. 1 invoice for Freight and Duties: Freight charges and duties are grouped into a single invoice number.Example: If there are 3 bookings, only one invoice number will be generated grouping freight and duties.<br><br>3. 1 invoice for Freight and 1 invoice for Duties per booking: Freight charges and duties are grouped into separate invoice numbers, but organized by booking. That is, one invoice for the freight of each booking and one invoice for the duties of each booking.<br>Example: If there are 3 bookings, 3 freight invoices and 3 duties invoices will be generated.<br><br>4. 1 invoice for Freight and Duties per booking: Freight charges and duties are grouped into a single invoice, but one per booking. Example: If there are 3 bookings, 3 invoices will be generated grouping freight and duties."}}'
			);

			EXEC dbo.PRO_General_GenerarIdUnico 'ParametrosLista', @IdUnico = @newId OUTPUT;
			INSERT INTO dbo.ParametrosLista
			(
				id, 
				codigo, 
				descripcion,
				tipo, 
				actor, 
				nota, 
				fechaCambio,
				[status], 
				idEmpresa, 
				tipoActor, 
				enumerador,
				detailDescription
			)
			VALUES
			(
				@newId, 
				'TipoDeManifiesto', 
				'Tipo de Manifiesto', 
				'DESPACHO', 
				'BILLTO',
				'This parameter allows configuring the type of format to be generated for the manifest at the time of dispatch', 
				GETDATE(), 
				'ACTIVO', 
				@idEmpresa, 
				NULL, 
				'TipoDeManifiesto', 
				'{"description":{"es-US":"Tipo de Manifiesto","en-US":"Manifest Type"},"detail":{"es-US":"Este parámetro permite configurar el tipo de formato que se debe generar para el manifiesto al momento de realizar un despacho. La información se visualiza por exportador. Las opciones disponibles son:<br>1. Manifiesto Normal: Organiza la información en orden alfabético según la columna \"Proveedor\".<br>2. Manifiesto por Producto: Incluye una columna adicional con la información del producto.<br>3. Manifiesto por Truck ID: Genera un documento agrupado por cada identificador de camión (Truck ID).<br>4. Manifiesto por Número de Documento: Genera un documento agrupado por número de waybill.<br>5. Manifiesto por PO: Genera un documento agrupado por cada orden de compra (PO).<br>6. Manifiesto por EDI: Formato específico para integraciones vía EDI (Electronic Data Interchange), este manifiesto contiene una columna con nombre del proveedor que viene desde el EDI.<br>7. Manifiesto PYF: (Formato Plantas y Flores) Genera un formato específico para el cliente Interaxion.<br>El sistema valida esta configuración jerárquicamente. Primero revisa la opción escogida en el \"Consignatario\", en caso de estar vacío, busca la opción a nivel del \"Bill-To\".","en-US":"This parameter allows configuring the type of format to be generated for the manifest at the time of dispatch. The information is displayed per exporter. The available options are:<br>1. Normal Manifest: Organizes the information in alphabetical order based on the \"Supplier\" column.<br>2. Manifest by Product: Adds an additional column with product information.<br>3. Manifest by Truck ID: Generates a document grouped by each Truck ID.<br>4. Manifest by Document Number: Generates a document grouped by waybill number.<br>5. Manifest by PO: Generates a document grouped by each Purchase Order (PO).<br>6. Manifest by EDI: Specific format for integrations via EDI (Electronic Data Interchange). This manifest includes a column with the supplier''s name as provided through the EDI.<br>7. PYF Manifest: (Plants and Flowers format) Generates a specific format for the customer Interaxion. The system validates this configuration hierarchically. It first checks the option selected for the Consignee, and if it''s not set, it looks for the setting at the Bill-To level.<br>"}}'
			);

			FETCH NEXT FROM empresa_cursor INTO @idEmpresa;
		END
    CLOSE empresa_cursor;
    DEALLOCATE empresa_cursor;
END

BEGIN

	DECLARE @Codigo VARCHAR(64),
			@Descripcion VARCHAR(128),
			@Tipo VARCHAR(32),
			@Actor VARCHAR(16),
			@Nota VARCHAR(256),
			@FechaCambio DATETIME,
			@Status VARCHAR(32),
			@Enumerador VARCHAR(64),
			@DetailDescription VARCHAR(8000),
			@empresaId VARCHAR(16),
			@idNew VARCHAR(16);

	SELECT	@Codigo = 'ShiptoDetailLabelType',
			@Descripcion = 'Permite imprimir una etiqueta adicional para el cliente final',
			@Tipo = 'CODIGOBARRA',
			@Actor = 'BILLTO',
			@Nota = 'This parameter allows you to define whether an additional label should be printed for the Ship-to and which Bill-to � Consignee relationships it applies to.
					 The configuration is done by selecting the label type and the corresponding relationships.
					 Configuring all label types is not mandatory.',
			@FechaCambio = GETDATE(),
			@Status = 'ACTIVO',
			@Enumerador = 'ShiptoDetailLabelType',
			@DetailDescription = '{"description":{"es-US":"Permite imprimir una etiqueta adicional para el cliente final.","en-US":"Allows printing an additional label for the Ship-to."},"detail":{"es-US":"Este par�metro permite imprimir una etiqueta adicional para el Cliente Final (Ship-to) y a qu� relaciones Bill-to � Consignee aplica.<br>La configuraci�n se realiza seleccionando el tipo de etiqueta y las relaciones correspondientes.<br>No es obligatorio parametrizar todas las etiquetas.","en-US":"This parameter allows you to define whether an additional label should be printed for the Ship-to and which Bill-to � Consignee relationships it applies to.<br>The configuration is done by selecting the label type and the corresponding relationships.<br>Configuring all label types is not mandatory."}}'


	DECLARE EMP_CURSOR CURSOR FOR
	SELECT E.Id
	FROM dbo.Empresas E
	WHERE [status] = 'ACTIVO'

	OPEN EMP_CURSOR
	FETCH NEXT FROM EMP_CURSOR INTO @empresaId

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF NOT EXISTS (
			SELECT 1
			FROM dbo.ParametrosLista PL
			WHERE PL.Codigo = @Codigo
			AND PL.IdEmpresa = @empresaId
		)
		BEGIN
			EXEC dbo.PRO_General_GenerarIdUnico 
				'ParametrosLista',
				@IdUnico = @idNew OUTPUT

			INSERT INTO dbo.ParametrosLista
			(
				Id,
				Codigo,
				Descripcion,
				Tipo,
				Actor,
				Nota,
				FechaCambio,
				[Status],
				IdEmpresa,
				TipoActor,
				Enumerador,
				DetailDescription
			)
			VALUES
			(
				@idNew,
				@Codigo,
				@Descripcion,
				@Tipo,
				@Actor,
				@Nota,
				@FechaCambio,
				@Status,
				@empresaId,
				NULL,
				@Enumerador,
				@DetailDescription
			)
		END

		FETCH NEXT FROM EMP_CURSOR INTO @empresaId
	END

	CLOSE EMP_CURSOR
	DEALLOCATE EMP_CURSOR

END

BEGIN

	DECLARE @CodigoSL VARCHAR(64),
			@DescripcionSL VARCHAR(128),
			@TipoSL VARCHAR(32),
			@ActorSL VARCHAR(16),
			@NotaSL VARCHAR(256),
			@FechaCambioSL DATETIME,
			@StatusSL VARCHAR(32),
			@EnumeradorSL VARCHAR(64),
			@DetailDescriptionSL VARCHAR(8000),
			@empresaIdSL VARCHAR(16),
			@idNewSL VARCHAR(16);

	SELECT	@CodigoSL = 'TarifaServicioLocal',
			@DescripcionSL = 'Permite definir el conjunto de servicios locales que serán ejecutados automáticamente sobre la carga durante su proceso operativo en bodega',
			@TipoSL = 'FACTURACION',
			@ActorSL = 'BILLTO',
			@NotaSL = 'Allows defining the set of local services that will be automatically executed on the cargo during its warehouse operational process. 
			The selected values correspond to the Local Services catalog and determine which operational processes, calculations, or services must be generated for the received pieces associated with the operation.',
			@FechaCambioSL = GETDATE(),
			@StatusSL = 'ACTIVO',
			@EnumeradorSL = 'TarifaServicioLocal',
			@DetailDescriptionSL = '{"description":{"es-US":"Servicios Locales","en-US":"Local Services"},"detail":{"es-US":"Permite definir el conjunto de servicios locales que serán ejecutados automáticamente sobre la carga durante su proceso operativo en bodega.<br>Los valores seleccionados corresponden al catálogo de Servicios Locales y determinan qué procesos, cálulos o servicios deberán generarse para las piezas recibidas asociadas a la operación.<br>","en-US":"Allows defining the set of local services that will be automatically executed on the cargo during its warehouse operational process.<br>The selected values correspond to the Local Services catalog and determine which operational processes, calculations, or services must be generated for the received pieces associated with the operation.<br>"}}'


	DECLARE EMP_CURSOR CURSOR FOR
	SELECT E.Id
	FROM dbo.Empresas E
	WHERE [status] = 'ACTIVO'

	OPEN EMP_CURSOR
	FETCH NEXT FROM EMP_CURSOR INTO @empresaIdSL

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF NOT EXISTS (
			SELECT 1
			FROM dbo.ParametrosLista PL
			WHERE PL.Codigo = @CodigoSL
			AND PL.IdEmpresa = @empresaIdSL
		)
		BEGIN
			EXEC dbo.PRO_General_GenerarIdUnico 
				'ParametrosLista',
				@IdUnico = @idNewSL OUTPUT

			INSERT INTO dbo.ParametrosLista
			(
				Id,
				Codigo,
				Descripcion,
				Tipo,
				Actor,
				Nota,
				FechaCambio,
				[Status],
				IdEmpresa,
				TipoActor,
				Enumerador,
				DetailDescription
			)
			VALUES
			(
				@idNewSL,
				@CodigoSL,
				@DescripcionSL,
				@TipoSL,
				@ActorSL,
				@NotaSL,
				@FechaCambioSL,
				@StatusSL,
				@empresaIdSL,
				NULL,
				@EnumeradorSL,
				@DetailDescriptionSL
			)
		END

		FETCH NEXT FROM EMP_CURSOR INTO @empresaIdSL
	END

	CLOSE EMP_CURSOR
	DEALLOCATE EMP_CURSOR

END
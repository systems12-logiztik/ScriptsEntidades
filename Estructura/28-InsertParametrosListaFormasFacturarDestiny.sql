/*
VERSION		MODIFIEDBY			MODIFIEDDATE	HU					MODIFICATION
1			Jesús Yandún		2026-06-05		LAG-WM4-000 53098	Initial Code - Add new ParametersList for all FormasFacturarDestiny
*/

BEGIN

	DECLARE @CodigoFD VARCHAR(64),
			@DescripcionFD VARCHAR(128),
			@TipoFD VARCHAR(32),
			@ActorFD VARCHAR(16),
			@NotaFD VARCHAR(256),
			@FechaCambioFD DATETIME,
			@StatusFD VARCHAR(32),
			@EnumeradorFD VARCHAR(64),
			@DetailDescriptionFD VARCHAR(8000),
			@empresaIdFD VARCHAR(16),
			@idNewFD VARCHAR(16);

	SELECT	@CodigoFD = 'FormasFacturarDestiny',
			@DescripcionFD = 'Seleccionar la forma de facturar para Destiny para el archivo CSV',
			@TipoFD = 'FACTURACION',
			@ActorFD = 'BILLTO',
			@NotaFD = 'This parameter allows you to define what type of billing document you need to group.',
			@FechaCambioFD = GETDATE(),
			@StatusFD = 'ACTIVO',
			@EnumeradorFD = 'FormasFacturarDestiny',
			@DetailDescriptionFD = '{"description":{"es-US":"Seleccione la forma de facturar para Destiny para el archivo CSV","en-US":"Select the billing method for Destiny for the CSV file"},"detail":{"es-US":"Este parámetro permite configurar el tipo de agrupamiento para destiny en el archivo csv. La información se visualiza por cliente. Las opciones disponibles son:<br>AGRUPAR_1_FACTURA_FLETE_DUTIES: Debe generarse un archivo por código contable cliente, que va a incluir un numero de factura y varios clientes de distribucion.<br>AGRUPAR_1_FACTURA_FLETE_1_FACTURA_DUTIES: Debe generarse un archivo por código contable cliente, que va a incluir dos numeros de factura y varios clientes de distribucion.<br>GUIA_AGRUPAR_1_FACTURA_FLETE_DUTIES: Debe generarse un archivo por cada guía de distribución, que va a incluir un numero de factura y un cliente de distribución.<br>GUIA_1_FACTURA_FLETE_1_FACTURA_DUTIES: Debe generarse un archivo por cada guía de distribución, que va a incluir dos números de factura y un cliente de distribucion.<br>","en-US":"This parameter allows you to configure the grouping type for Destiny in the CSV file. The information is displayed per customer. The available options are:<br>AGRUPAR_1_FACTURA_FLETE_DUTIES: One file should be generated per customer accounting code, which will include one invoice number and several distribution customers.<br>AGRUPAR_1_FACTURA_FLETE_1_FACTURA_DUTIES: One file should be generated per customer accounting code, which will include two invoice numbers and several distribution customers.<br>GUIA_AGRUPAR_1_FACTURA_FLETE_DUTIES: One file should be generated for each distribution guide, which will include one invoice number and one distribution customer.<br>GUIA_1_FACTURA_FLETE_1_FACTURA_DUTIES: One file should be generated for each distribution guide, which will include two invoice numbers and one distribution customer.<br>"}}'

	DECLARE EMP_CURSOR CURSOR FOR
	SELECT E.Id
	FROM dbo.Empresas E
	WHERE [status] = 'ACTIVO'

	OPEN EMP_CURSOR
	FETCH NEXT FROM EMP_CURSOR INTO @empresaIdFD

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS (
			SELECT 1
			FROM dbo.ParametrosLista PL
			WHERE PL.Codigo = @CodigoFD
			AND PL.IdEmpresa = @empresaIdFD
			AND PL.actor = 'BILLTO'
		)
		BEGIN
			PRINT 'EMP ' + @empresaIdFD
			EXEC dbo.PRO_General_GenerarIdUnico 
				'ParametrosLista',
				@IdUnico = @idNewFD OUTPUT

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
				@idNewFD,
				@CodigoFD,
				@DescripcionFD,
				@TipoFD,
				@ActorFD,
				@NotaFD,
				@FechaCambioFD,
				@StatusFD,
				@empresaIdFD,
				NULL,
				@EnumeradorFD,
				@DetailDescriptionFD
			)
		END

		FETCH NEXT FROM EMP_CURSOR INTO @empresaIdFD
	END

	CLOSE EMP_CURSOR
	DEALLOCATE EMP_CURSOR

END
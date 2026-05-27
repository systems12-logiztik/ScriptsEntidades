/*
VERSION     MODIFIEDBY          MODIFIEDDATE    HU            MODIFICATION
1           Luis Campos         2026-05-21      64765         Insert ParametrosCatalogos from Parametros Final.xlsx for Bill-to Consignee relation
*/

DECLARE @TotalRecords INT = 0,
	@InsertedRows INT = 0,
	@GeneratedIds INT = 0,
	@ErrorCount INT = 0,
	@ErrorMessage VARCHAR(2000);

IF OBJECT_ID('tempdb..#TMP_ParametrosPendientes') IS NOT NULL
	DROP TABLE #TMP_ParametrosPendientes

IF OBJECT_ID('tempdb..#TMP_ParametrosPendientesNro') IS NOT NULL
	DROP TABLE #TMP_ParametrosPendientesNro

IF OBJECT_ID('tempdb..#TMP_ParametrosV1Checks') IS NOT NULL
	DROP TABLE #TMP_ParametrosV1Checks

IF OBJECT_ID('tempdb..#TMP_ParametrosOrigen') IS NOT NULL
	DROP TABLE #TMP_ParametrosOrigen

IF OBJECT_ID('tempdb..#TMP_ParametrosPendientesEmpresaNro') IS NOT NULL
	DROP TABLE #TMP_ParametrosPendientesEmpresaNro

IF OBJECT_ID('tempdb..#TMP_ParametrosCatalogosInsert') IS NOT NULL
	DROP TABLE #TMP_ParametrosCatalogosInsert

CREATE TABLE #TMP_ParametrosV1Checks (
	ParametroV1 VARCHAR(256),
	AplicaBillTo BIT,
	AplicaBillToConsignee BIT,
	AplicaConsignee BIT
);

INSERT INTO #TMP_ParametrosV1Checks (
	ParametroV1,
	AplicaBillTo,
	AplicaBillToConsignee,
	AplicaConsignee
)
VALUES
	('Definir el tipo de servicio que brinda al cliente', 1, 1, 0)
	,('Codigo de barra puede repetirse?', 1, 1, 0)
	,('Cargar cliente final y programacion del xml o sw de cliente?', 1, 1, 0)
	,('Secuencial Propio Codigo de Barra', 1, 1, 0)
	,('Validar que el Truck ID no se duplique?', 1, 1, 0)
	,('Nombre del exportador para los manifiestos de despacho en destino', 1, 1, 0)
	,('Tipo de manifiesto de despacho', 1, 1, 0)
	,('Seleccionar agrupacion de facturacion de servicios locales', 1, 1, 0)
	,('Generar el reporte duty al cliente?', 1, 1, 0)
	,('Seleccionar la forma de facturar para Destiny para el archivo CSV', 1, 1, 0)
	,('Tipo de etiqueta detalle cliente final', 0, 0, 1)
	,('Gestion de grupos de fincas en PO', 1, 0, 0)
	,('Valida que cliente puede modificar la House', 1, 0, 0)
	,('Enviar Documentos Adjuntos', 1, 0, 0)
	,('Guarda las dimensiones de los codigos de barra al insertar XML', 1, 0, 0)
	,('Guardar Pesos Agencia Neto y Volumen Mayor?', 1, 1, 0)
	,('Cliente usa una etiqueta detalle de sus clientes finales', 0, 0, 1)
	,('Valor maximo del contador de codigo de barra de etiquetas', 1, 0, 0);

SELECT DISTINCT
PL.Id AS IdParametroLista,
PL.IdEmpresa,
PC.Valor,
PC.Notas,
ER.EntityTypeId,
ER.Id AS EntityRelationId,
ER.ChildEntityTypeId,
PVC.AplicaBillTo,
PVC.AplicaBillToConsignee,
PVC.AplicaConsignee
INTO #TMP_ParametrosOrigen
FROM dbo.ParametrosLista PL WITH (NOLOCK)
INNER JOIN dbo.ParametrosCatalogos PC WITH (NOLOCK) ON PL.Id = PC.IdParametroLista AND PC.[status] = 'ACTIVO'
INNER JOIN #TMP_ParametrosV1Checks PVC ON PL.descripcion COLLATE Latin1_General_CI_AI = PVC.ParametroV1 COLLATE Latin1_General_CI_AI
INNER JOIN dbo.EntityRelations ER WITH (NOLOCK) ON ER.ReferenceId = PC.IdEntidad;

SELECT DISTINCT
POR.IdParametroLista,
POR.IdEmpresa,
POR.Valor,
POR.Notas,
POR.EntityTypeId AS TargetIdEntidad
INTO #TMP_ParametrosPendientes
FROM #TMP_ParametrosOrigen POR
WHERE POR.AplicaBillTo = 1

UNION

SELECT DISTINCT
POR.IdParametroLista,
POR.IdEmpresa,
POR.Valor,
POR.Notas,
POR.EntityRelationId AS TargetIdEntidad
FROM #TMP_ParametrosOrigen POR
WHERE POR.AplicaBillToConsignee = 1

UNION

SELECT DISTINCT
POR.IdParametroLista,
POR.IdEmpresa,
POR.Valor,
POR.Notas,
POR.ChildEntityTypeId AS TargetIdEntidad
FROM #TMP_ParametrosOrigen POR
WHERE POR.AplicaConsignee = 1;

DELETE PP
FROM #TMP_ParametrosPendientes PP
INNER JOIN dbo.ParametrosCatalogos PC WITH (NOLOCK) ON PC.IdParametroLista = PP.IdParametroLista
AND PC.IdEntidad = PP.TargetIdEntidad;

SELECT ROW_NUMBER() OVER (
ORDER BY TargetIdEntidad, IdParametroLista
) AS Nro,
TargetIdEntidad,
IdParametroLista,
IdEmpresa,
Valor,
Notas
INTO #TMP_ParametrosPendientesNro
FROM #TMP_ParametrosPendientes;

SELECT
PPN.Nro,
PPN.IdEmpresa,
ROW_NUMBER() OVER (
	PARTITION BY PPN.IdEmpresa
	ORDER BY PPN.Nro
) AS NroEmpresa,
PPN.TargetIdEntidad,
PPN.IdParametroLista,
PPN.Valor,
PPN.Notas
INTO #TMP_ParametrosPendientesEmpresaNro
FROM #TMP_ParametrosPendientesNro PPN
WHERE PPN.IdEmpresa IS NOT NULL;

SELECT @TotalRecords = COUNT(1)
FROM #TMP_ParametrosPendientesEmpresaNro;

INSERT INTO administracion_db..DBA_LogDepuracion
SELECT GETDATE(),
'ParametrosCatalogos',
'INICIO INSERT PARAMETROS CATALOGOS',
@TotalRecords,
GETDATE();

DECLARE @TMP_AllIds TABLE (
	IdEmpresa VARCHAR(16),
	NroEmpresa INT,
	Unificado VARCHAR(16)
);

DECLARE @TMP_TempIds TABLE (
	Id INT,
	Unificado VARCHAR(16)
);

DECLARE @Companies TABLE (
	Seq INT IDENTITY(1, 1),
	IdEmpresa VARCHAR(16)
);

DECLARE @CompanyId VARCHAR(16),
	@CompanyCount INT = 0,
	@CompanyRow INT = 1,
	@CompanyRows INT = 0;

INSERT INTO @Companies (
	IdEmpresa
)
SELECT
	PPN.IdEmpresa
FROM #TMP_ParametrosPendientesEmpresaNro PPN
GROUP BY PPN.IdEmpresa;

SELECT @CompanyRows = COUNT(1)
FROM @Companies;

BEGIN TRY
	IF @TotalRecords > 0
	BEGIN
		WHILE @CompanyRow <= @CompanyRows
		BEGIN
			SELECT @CompanyId = C.IdEmpresa
			FROM @Companies C
			WHERE C.Seq = @CompanyRow;

			SELECT @CompanyCount = COUNT(1)
			FROM #TMP_ParametrosPendientesEmpresaNro PPN
			WHERE PPN.IdEmpresa = @CompanyId;

			IF @CompanyCount > 0
			BEGIN
				DELETE FROM @TMP_TempIds;

				INSERT INTO @TMP_TempIds
				EXEC dbo.pro_GeneralGenerarIdUnicoMasivo
					@tabla = 'ParametrosCatalogos',
					@cantidad = @CompanyCount,
					@idEmpresa = @CompanyId;

				INSERT INTO @TMP_AllIds (
					IdEmpresa,
					NroEmpresa,
					Unificado
				)
				SELECT
					@CompanyId,
					T.Id,
					T.Unificado
				FROM @TMP_TempIds T;
			END
			
			SELECT @CompanyRow = @CompanyRow + 1;
		END

		SELECT @GeneratedIds = COUNT(1)
		FROM @TMP_AllIds;

		IF @GeneratedIds <> @TotalRecords
		BEGIN
			RAISERROR('Cantidad de IDs generados no coincide con total de registros.', 16, 1);
		END

		SELECT
			AI.Unificado AS Id,
			PPN.TargetIdEntidad AS IdEntidad,
			PPN.IdParametroLista,
			PPN.Valor,
			PPN.Notas,
			GETDATE() AS FechaCambio,
			'ACTIVO' AS [Status],
			'yUJoJlBG' AS IdUsuarioLog
		INTO #TMP_ParametrosCatalogosInsert
		FROM #TMP_ParametrosPendientesEmpresaNro PPN
		INNER JOIN @TMP_AllIds AI ON AI.IdEmpresa = PPN.IdEmpresa
			AND AI.NroEmpresa = PPN.NroEmpresa;

		IF (SELECT COUNT(1) FROM #TMP_ParametrosCatalogosInsert) <> @TotalRecords
		BEGIN
			RAISERROR('El mapeo entre pendientes e IDs masivos no coincide en cantidad.', 16, 1);
		END

		IF EXISTS (
			SELECT 1
			FROM #TMP_ParametrosCatalogosInsert I
			WHERE I.Id IS NULL
				OR LTRIM(RTRIM(I.Id)) = ''
		)
		BEGIN
			RAISERROR('Se detectaron IDs nulos o vacios en el dataset a insertar.', 16, 1);
		END

		IF EXISTS (
			SELECT I.Id
			FROM #TMP_ParametrosCatalogosInsert I
			GROUP BY I.Id
			HAVING COUNT(1) > 1
		)
		BEGIN
			RAISERROR('Se detectaron IDs duplicados en el dataset a insertar.', 16, 1);
		END

		IF EXISTS (
			SELECT 1
			FROM #TMP_ParametrosCatalogosInsert I
			WHERE LEN(I.Id) > 16
				OR LEN(I.IdEntidad) > 16
				OR LEN(I.IdParametroLista) > 32
				OR LEN(I.Notas) > 256
				OR LEN(I.Valor) > 1024
		)
		BEGIN
			RAISERROR('Hay valores que exceden el tamano permitido de columnas en ParametrosCatalogos.', 16, 1);
		END

		IF EXISTS (
			SELECT 1
			FROM #TMP_ParametrosCatalogosInsert I
			INNER JOIN dbo.ParametrosCatalogos PC ON PC.Id = I.Id
		)
		BEGIN
			RAISERROR('Se detectaron colisiones de Id con registros existentes en ParametrosCatalogos.', 16, 1);
		END
/*
		INSERT INTO dbo.ParametrosCatalogos (
			Id,
			IdEntidad,
			IdParametroLista,
			Valor,
			Notas,
			fechaCambio,
			[status],
			[idUsuarioLog]
		)
		*/
		SELECT
			I.Id,
			I.IdEntidad,
			I.IdParametroLista,
			I.Valor,
			I.Notas,
			I.FechaCambio,
			I.[Status],
			I.IdUsuarioLog
		FROM #TMP_ParametrosCatalogosInsert I;
		
		SELECT @InsertedRows = @@ROWCOUNT
	END

	INSERT INTO administracion_db..DBA_LogDepuracion
	SELECT GETDATE(),
	'ParametrosCatalogos',
	'INSERT FINALIZADO',
	@InsertedRows,
	GETDATE();
END TRY

BEGIN CATCH
	SELECT @ErrorCount = @ErrorCount + 1
	SELECT @ErrorMessage = 'Linea ' + CAST(ERROR_LINE() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE()

	INSERT INTO administracion_db..DBA_LogDepuracion
	SELECT GETDATE(),
	'ParametrosCatalogos',
	'ERROR: ' + ISNULL(@ErrorMessage, 'SIN MENSAJE'),
	0,
	GETDATE();
END CATCH

IF @ErrorCount = 0
	PRINT 'Estado: COMPLETADO EXITOSAMENTE'
ELSE
	PRINT 'Estado: COMPLETADO CON ERRORES'

IF OBJECT_ID('tempdb..#TMP_ParametrosPendientes') IS NOT NULL
	DROP TABLE #TMP_ParametrosPendientes

IF OBJECT_ID('tempdb..#TMP_ParametrosPendientesNro') IS NOT NULL
	DROP TABLE #TMP_ParametrosPendientesNro

IF OBJECT_ID('tempdb..#TMP_ParametrosV1Checks') IS NOT NULL
	DROP TABLE #TMP_ParametrosV1Checks

IF OBJECT_ID('tempdb..#TMP_ParametrosOrigen') IS NOT NULL
	DROP TABLE #TMP_ParametrosOrigen

IF OBJECT_ID('tempdb..#TMP_ParametrosPendientesEmpresaNro') IS NOT NULL
	DROP TABLE #TMP_ParametrosPendientesEmpresaNro

IF OBJECT_ID('tempdb..#TMP_ParametrosCatalogosInsert') IS NOT NULL
	DROP TABLE #TMP_ParametrosCatalogosInsert
GO

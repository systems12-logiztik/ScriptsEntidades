
/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Jorge Ortiz		2025-11-10		CT 55390	Initial Code - New SP to generate unique integer IDs
2			Jorge Ortiz		2025-11-13		CT 55390	Modified to generate bulk IDs and return table
*/
CREATE OR ALTER PROCEDURE [dbo].[AC_pro_General_GenerateBulkInt]
(
    @table VARCHAR(32),
	@idEmpresa VARCHAR(32),
	@cantidad INT = 1
)
AS
BEGIN
	BEGIN TRY
		DECLARE @contadorInicial INT,
				@codigoSucursal INT,
				@rangoBase INT = 1000000,
				@i INT = 1;

		DECLARE @TablaOutput TABLE
		(	
			id INT IDENTITY(1, 1),
			unificado INT
		);

		UPDATE dbo.Contadores 
		SET contador = contador + @cantidad,
			@contadorInicial = contador + 1
		WHERE tabla = @table;
    
		SELECT TOP 1 @codigoSucursal = CAST(valor AS INT) - 1 
		FROM ParametrosGenerales 
		WHERE codigo = 'idUnico'
		AND idEmpresa = @idEmpresa;

		WHILE @i <= @cantidad
		BEGIN
			INSERT INTO @TablaOutput (unificado)
			VALUES ((@codigoSucursal * @rangoBase) + @contadorInicial + @i - 1);
			
			SET @i = @i + 1;
		END;

		SELECT 
			id,
			unificado 
		FROM @TablaOutput	
		ORDER BY id ASC;

	END TRY
	BEGIN CATCH
		EXEC [dbo].[pro_LogError];
	END CATCH
END;
/*
-- Ejemplo de uso: Generar 5 IDs
EXEC AC_pro_General_GenerateBulkInt 
    @table = 'ExcludedContacts',
    @idEmpresa = 'EMP011',
    @cantidad = 5;

-- Ejemplo de uso: Guardar los IDs en una variable de tabla
DECLARE @NuevosIDs TABLE (id INT, unificado INT);

INSERT INTO @NuevosIDs (id, unificado)
EXEC AC_pro_General_GenerateBulkInt 
    @table = 'ExcludedContacts',
    @idEmpresa = 'EMP011',
    @cantidad = 10;

SELECT * FROM @NuevosIDs;
*/
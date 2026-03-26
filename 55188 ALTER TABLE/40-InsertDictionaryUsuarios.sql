/*    
VERSION		MODIFIEDBY		MODIFIEDDATE	HU				MODIFICATION
1			Jorge Ortiz		2025-04-10		CT 46760		Initial Code - Add addextendedproperty for DetailDescription
*/
DECLARE @tabla VARCHAR(32) = 'ParametrosLista',
		@columnDetailDescription VARCHAR(32) = 'DetailDescription',
		@name VARCHAR(32) = 'MS_Description';

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME = @tabla
	AND COLUMN_NAME = @columnDetailDescription
)
BEGIN
	IF NOT EXISTS (
		SELECT 1 
		FROM sys.extended_properties ep
		INNER JOIN sys.tables t ON ep.major_id = t.object_id
		INNER JOIN sys.columns c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
		INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
		WHERE s.name = 'dbo'
		AND t.name = @tabla
		AND c.name = @columnDetailDescription
		AND ep.name = @name
	)
	BEGIN
		-- Agregar extended property si no existe
		EXEC sp_addextendedproperty 
			@name = @name, 
			@value = 'Json with descriptions in different languages. Ex: {"description":{"es-US":"Texto espaniol","en-US":"texto ingles"},"detail":{"es-US":"texto espaniol","en-US":"texto ingles"}}', 
			@level0type = N'SCHEMA', @level0name = 'dbo', 
			@level1type = N'TABLE',  @level1name = @tabla, 
			@level2type = N'COLUMN', @level2name = @columnDetailDescription;
		PRINT 'DICTIONARY INSERTED INTO COLUMN '+ @columnDetailDescription;
	END
	ELSE	
	BEGIN
		PRINT 'EXTENDED PROPERTY ALREADY EXISTS FOR COLUMN '+ @columnDetailDescription + ' - NO ACTION TAKEN';
	END
END
ELSE
BEGIN
	PRINT 'TABLE ' + @tabla + ' OR COLUMN ' + @columnDetailDescription + ' DOES NOT EXIST - NO ACTION TAKEN';
END
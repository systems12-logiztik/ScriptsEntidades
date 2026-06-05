/*    
VERSION		MODIFIEDBY					MODIFIEDDATE	HU				MODIFICATION
1			Cristhian Cuichan			2025-03-26		67468			Initial Code - Add addextendedproperty for EntityType field in Usuarios table
*/
DECLARE @tabla VARCHAR(32) = 'Usuarios',
		@columnEntityType VARCHAR(32) = 'EntityType',
		@name VARCHAR(32) = 'MS_Description';

IF EXISTS (
	SELECT 1
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME = @tabla
	AND COLUMN_NAME = @columnEntityType
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
		AND c.name = @columnEntityType
		AND ep.name = @name
	)
	BEGIN
		-- Agregar extended property si no existe
		EXEC sp_addextendedproperty 
			@name = @name, 
			@value = '1:BillTo,2:Consignee', 
			@level0type = N'SCHEMA', @level0name = 'dbo', 
			@level1type = N'TABLE',  @level1name = @tabla, 
			@level2type = N'COLUMN', @level2name = @columnEntityType;
		PRINT 'DICTIONARY INSERTED INTO COLUMN '+ @columnEntityType;
	END
	ELSE	
	BEGIN
		PRINT 'EXTENDED PROPERTY ALREADY EXISTS FOR COLUMN '+ @columnEntityType + ' - NO ACTION TAKEN';
	END
END
ELSE
BEGIN
	PRINT 'TABLE ' + @tabla + ' OR COLUMN ' + @columnEntityType + ' DOES NOT EXIST - NO ACTION TAKEN';
END


/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			    MODIFICATION
1			Jorge Ortiz		2025-10-21		55188			Initial Code - 'CODIGO CONTABLE BILLTO' in 'TipoCodigo'
*/
IF NOT EXISTS (
    SELECT TOP 1 1 
    FROM [dbo].[TipoCodigo]
    WHERE [codigo] = 'CODIGO_CONTABLE_BILLTO'
)
BEGIN
    INSERT INTO [dbo].[TipoCodigo]
        (
            [id], 
            [nombre], 
            [codigo]
        )
    VALUES
        (
            'TCOD004',
            'CODIGO CONTABLE BILLTO', 
            'CODIGO_CONTABLE_BILLTO'
        );
    
    PRINT 'RECORD INSERTED IN TIPOCODIGO TABLE - CODIGO CONTABLE BILLTO';
END
ELSE
BEGIN
    PRINT 'RECORD ALREADY EXISTS IN TIPOCODIGO TABLE - CODIGO CONTABLE BILLTO';
END;

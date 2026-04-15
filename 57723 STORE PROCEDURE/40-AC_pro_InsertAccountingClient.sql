/*
VERSION  MODIFIEDBY        MODIFIEDDATE  HU         MODIFICATION
1        Jordan Chango     2026-03-30    63671      Initial Code - SP for inserting accounting clients (serviceType = 3)
*/
CREATE OR ALTER PROCEDURE [dbo].[AC_pro_InsertAccountingClient] 
	@AccountingClientId	VARCHAR(16),
	@ClientName	VARCHAR(100)
AS
BEGIN
	
    IF NULLIF(LTRIM(RTRIM(@AccountingClientId)), '') IS NULL
    BEGIN
        RAISERROR('The field AccountingClientId is required and cannot be empty.', 16, 1)
        RETURN
    END

    IF NULLIF(LTRIM(RTRIM(@ClientName)), '') IS NULL
    BEGIN
        RAISERROR('The field ClientName is required and cannot be empty.', 16, 1)
        RETURN
    END


	IF NOT EXISTS (
			SELECT 1
			FROM dbo.ClientesContables WITH (NOLOCK)
			WHERE IdClienteContable = @AccountingClientId AND TipoServicio = 3
			)
	BEGIN
		INSERT INTO [dbo].[ClientesContables] (
			Id,
			IdClienteContable,
			NombreCliente,
			IdEmpresa,
			[Status],
			Nota,
			FechaCambio,
			TipoServicio,
			IdUsuarioLog
			)
		VALUES (
			NEWID(),
			@AccountingClientId,
			@ClientName,
			'EMP015', -- AMS
			'A',
			NULL,
			GETDATE(),
			3, -- tipoServicio AMS
			'USUCONSOLEAMS'
			)
	END
	ELSE
	BEGIN
		RAISERROR('The accounting client with AccountingClientId ''%s'' already exists for serviceType 3.', 16, 1, @AccountingClientId)
	END
END

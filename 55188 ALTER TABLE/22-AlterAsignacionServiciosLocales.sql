/*
VERSION		AUTOR			FECHA			HU				CAMBIO
1			Jean Martillo	16-02-2026		ACWMS 57736  	Agregar campo BillToConsigneeId y ConsigneeId en la tabla AsignacionServiciosLocales
*/
 
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('AsignacionServiciosLocales') AND name = 'ConsigneeId')
BEGIN
    ALTER TABLE AsignacionServiciosLocales ADD ConsigneeId VARCHAR(16) NULL,
									BillToConsigneeId VARCHAR(16) NULL;
    PRINT 'Columna ConsigneeId y BillToConsigneeId agregada a AsignacionServiciosLocales';
END
ELSE
BEGIN
    PRINT 'Columna ConsigneeId y BillToConsigneeId ya existe en AsignacionServiciosLocales';
END


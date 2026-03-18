/*    
VERSION		MODIFIEDBY			MODIFIEDDATE	HU		MODIFICATION
1		    Jean Martillo		2025-12-08	    57736	Initial Code - Add BillToConsigneeId and ConsigneeId columns to AsignacionServiciosLocales
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


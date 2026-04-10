/*
VERSION		MODIFIEDBY		MODIFIEDDATE	HU			MODIFICATION
1			Luis Campos		2025-10-31		AC 55188	Initial Code
*/
CREATE OR ALTER TRIGGER trg_UpdateEntityTypes
ON dbo.EntityTypes
AFTER UPDATE 
NOT FOR REPLICATION
AS
BEGIN
    -- Si es una actualización masiva (más de un registro), salir del trigger
    IF EXISTS (SELECT 1 FROM inserted HAVING COUNT(*) > 1)
    BEGIN
        RETURN;
    END
    
    -- Ejecutar solo si el Status es 0 o 1 y EntityType = 2 (Consignee)
    -- Y solo si la columna Metadata o Status fue actualizada
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON i.Id = d.Id
        WHERE i.EntityType = 2
        AND i.[Status] IN (0,1)
        AND 
        (
            i.Metadata <> d.Metadata
            OR i.[Status] <> d.[Status]
        )
    )
    BEGIN
        -- Lógica deshabilitada: ReferenceId fue removido de EntityTypes
        -- Ahora ReferenceId se encuentra en EntityRelations
        RETURN;
    END
END
GO

/*
VERSION     MODIFIEDBY      MODIFIEDDATE    HU      MODIFICATION
1           Luis Campos     2026-02-27      55188   Optimized indexes for fast LIKE search on EntityTypes, EntityRelations, Entities with filtered WHERE Status=1
*/

-- Drop indexes no utilizados
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityTypes_Status_EntityType' AND object_id = OBJECT_ID('EntityTypes'))
    DROP INDEX idx_EntityTypes_Status_EntityType ON EntityTypes;
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityRelations_Status_Alias' AND object_id = OBJECT_ID('EntityRelations'))
    DROP INDEX idx_EntityRelations_Status_Alias ON EntityRelations;
GO

-- Create optimized indexes
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_Entities_Name')
BEGIN
    CREATE NONCLUSTERED INDEX idx_Entities_Name
    ON Entities(Name)
    INCLUDE (Id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityTypes_EntityId_Type_Status')
BEGIN
    CREATE NONCLUSTERED INDEX idx_EntityTypes_EntityId_Type_Status
    ON EntityTypes(EntityId, EntityType, Status)
    INCLUDE (Id)
    WHERE Status = 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityRelations_EntityTypeId_Status')
BEGIN
    CREATE NONCLUSTERED INDEX idx_EntityRelations_EntityTypeId_Status
    ON EntityRelations(EntityTypeId, Status)
    INCLUDE (Id)
    WHERE Status = 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityRelations_Id_Status')
BEGIN
    CREATE NONCLUSTERED INDEX idx_EntityRelations_Id_Status
    ON EntityRelations(Id, Status)
    INCLUDE (EntityTypeId, Alias)
    WHERE Status = 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityTypes_Id_Status')
BEGIN
    CREATE NONCLUSTERED INDEX idx_EntityTypes_Id_Status
    ON EntityTypes(Id, Status, EntityType)
    INCLUDE (EntityId)
    WHERE Status = 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityRelations_ReferenceId_Id')
BEGIN
    CREATE NONCLUSTERED INDEX idx_EntityRelations_ReferenceId_Id
    ON EntityRelations(ReferenceId)
    INCLUDE (Id, ChildEntityTypeId, [Status]);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_EntityTypes_ReferenceId_Id')
BEGIN
    CREATE NONCLUSTERED INDEX idx_EntityTypes_ReferenceId_Id
    ON EntityTypes(ReferenceId)
    INCLUDE (Id, [Status])
    WHERE [Status] = 1;
END
GO
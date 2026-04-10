/*
VERSION     MODIFIEDBY		MODIFIEDDATE    HU          MODIFICATION
1           Luis Campos		2025-09-16      55188       Create tables
*/
IF OBJECT_ID('dbo.Entities', 'U') IS NOT NULL
BEGIN
    PRINT 'Table Entities already exists';
END
ELSE
BEGIN
    CREATE TABLE dbo.Entities 
    (
        Id VARCHAR(16) NOT NULL,
        CountryId VARCHAR(16) NOT NULL,
        SubdivisionId VARCHAR(16),
        CityId VARCHAR(16) NOT NULL,
        [Name] VARCHAR(128) NOT NULL,
        Address1 VARCHAR(256) NOT NULL,
        Address2 VARCHAR(256),
        PostalCode VARCHAR(16) NOT NULL,        
        Latitude DECIMAL(18,8),
        Longitude DECIMAL(18,8),
        CreatedDate DATETIME NOT NULL,
        CreatedBy VARCHAR(16) NOT NULL,
        ModifiedDate DATETIME NOT NULL,
        ModifiedBy VARCHAR(16) NOT NULL,
        CONSTRAINT PK_Entities PRIMARY KEY NONCLUSTERED (Id)
    );

    CREATE CLUSTERED INDEX idx_Entities_CreatedDate
        ON dbo.Entities (CreatedDate);

    ALTER TABLE dbo.Entities
        ADD CONSTRAINT FK_Entities_Countries
        FOREIGN KEY (CountryId) REFERENCES dbo.Paises(Id) NOT FOR REPLICATION;

    ALTER TABLE dbo.Entities
        ADD CONSTRAINT FK_Entities_Subdivisions
        FOREIGN KEY (SubdivisionId) REFERENCES dbo.Estados(Id) NOT FOR REPLICATION;

    ALTER TABLE dbo.Entities
        ADD CONSTRAINT FK_Entities_Cities
        FOREIGN KEY (CityId) REFERENCES dbo.Ciudades(Id) NOT FOR REPLICATION;

    PRINT 'Table created: Entities';
END;

IF OBJECT_ID('dbo.EntityTypes', 'U') IS NOT NULL
BEGIN
    PRINT 'Table EntityTypes already exists';
END
ELSE
BEGIN
    CREATE TABLE dbo.EntityTypes 
    (
        Id VARCHAR(16) NOT NULL,
        EntityId VARCHAR(16) NOT NULL,
        [Status] INT NOT NULL,
        EntityType INT NOT NULL,
        Metadata VARCHAR(MAX) NULL,
        CreatedDate DATETIME NOT NULL,
        CreatedBy VARCHAR(16) NOT NULL,
        ModifiedDate DATETIME NOT NULL,
        ModifiedBy VARCHAR(16) NOT NULL,
        CONSTRAINT PK_EntityTypes PRIMARY KEY NONCLUSTERED (Id)
    );

    CREATE CLUSTERED INDEX idx_EntityTypes_CreatedDate
        ON dbo.EntityTypes (CreatedDate);

    ALTER TABLE dbo.EntityTypes WITH CHECK 
        ADD CONSTRAINT FK_EntityTypes_Entities
        FOREIGN KEY (EntityId) REFERENCES dbo.Entities (Id) NOT FOR REPLICATION;

    EXEC sys.sp_addextendedproperty 
        @name=N'values', 
        @value=N'1:BillTo,2:Consignee', 
        @level0type=N'SCHEMA',
        @level0name=N'dbo', 
        @level1type=N'TABLE',
        @level1name=N'EntityTypes', 
        @level2type=N'COLUMN',
        @level2name=N'EntityType';

    EXEC sys.sp_addextendedproperty 
        @name=N'values', 
        @value=N'0:Inactive,1:Active,2:Hidden,3:Incomplete', 
        @level0type=N'SCHEMA',
        @level0name=N'dbo', 
        @level1type=N'TABLE',
        @level1name=N'EntityTypes', 
        @level2type=N'COLUMN',
        @level2name=N'Status';

    PRINT 'Table created: EntityTypes';
END


IF OBJECT_ID('dbo.EntityRelations', 'U') IS NOT NULL
BEGIN
    PRINT 'Table EntityRelations already exists';
END
ELSE
BEGIN
    CREATE TABLE dbo.EntityRelations 
    (
        Id VARCHAR(16) NOT NULL,
        EntityTypeId VARCHAR(16) NOT NULL,
        ChildEntityTypeId VARCHAR(16) NOT NULL,
        ReferenceId VARCHAR(16),
        [Status] INT NOT NULL,
        SubType INT NOT NULL,
        Alias VARCHAR(512) NOT NULL,
        CreatedDate DATETIME NOT NULL,
        CreatedBy VARCHAR(16) NOT NULL,
        ModifiedDate DATETIME NOT NULL,
        ModifiedBy VARCHAR(16) NOT NULL,
        CONSTRAINT PK_EntityRelations PRIMARY KEY NONCLUSTERED (Id)
    );

    CREATE CLUSTERED INDEX idx_EntityRelations_CreatedDate
        ON dbo.EntityRelations (CreatedDate);

    ALTER TABLE dbo.EntityRelations WITH CHECK 
        ADD CONSTRAINT FK_EntityRelations_EntityTypes
        FOREIGN KEY (EntityTypeId) REFERENCES dbo.EntityTypes (Id) NOT FOR REPLICATION;

    ALTER TABLE dbo.EntityRelations WITH CHECK 
        ADD CONSTRAINT FK_EntityRelations_EntityTypes_Child
        FOREIGN KEY (ChildEntityTypeId) REFERENCES dbo.EntityTypes (Id) NOT FOR REPLICATION;

    EXEC sys.sp_addextendedproperty 
        @name=N'values', 
        @value=N'1:Own Consignee,2:Alias Consignee,3:Final Consignee', 
        @level0type=N'SCHEMA',
        @level0name=N'dbo', 
        @level1type=N'TABLE',
        @level1name=N'EntityRelations', 
        @level2type=N'COLUMN',
        @level2name=N'SubType';

    EXEC sys.sp_addextendedproperty 
        @name=N'values', 
        @value=N'0:Inactive, 1:Active,2:Hidden', 
        @level0type=N'SCHEMA',
        @level0name=N'dbo', 
        @level1type=N'TABLE',
        @level1name=N'EntityRelations', 
        @level2type=N'COLUMN',
        @level2name=N'Status';

    PRINT 'Table created: EntityRelations';
END


IF NOT EXISTS(
	SELECT 1 
	FROM INFORMATION_SCHEMA.TABLES 
	WHERE TABLE_SCHEMA = 'dbo' 
	AND TABLE_NAME = 'ExcludedContacts'
)
BEGIN
	CREATE TABLE [dbo].[ExcludedContacts] (
	    [Id] INT NOT NULL,
	    [ContactCompanyId] VARCHAR(16) NOT NULL,
	    [EntityRelationId] VARCHAR(16) NOT NULL,
	    [Status] INT NOT NULL,
	    [CreatedDate] DATETIME NOT NULL,
		[CreatedBy] VARCHAR(16) NOT NULL,
	    [ModifiedDate] DATETIME NOT NULL,
	    [ModifiedBy] VARCHAR(16) NOT NULL,
		CONSTRAINT [PK_ExcludedContacts] PRIMARY KEY ([Id]),
	    CONSTRAINT [FK_ExcludedContacts_ContactCompany] 
	        FOREIGN KEY ([ContactCompanyId]) 
	        REFERENCES [dbo].[ContactoEmpresas]([id])
	        NOT FOR REPLICATION,
	    CONSTRAINT [FK_ExcludedContacts_EntityRelations]
	        FOREIGN KEY ([EntityRelationId]) 
	        REFERENCES [dbo].[EntityRelations]([Id])
	        NOT FOR REPLICATION
	)
	
	PRINT 'Table ExcludedContacts created successfully.'
END
ELSE
BEGIN
	PRINT 'Table ExcludedContacts already exists.'
END

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'RolesActors'
)
BEGIN
    CREATE TABLE dbo.[RolesActors] (
        Id INT NOT NULL,
        AspNetRoleId NVARCHAR(128) NOT NULL,
        CatalogosId UNIQUEIDENTIFIER NOT NULL,
        [Status] INT NOT NULL,
        CreatedBy VARCHAR(16) NOT NULL,
        CreatedDate DATETIME NOT NULL,
        ModifiedBy VARCHAR(16) NOT NULL,
        ModifiedDate DATETIME NOT NULL,
        CONSTRAINT PK_RolesActors PRIMARY KEY (Id),
        CONSTRAINT FK_RolesActors_AspNetRoles FOREIGN KEY (AspNetRoleId) REFERENCES AspNetRoles(id) NOT FOR REPLICATION,
        CONSTRAINT FK_RolesActors_Catalogos FOREIGN KEY (CatalogosId) REFERENCES Catalogos(id) NOT FOR REPLICATION
    );

    PRINT 'Table RolesActors created successfully.'
END
ELSE
BEGIN
    PRINT 'Table RolesActors already exists.'
END
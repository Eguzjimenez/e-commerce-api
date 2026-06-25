IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TiposProducto')
BEGIN
    CREATE TABLE TiposProducto (
        IdTipo INT IDENTITY(1,1) PRIMARY KEY,
        NombreTipo VARCHAR(100) NOT NULL,
        Descripcion VARCHAR(255) NOT NULL CONSTRAINT DF_TiposProducto_Descripcion DEFAULT (''),
        Estado VARCHAR(20) NOT NULL CONSTRAINT DF_TiposProducto_Estado DEFAULT ('Activo')
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_TiposProducto_NombreTipo')
BEGIN
    CREATE UNIQUE INDEX UQ_TiposProducto_NombreTipo ON TiposProducto (NombreTipo);
END;

IF COL_LENGTH('Productos', 'IdTipo') IS NULL
BEGIN
    ALTER TABLE Productos ADD IdTipo INT NULL;
END;

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Productos_TiposProducto')
BEGIN
    ALTER TABLE Productos
        ADD CONSTRAINT FK_Productos_TiposProducto FOREIGN KEY (IdTipo) REFERENCES TiposProducto (IdTipo);
END;

IF COL_LENGTH('Productos', 'Caracteristicas') IS NULL
BEGIN
    ALTER TABLE Productos
        ADD Caracteristicas VARCHAR(500) NOT NULL
            CONSTRAINT DF_Productos_Caracteristicas DEFAULT ('');
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CategoriaTipo')
BEGIN
    CREATE TABLE CategoriaTipo (
        IdCategoria INT NOT NULL,
        IdTipo INT NOT NULL,
        CONSTRAINT PK_CategoriaTipo PRIMARY KEY (IdCategoria, IdTipo),
        CONSTRAINT FK_CategoriaTipo_Categorias FOREIGN KEY (IdCategoria) REFERENCES Categorias (IdCategoria),
        CONSTRAINT FK_CategoriaTipo_TiposProducto FOREIGN KEY (IdTipo) REFERENCES TiposProducto (IdTipo)
    );
END;

INSERT INTO TiposProducto (NombreTipo, Descripcion)
SELECT 'Interior', 'Productos pensados para espacios interiores.'
WHERE NOT EXISTS (SELECT 1 FROM TiposProducto WHERE NombreTipo = 'Interior');

INSERT INTO TiposProducto (NombreTipo, Descripcion)
SELECT 'Exterior', 'Productos pensados para espacios exteriores.'
WHERE NOT EXISTS (SELECT 1 FROM TiposProducto WHERE NombreTipo = 'Exterior');

INSERT INTO TiposProducto (NombreTipo, Descripcion)
SELECT 'Decorativo', 'Productos con fines decorativos.'
WHERE NOT EXISTS (SELECT 1 FROM TiposProducto WHERE NombreTipo = 'Decorativo');

INSERT INTO CategoriaTipo (IdCategoria, IdTipo)
SELECT c.IdCategoria, t.IdTipo
FROM Categorias c
CROSS JOIN TiposProducto t
WHERE NOT (
        c.NombreCategoria COLLATE Latin1_General_CI_AI LIKE '%planta%'
        AND t.NombreTipo = 'Decorativo'
    )
    AND NOT EXISTS (
        SELECT 1 FROM CategoriaTipo ct
        WHERE ct.IdCategoria = c.IdCategoria AND ct.IdTipo = t.IdTipo
    );

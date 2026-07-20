IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('Bitacora')
        AND name = 'IdUsuario'
        AND is_nullable = 0
)
BEGIN
    ALTER TABLE Bitacora ALTER COLUMN IdUsuario INT NULL;
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Permisos')
BEGIN
    CREATE TABLE Permisos (
        IdPermiso INT IDENTITY(1,1) PRIMARY KEY,
        Codigo VARCHAR(120) NOT NULL,
        Nombre VARCHAR(120) NOT NULL,
        Modulo VARCHAR(80) NOT NULL,
        Descripcion VARCHAR(255) NOT NULL CONSTRAINT DF_Permisos_Descripcion DEFAULT (''),
        Estado VARCHAR(20) NOT NULL CONSTRAINT DF_Permisos_Estado DEFAULT ('Activo')
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_Permisos_Codigo')
BEGIN
    CREATE UNIQUE INDEX UQ_Permisos_Codigo ON Permisos (Codigo);
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RolPermisos')
BEGIN
    CREATE TABLE RolPermisos (
        IdRol INT NOT NULL,
        IdPermiso INT NOT NULL,
        CONSTRAINT PK_RolPermisos PRIMARY KEY (IdRol, IdPermiso),
        CONSTRAINT FK_RolPermisos_Roles FOREIGN KEY (IdRol) REFERENCES Roles (IdRol),
        CONSTRAINT FK_RolPermisos_Permisos FOREIGN KEY (IdPermiso) REFERENCES Permisos (IdPermiso)
    );
END;

DECLARE @Permisos TABLE (
    Codigo VARCHAR(120),
    Nombre VARCHAR(120),
    Modulo VARCHAR(80),
    Descripcion VARCHAR(255)
);

INSERT INTO @Permisos (Codigo, Nombre, Modulo, Descripcion)
VALUES
('usuarios.ver', 'Ver usuarios', 'Usuarios', 'Consultar lista y detalle de usuarios.'),
('usuarios.crear', 'Crear usuarios', 'Usuarios', 'Crear usuarios desde administracion.'),
('usuarios.actualizar', 'Actualizar usuarios', 'Usuarios', 'Modificar informacion y estado de usuarios.'),
('usuarios.eliminar', 'Eliminar usuarios', 'Usuarios', 'Inactivar usuarios.'),
('roles.ver', 'Ver roles', 'Roles', 'Consultar catalogo de roles.'),
('permisos.gestionar', 'Gestionar permisos', 'Permisos', 'Asignar y retirar permisos por rol.'),
('bitacora.ver', 'Ver bitacora', 'Bitacora', 'Consultar auditoria del sistema.'),
('productos.crear', 'Crear productos', 'Productos', 'Crear productos y cargar imagenes.'),
('productos.actualizar', 'Actualizar productos', 'Productos', 'Modificar productos existentes.'),
('productos.eliminar', 'Eliminar productos', 'Productos', 'Inactivar productos.'),
('categorias.leer', 'Ver categorias', 'Categorias', 'Consultar categorias de administracion.'),
('categorias.crear', 'Crear categorias', 'Categorias', 'Crear categorias.'),
('categorias.actualizar', 'Actualizar categorias', 'Categorias', 'Modificar categorias.'),
('categorias.eliminar', 'Eliminar categorias', 'Categorias', 'Inactivar categorias.'),
('tipos-producto.leer', 'Ver tipos de producto', 'Tipos de producto', 'Consultar tipos de producto de administracion.'),
('tipos-producto.crear', 'Crear tipos de producto', 'Tipos de producto', 'Crear tipos de producto.'),
('tipos-producto.actualizar', 'Actualizar tipos de producto', 'Tipos de producto', 'Modificar tipos de producto.'),
('tipos-producto.eliminar', 'Eliminar tipos de producto', 'Tipos de producto', 'Inactivar tipos de producto.');

INSERT INTO Permisos (Codigo, Nombre, Modulo, Descripcion)
SELECT p.Codigo, p.Nombre, p.Modulo, p.Descripcion
FROM @Permisos p
WHERE NOT EXISTS (
    SELECT 1 FROM Permisos existing WHERE existing.Codigo = p.Codigo
);

INSERT INTO RolPermisos (IdRol, IdPermiso)
SELECT 1, p.IdPermiso
FROM Permisos p
WHERE NOT EXISTS (
    SELECT 1
    FROM RolPermisos rp
    WHERE rp.IdRol = 1
        AND rp.IdPermiso = p.IdPermiso
);

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Favoritos')
BEGIN
    CREATE TABLE Favoritos (
        IdFavorito INT IDENTITY(1,1) PRIMARY KEY,
        IdUsuario INT NOT NULL,
        IdProducto INT NOT NULL,
        FechaRegistro DATETIME NOT NULL CONSTRAINT DF_Favoritos_FechaRegistro DEFAULT (GETDATE()),
        CONSTRAINT FK_Favoritos_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios (IdUsuario),
        CONSTRAINT FK_Favoritos_Productos FOREIGN KEY (IdProducto) REFERENCES Productos (IdProducto)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_Favoritos_UsuarioProducto')
BEGIN
    CREATE UNIQUE INDEX UQ_Favoritos_UsuarioProducto ON Favoritos (IdUsuario, IdProducto);
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'ProductoVariantes')
BEGIN
    CREATE TABLE ProductoVariantes (
        IdVariante INT IDENTITY(1,1) PRIMARY KEY,
        IdProducto INT NOT NULL,
        NombreVariante VARCHAR(120) NOT NULL,
        Tamano VARCHAR(80) NOT NULL CONSTRAINT DF_ProductoVariantes_Tamano DEFAULT ('No especificado'),
        Material VARCHAR(80) NOT NULL CONSTRAINT DF_ProductoVariantes_Material DEFAULT ('No especificado'),
        Precio DECIMAL(18,2) NOT NULL,
        Stock INT NOT NULL CONSTRAINT DF_ProductoVariantes_Stock DEFAULT (0),
        Imagen VARCHAR(255) NULL,
        Estado VARCHAR(20) NOT NULL CONSTRAINT DF_ProductoVariantes_Estado DEFAULT ('Activo'),
        FechaRegistro DATETIME NOT NULL CONSTRAINT DF_ProductoVariantes_FechaRegistro DEFAULT (GETDATE()),
        CONSTRAINT FK_ProductoVariantes_Productos FOREIGN KEY (IdProducto) REFERENCES Productos (IdProducto)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductoVariantes_IdProducto')
BEGIN
    CREATE INDEX IX_ProductoVariantes_IdProducto ON ProductoVariantes (IdProducto);
END;

INSERT INTO ProductoVariantes
    (IdProducto, NombreVariante, Tamano, Material, Precio, Stock, Imagen, Estado)
SELECT
    p.IdProducto,
    'Estandar',
    ISNULL(NULLIF(p.Tamano, ''), 'No especificado'),
    ISNULL(NULLIF(p.Material, ''), 'No especificado'),
    p.Precio,
    COALESCE(i.CantidadDisponible, p.Stock, 0),
    p.Imagen,
    'Activo'
FROM Productos p
LEFT JOIN Inventario i ON i.IdProducto = p.IdProducto
WHERE p.Estado = 'Activo'
    AND NOT EXISTS (
        SELECT 1
        FROM ProductoVariantes v
        WHERE v.IdProducto = p.IdProducto
    );

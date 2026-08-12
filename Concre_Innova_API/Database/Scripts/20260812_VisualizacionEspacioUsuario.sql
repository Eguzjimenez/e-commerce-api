-- Visualizacion del espacio del usuario: imagen cargada y proyectos guardados.
-- Fecha: 2026-08-12
-- Base de datos: ConcreInnovaDB
--
-- Contenido:
--   1. Tabla Visualizaciones (proyecto guardado por usuario).
--   2. Tabla VisualizacionProductos (productos colocados con su configuracion).
--   3. Tipo de tabla para enviar los productos colocados.
--   4. Procedimientos de guardado, consulta y eliminacion.
--
-- Todos los procedimientos filtran por IdUsuario para que una persona solo
-- pueda leer o modificar sus propias visualizaciones.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ---------------------------------------------------------------------------
-- 1. Encabezado de la visualizacion.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.Visualizaciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Visualizaciones
    (
        IdVisualizacion INT IDENTITY(1,1) NOT NULL,
        IdUsuario INT NOT NULL,
        Nombre VARCHAR(120) NOT NULL,
        RutaImagenEspacio VARCHAR(255) NOT NULL,
        AnchoLienzo INT NOT NULL,
        AltoLienzo INT NOT NULL,
        FechaCreacion DATETIME2(0) NOT NULL
            CONSTRAINT DF_Visualizaciones_FechaCreacion DEFAULT (SYSDATETIME()),
        FechaActualizacion DATETIME2(0) NOT NULL
            CONSTRAINT DF_Visualizaciones_FechaActualizacion DEFAULT (SYSDATETIME()),
        Estado VARCHAR(20) NOT NULL
            CONSTRAINT DF_Visualizaciones_Estado DEFAULT ('Activo'),
        CONSTRAINT PK_Visualizaciones PRIMARY KEY CLUSTERED (IdVisualizacion),
        CONSTRAINT FK_Visualizaciones_Usuarios
            FOREIGN KEY (IdUsuario)
            REFERENCES dbo.Usuarios (IdUsuario)
            ON DELETE CASCADE,
        CONSTRAINT CK_Visualizaciones_Lienzo
            CHECK (AnchoLienzo > 0 AND AltoLienzo > 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Visualizaciones')
      AND name = 'IX_Visualizaciones_UsuarioFecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Visualizaciones_UsuarioFecha
        ON dbo.Visualizaciones (IdUsuario, FechaActualizacion DESC, IdVisualizacion DESC)
        INCLUDE (Nombre, RutaImagenEspacio, Estado);
END;
GO

-- ---------------------------------------------------------------------------
-- 2. Productos colocados sobre la imagen del espacio.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.VisualizacionProductos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.VisualizacionProductos
    (
        IdVisualizacionProducto INT IDENTITY(1,1) NOT NULL,
        IdVisualizacion INT NOT NULL,
        IdProducto INT NOT NULL,
        IdVariante INT NULL,
        Cantidad INT NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Cantidad DEFAULT (1),
        Color VARCHAR(80) NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Color DEFAULT (''),
        Macetero VARCHAR(150) NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Macetero DEFAULT (''),
        PosicionX DECIMAL(9,2) NOT NULL,
        PosicionY DECIMAL(9,2) NOT NULL,
        Ancho DECIMAL(9,2) NOT NULL,
        Alto DECIMAL(9,2) NOT NULL,
        Rotacion DECIMAL(9,2) NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Rotacion DEFAULT (0),
        Orden INT NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Orden DEFAULT (1),
        CONSTRAINT PK_VisualizacionProductos
            PRIMARY KEY CLUSTERED (IdVisualizacionProducto),
        CONSTRAINT FK_VisualizacionProductos_Visualizaciones
            FOREIGN KEY (IdVisualizacion)
            REFERENCES dbo.Visualizaciones (IdVisualizacion)
            ON DELETE CASCADE,
        CONSTRAINT FK_VisualizacionProductos_Productos
            FOREIGN KEY (IdProducto)
            REFERENCES dbo.Productos (IdProducto),
        CONSTRAINT FK_VisualizacionProductos_ProductoVariantes
            FOREIGN KEY (IdVariante)
            REFERENCES dbo.ProductoVariantes (IdVariante),
        CONSTRAINT CK_VisualizacionProductos_Cantidad CHECK (Cantidad > 0),
        CONSTRAINT CK_VisualizacionProductos_Dimensiones
            CHECK (Ancho > 0 AND Alto > 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.VisualizacionProductos')
      AND name = 'IX_VisualizacionProductos_Visualizacion'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_VisualizacionProductos_Visualizacion
        ON dbo.VisualizacionProductos (IdVisualizacion, Orden, IdVisualizacionProducto);
END;
GO

-- ---------------------------------------------------------------------------
-- 3. Tipo de tabla para los productos colocados.
-- ---------------------------------------------------------------------------

IF TYPE_ID(N'dbo.TVP_VisualizacionProducto') IS NULL
BEGIN
    EXEC
    (
        N'CREATE TYPE dbo.TVP_VisualizacionProducto AS TABLE
        (
            IdProducto INT NOT NULL,
            IdVariante INT NULL,
            Cantidad INT NOT NULL,
            Color VARCHAR(80) NULL,
            Macetero VARCHAR(150) NULL,
            PosicionX DECIMAL(9,2) NOT NULL,
            PosicionY DECIMAL(9,2) NOT NULL,
            Ancho DECIMAL(9,2) NOT NULL,
            Alto DECIMAL(9,2) NOT NULL,
            Rotacion DECIMAL(9,2) NOT NULL,
            Orden INT NOT NULL
        );'
    );
END;
GO

-- ---------------------------------------------------------------------------
-- 4. Procedimientos.
-- ---------------------------------------------------------------------------

-- Crea o actualiza una visualizacion. Devuelve la ruta de la imagen anterior
-- cuando se reemplaza, para que la API pueda borrar el archivo en desuso.
CREATE OR ALTER PROCEDURE dbo.SP_GuardarVisualizacion
(
    @IdUsuario INT,
    @IdVisualizacion INT = NULL,
    @Nombre VARCHAR(120),
    @RutaImagenEspacio VARCHAR(255),
    @AnchoLienzo INT,
    @AltoLienzo INT,
    @Productos dbo.TVP_VisualizacionProducto READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RutaImagenAnterior VARCHAR(255) = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario
              AND Estado = 'Activo'
        )
        BEGIN
            THROW 52001, 'USUARIO_NO_EXISTE', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM @Productos)
        BEGIN
            THROW 52002, 'SIN_PRODUCTOS', 1;
        END

        IF EXISTS
        (
            SELECT 1
            FROM @Productos P
            LEFT JOIN dbo.Productos PR
                ON PR.IdProducto = P.IdProducto
            WHERE PR.IdProducto IS NULL
               OR PR.Estado <> 'Activo'
        )
        BEGIN
            THROW 52003, 'PRODUCTO_NO_DISPONIBLE', 1;
        END

        IF @IdVisualizacion IS NOT NULL
        BEGIN
            SELECT
                @RutaImagenAnterior = RutaImagenEspacio
            FROM dbo.Visualizaciones
            WHERE IdVisualizacion = @IdVisualizacion
              AND IdUsuario = @IdUsuario;

            IF @RutaImagenAnterior IS NULL
            BEGIN
                THROW 52004, 'VISUALIZACION_NO_ENCONTRADA', 1;
            END

            UPDATE dbo.Visualizaciones
            SET
                Nombre = @Nombre,
                RutaImagenEspacio = @RutaImagenEspacio,
                AnchoLienzo = @AnchoLienzo,
                AltoLienzo = @AltoLienzo,
                FechaActualizacion = SYSDATETIME(),
                Estado = 'Activo'
            WHERE IdVisualizacion = @IdVisualizacion
              AND IdUsuario = @IdUsuario;

            DELETE FROM dbo.VisualizacionProductos
            WHERE IdVisualizacion = @IdVisualizacion;

            IF @RutaImagenAnterior = @RutaImagenEspacio
            BEGIN
                SET @RutaImagenAnterior = NULL;
            END
        END
        ELSE
        BEGIN
            INSERT INTO dbo.Visualizaciones
            (
                IdUsuario,
                Nombre,
                RutaImagenEspacio,
                AnchoLienzo,
                AltoLienzo
            )
            VALUES
            (
                @IdUsuario,
                @Nombre,
                @RutaImagenEspacio,
                @AnchoLienzo,
                @AltoLienzo
            );

            SET @IdVisualizacion = CONVERT(INT, SCOPE_IDENTITY());
        END

        INSERT INTO dbo.VisualizacionProductos
        (
            IdVisualizacion,
            IdProducto,
            IdVariante,
            Cantidad,
            Color,
            Macetero,
            PosicionX,
            PosicionY,
            Ancho,
            Alto,
            Rotacion,
            Orden
        )
        SELECT
            @IdVisualizacion,
            P.IdProducto,
            P.IdVariante,
            P.Cantidad,
            ISNULL(P.Color, ''),
            ISNULL(P.Macetero, ''),
            P.PosicionX,
            P.PosicionY,
            P.Ancho,
            P.Alto,
            P.Rotacion,
            P.Orden
        FROM @Productos P;

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'VISUALIZACION_GUARDADA' AS Mensaje,
            @IdVisualizacion AS IdVisualizacion,
            @RutaImagenAnterior AS RutaImagenAnterior;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Codigo,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS IdVisualizacion,
            NULL AS RutaImagenAnterior;
    END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerVisualizacionesUsuario
(
    @IdUsuario INT,
    @IdVisualizacion INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        V.IdVisualizacion,
        V.Nombre,
        V.RutaImagenEspacio,
        V.AnchoLienzo,
        V.AltoLienzo,
        V.FechaCreacion,
        V.FechaActualizacion
    INTO #VisualizacionesUsuario
    FROM dbo.Visualizaciones V
    WHERE V.IdUsuario = @IdUsuario
      AND V.Estado = 'Activo'
      AND (@IdVisualizacion IS NULL OR V.IdVisualizacion = @IdVisualizacion);

    SELECT
        VU.IdVisualizacion,
        VU.Nombre,
        VU.RutaImagenEspacio,
        VU.AnchoLienzo,
        VU.AltoLienzo,
        VU.FechaCreacion,
        VU.FechaActualizacion,
        (
            SELECT COUNT(*)
            FROM dbo.VisualizacionProductos VP
            WHERE VP.IdVisualizacion = VU.IdVisualizacion
        ) AS TotalProductos
    FROM #VisualizacionesUsuario VU
    ORDER BY VU.FechaActualizacion DESC, VU.IdVisualizacion DESC;

    SELECT
        VP.IdVisualizacionProducto,
        VP.IdVisualizacion,
        VP.IdProducto,
        VP.IdVariante,
        COALESCE(PR.Nombre, CONCAT('Producto #', VP.IdProducto)) AS Nombre,
        ISNULL(PV.Imagen, PR.Imagen) AS Imagen,
        COALESCE(PV.Precio, PR.Precio, 0) AS Precio,
        COALESCE(NULLIF(PV.Tamano, ''), PR.Tamano, '') AS Tamano,
        COALESCE(NULLIF(PV.Material, ''), PR.Material, '') AS Material,
        ISNULL(CC.Clasificacion, 'Otro') AS Clasificacion,
        VP.Cantidad,
        VP.Color,
        VP.Macetero,
        VP.PosicionX,
        VP.PosicionY,
        VP.Ancho,
        VP.Alto,
        VP.Rotacion,
        VP.Orden
    FROM dbo.VisualizacionProductos VP
    INNER JOIN #VisualizacionesUsuario VU
        ON VU.IdVisualizacion = VP.IdVisualizacion
    LEFT JOIN dbo.Productos PR
        ON PR.IdProducto = VP.IdProducto
    LEFT JOIN dbo.ProductoVariantes PV
        ON PV.IdVariante = VP.IdVariante
       AND PV.IdProducto = VP.IdProducto
    LEFT JOIN dbo.CategoriaClasificacion CC
        ON CC.IdCategoria = PR.IdCategoria
    ORDER BY VP.IdVisualizacion, VP.Orden, VP.IdVisualizacionProducto;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_EliminarVisualizacion
(
    @IdUsuario INT,
    @IdVisualizacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RutaImagenEspacio VARCHAR(255) = NULL;

    SELECT
        @RutaImagenEspacio = RutaImagenEspacio
    FROM dbo.Visualizaciones
    WHERE IdVisualizacion = @IdVisualizacion
      AND IdUsuario = @IdUsuario;

    IF @RutaImagenEspacio IS NULL
    BEGIN
        SELECT
            0 AS Codigo,
            'VISUALIZACION_NO_ENCONTRADA' AS Mensaje,
            NULL AS RutaImagenEspacio;

        RETURN;
    END

    DELETE FROM dbo.Visualizaciones
    WHERE IdVisualizacion = @IdVisualizacion
      AND IdUsuario = @IdUsuario;

    SELECT
        1 AS Codigo,
        'VISUALIZACION_ELIMINADA' AS Mensaje,
        @RutaImagenEspacio AS RutaImagenEspacio;
END;
GO

PRINT 'Visualizacion del espacio del usuario instalada.';
GO

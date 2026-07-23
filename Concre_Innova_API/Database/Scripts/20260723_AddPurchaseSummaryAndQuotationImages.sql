-- Sprint 3: authoritative purchase summary and quotation reference images.
-- Database: ConcreInnovaDB

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
GO

IF COL_LENGTH('dbo.Cotizaciones', 'Descripcion') IS NULL
BEGIN
    ALTER TABLE dbo.Cotizaciones
        ADD Descripcion VARCHAR(1000) NULL;
END;
GO

IF OBJECT_ID('dbo.CotizacionImagenes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CotizacionImagenes
    (
        IdCotizacionImagen INT IDENTITY(1,1) NOT NULL,
        IdCotizacion INT NOT NULL,
        RutaArchivo VARCHAR(500) NOT NULL,
        NombreOriginal VARCHAR(255) NOT NULL,
        TipoContenido VARCHAR(100) NOT NULL,
        TamanoBytes BIGINT NOT NULL,
        FechaCarga DATETIME NOT NULL
            CONSTRAINT DF_CotizacionImagenes_FechaCarga DEFAULT GETDATE(),
        CONSTRAINT PK_CotizacionImagenes
            PRIMARY KEY CLUSTERED (IdCotizacionImagen),
        CONSTRAINT FK_CotizacionImagenes_Cotizaciones
            FOREIGN KEY (IdCotizacion)
            REFERENCES dbo.Cotizaciones (IdCotizacion)
            ON DELETE CASCADE
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.CotizacionImagenes')
      AND name = 'IX_CotizacionImagenes_IdCotizacion'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_CotizacionImagenes_IdCotizacion
        ON dbo.CotizacionImagenes (IdCotizacion);
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Clientes')
      AND name = 'UX_Clientes_IdUsuario'
)
AND NOT EXISTS
(
    SELECT IdUsuario
    FROM dbo.Clientes
    WHERE IdUsuario IS NOT NULL
    GROUP BY IdUsuario
    HAVING COUNT(*) > 1
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_Clientes_IdUsuario
        ON dbo.Clientes (IdUsuario)
        WHERE IdUsuario IS NOT NULL;
END;
GO

IF TYPE_ID('dbo.TVP_CotizacionImagen') IS NULL
BEGIN
    EXEC
    (
        'CREATE TYPE dbo.TVP_CotizacionImagen AS TABLE
        (
            RutaArchivo VARCHAR(500) NOT NULL,
            NombreOriginal VARCHAR(255) NOT NULL,
            TipoContenido VARCHAR(100) NOT NULL,
            TamanoBytes BIGINT NOT NULL
        );'
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ValidarStockCarrito
(
    @Carrito dbo.TVP_PedidoItem READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.IdProducto,
        C.IdVariante,
        SUM(C.Cantidad) AS Cantidad
    INTO #ItemsCarrito
    FROM @Carrito C
    GROUP BY
        C.IdProducto,
        C.IdVariante;

    SELECT
        C.IdProducto,
        C.IdVariante,
        CASE
            WHEN C.IdVariante IS NULL THEN P.Nombre
            ELSE CONCAT(P.Nombre, ' - ', V.NombreVariante)
        END AS Nombre,
        C.Cantidad AS CantidadSolicitada,
        CASE
            WHEN C.IdVariante IS NULL THEN ISNULL(P.Stock, 0)
            ELSE ISNULL(V.Stock, 0)
        END AS StockDisponible,
        CONVERT
        (
            DECIMAL(10,2),
            CASE
                WHEN C.IdVariante IS NULL THEN ISNULL(P.Precio, 0)
                ELSE COALESCE(V.Precio, P.Precio, 0)
            END
        ) AS PrecioUnitario,
        CONVERT
        (
            DECIMAL(28,2),
            C.Cantidad *
            CASE
                WHEN C.IdVariante IS NULL THEN ISNULL(P.Precio, 0)
                ELSE COALESCE(V.Precio, P.Precio, 0)
            END
        ) AS Subtotal,
        CASE
            WHEN P.IdProducto IS NULL THEN 'PRODUCTO_NO_EXISTE'
            WHEN C.Cantidad <= 0 THEN 'CANTIDAD_INVALIDA'
            WHEN ISNULL(P.Estado, 'Activo') <> 'Activo' THEN 'PRODUCTO_NO_DISPONIBLE'
            WHEN C.IdVariante IS NOT NULL AND V.IdVariante IS NULL THEN 'VARIANTE_NO_EXISTE'
            WHEN C.IdVariante IS NOT NULL AND V.Estado <> 'Activo' THEN 'VARIANTE_NO_DISPONIBLE'
            WHEN C.IdVariante IS NULL AND ISNULL(P.Stock, 0) <= 0 THEN 'SIN_STOCK'
            WHEN C.IdVariante IS NOT NULL AND ISNULL(V.Stock, 0) <= 0 THEN 'SIN_STOCK'
            WHEN C.IdVariante IS NULL AND ISNULL(P.Stock, 0) < C.Cantidad THEN 'STOCK_INSUFICIENTE'
            WHEN C.IdVariante IS NOT NULL AND ISNULL(V.Stock, 0) < C.Cantidad THEN 'STOCK_INSUFICIENTE'
            ELSE 'DISPONIBLE'
        END AS Estado
    FROM #ItemsCarrito C
    LEFT JOIN dbo.Productos P
        ON P.IdProducto = C.IdProducto
    LEFT JOIN dbo.ProductoVariantes V
        ON V.IdVariante = C.IdVariante
       AND V.IdProducto = C.IdProducto;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CrearCotizacionConImagenes
(
    @IdUsuario INT,
    @Descripcion VARCHAR(1000),
    @Imagenes dbo.TVP_CotizacionImagen READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCliente INT;
    DECLARE @IdCotizacion INT;
    DECLARE @Correo VARCHAR(150);

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
            THROW 50001, 'USUARIO_NO_EXISTE', 1;
        END;

        IF NULLIF(LTRIM(RTRIM(@Descripcion)), '') IS NULL
        BEGIN
            THROW 50002, 'DESCRIPCION_REQUERIDA', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @Imagenes)
        BEGIN
            THROW 50003, 'IMAGEN_REQUERIDA', 1;
        END;

        SELECT
            @IdCliente = C.IdCliente
        FROM dbo.Clientes C
        WHERE C.IdUsuario = @IdUsuario;

        IF @IdCliente IS NULL
        BEGIN
            SELECT @Correo = U.Correo
            FROM dbo.Usuarios U
            WHERE U.IdUsuario = @IdUsuario;

            SELECT @IdCliente = C.IdCliente
            FROM dbo.Clientes C
            WHERE C.Correo = @Correo
              AND C.IdUsuario IS NULL;

            IF @IdCliente IS NOT NULL
            BEGIN
                UPDATE dbo.Clientes
                SET IdUsuario = @IdUsuario
                WHERE IdCliente = @IdCliente;
            END;
            ELSE
            BEGIN
                INSERT dbo.Clientes
                (
                    Nombre,
                    Apellido,
                    Correo,
                    Telefono,
                    FechaRegistro,
                    Estado,
                    IdUsuario
                )
                SELECT
                    U.Nombre,
                    ISNULL(U.Apellido, ''),
                    U.Correo,
                    U.Telefono,
                    GETDATE(),
                    'Activo',
                    U.IdUsuario
                FROM dbo.Usuarios U
                WHERE U.IdUsuario = @IdUsuario;

                SET @IdCliente = SCOPE_IDENTITY();
            END;
        END;

        INSERT dbo.Cotizaciones
        (
            IdCliente,
            FechaCotizacion,
            Estado,
            Total,
            Descripcion
        )
        VALUES
        (
            @IdCliente,
            GETDATE(),
            'Pendiente',
            0,
            LTRIM(RTRIM(@Descripcion))
        );

        SET @IdCotizacion = SCOPE_IDENTITY();

        INSERT dbo.CotizacionImagenes
        (
            IdCotizacion,
            RutaArchivo,
            NombreOriginal,
            TipoContenido,
            TamanoBytes
        )
        SELECT
            @IdCotizacion,
            I.RutaArchivo,
            I.NombreOriginal,
            I.TipoContenido,
            I.TamanoBytes
        FROM @Imagenes I;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'Cotizacion creada correctamente.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            COUNT(*) AS CantidadImagenes
        FROM @Imagenes;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            0 AS CantidadImagenes;
    END CATCH;
END;
GO

PRINT 'Purchase summary and quotation images installed.';
GO

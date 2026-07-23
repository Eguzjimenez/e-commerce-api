-- Sprint 3: requested products, preferences and quotation tracking number.
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

IF COL_LENGTH('dbo.Cotizaciones', 'Preferencias') IS NULL
BEGIN
    ALTER TABLE dbo.Cotizaciones ADD Preferencias VARCHAR(1000) NULL;
END;
GO

IF COL_LENGTH('dbo.Cotizaciones', 'NumeroSeguimiento') IS NULL
BEGIN
    ALTER TABLE dbo.Cotizaciones ADD NumeroSeguimiento VARCHAR(30) NULL;
END;
GO

UPDATE dbo.Cotizaciones
SET NumeroSeguimiento =
    CONCAT('COT-', RIGHT(REPLICATE('0', 10) +
        CONVERT(VARCHAR(10), IdCotizacion), 10))
WHERE NumeroSeguimiento IS NULL;
GO

IF OBJECT_ID('dbo.SolicitudCotizacionProductos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SolicitudCotizacionProductos
    (
        IdSolicitudCotizacionProducto INT IDENTITY(1,1) NOT NULL,
        IdCotizacion INT NOT NULL,
        IdProducto INT NOT NULL,
        Cantidad INT NOT NULL,
        CONSTRAINT PK_SolicitudCotizacionProductos
            PRIMARY KEY CLUSTERED (IdSolicitudCotizacionProducto),
        CONSTRAINT FK_SolicitudCotizacionProductos_Cotizaciones
            FOREIGN KEY (IdCotizacion)
            REFERENCES dbo.Cotizaciones (IdCotizacion)
            ON DELETE CASCADE,
        CONSTRAINT FK_SolicitudCotizacionProductos_Productos
            FOREIGN KEY (IdProducto)
            REFERENCES dbo.Productos (IdProducto),
        CONSTRAINT CK_SolicitudCotizacionProductos_Cantidad
            CHECK (Cantidad > 0),
        CONSTRAINT UQ_SolicitudCotizacionProductos_CotizacionProducto
            UNIQUE (IdCotizacion, IdProducto)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Cotizaciones')
      AND name = 'UX_Cotizaciones_NumeroSeguimiento'
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_Cotizaciones_NumeroSeguimiento
        ON dbo.Cotizaciones (NumeroSeguimiento)
        WHERE NumeroSeguimiento IS NOT NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.SolicitudCotizacionProductos')
      AND name = 'IX_SolicitudCotizacionProductos_IdCotizacion'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_SolicitudCotizacionProductos_IdCotizacion
        ON dbo.SolicitudCotizacionProductos (IdCotizacion)
        INCLUDE (IdProducto, Cantidad);
END;
GO

IF TYPE_ID('dbo.TVP_SolicitudCotizacionProducto') IS NULL
BEGIN
    EXEC
    (
        'CREATE TYPE dbo.TVP_SolicitudCotizacionProducto AS TABLE
        (
            IdProducto INT NOT NULL,
            Cantidad INT NOT NULL
        );'
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CrearCotizacionConImagenes
(
    @IdUsuario INT,
    @Descripcion VARCHAR(1000),
    @Preferencias VARCHAR(1000),
    @ProductosSolicitados dbo.TVP_SolicitudCotizacionProducto READONLY,
    @Imagenes dbo.TVP_CotizacionImagen READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCliente INT;
    DECLARE @IdCotizacion INT;
    DECLARE @Correo VARCHAR(150);
    DECLARE @NumeroSeguimiento VARCHAR(30);

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

        IF NULLIF(LTRIM(RTRIM(@Preferencias)), '') IS NULL
        BEGIN
            THROW 50003, 'PREFERENCIAS_REQUERIDAS', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @ProductosSolicitados)
        BEGIN
            THROW 50004, 'PRODUCTOS_REQUERIDOS', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @ProductosSolicitados S
            GROUP BY S.IdProducto
            HAVING COUNT(*) > 1
        )
        BEGIN
            THROW 50005, 'PRODUCTO_DUPLICADO', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @ProductosSolicitados S
            LEFT JOIN dbo.Productos P
                ON P.IdProducto = S.IdProducto
               AND P.Estado = 'Activo'
            WHERE P.IdProducto IS NULL
               OR S.Cantidad <= 0
        )
        BEGIN
            THROW 50006, 'PRODUCTO_NO_DISPONIBLE', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @Imagenes)
        BEGIN
            THROW 50007, 'IMAGEN_REQUERIDA', 1;
        END;

        SELECT @IdCliente = C.IdCliente
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
            Descripcion,
            Preferencias
        )
        VALUES
        (
            @IdCliente,
            GETDATE(),
            'Pendiente',
            0,
            LTRIM(RTRIM(@Descripcion)),
            LTRIM(RTRIM(@Preferencias))
        );

        SET @IdCotizacion = SCOPE_IDENTITY();
        SET @NumeroSeguimiento =
            CONCAT('COT-', RIGHT(REPLICATE('0', 10) +
                CONVERT(VARCHAR(10), @IdCotizacion), 10));

        UPDATE dbo.Cotizaciones
        SET NumeroSeguimiento = @NumeroSeguimiento
        WHERE IdCotizacion = @IdCotizacion;

        INSERT dbo.SolicitudCotizacionProductos
        (
            IdCotizacion,
            IdProducto,
            Cantidad
        )
        SELECT
            @IdCotizacion,
            S.IdProducto,
            S.Cantidad
        FROM @ProductosSolicitados S;

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
            'Cotizacion recibida y lista para ser procesada.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            @NumeroSeguimiento AS NumeroSeguimiento,
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
            '' AS NumeroSeguimiento,
            0 AS CantidadImagenes;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerMisCotizaciones
(
    @IdUsuario INT,
    @Pagina INT = 1,
    @TamanoPagina INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Pagina = CASE WHEN @Pagina < 1 THEN 1 ELSE @Pagina END;
    SET @TamanoPagina =
        CASE
            WHEN @TamanoPagina < 1 THEN 10
            WHEN @TamanoPagina > 100 THEN 100
            ELSE @TamanoPagina
        END;

    SELECT C.IdCotizacion
    INTO #CotizacionesPagina
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    WHERE CL.IdUsuario = @IdUsuario
    ORDER BY C.FechaCotizacion DESC, C.IdCotizacion DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;

    SELECT
        C.IdCotizacion,
        ISNULL(C.NumeroSeguimiento,
            CONCAT('COT-', RIGHT(REPLICATE('0', 10) +
                CONVERT(VARCHAR(10), C.IdCotizacion), 10))) AS NumeroSeguimiento,
        C.IdCliente,
        CONCAT(CL.Nombre, ' ', CL.Apellido) AS Cliente,
        ISNULL(C.FechaCotizacion, GETDATE()) AS FechaSolicitud,
        ISNULL(C.Estado, 'Pendiente') AS Estado,
        C.Total,
        ISNULL(C.Descripcion, '') AS Descripcion,
        ISNULL(C.Preferencias, '') AS Preferencias,
        ISNULL(C.Respuesta, '') AS Respuesta,
        C.FechaRespuesta,
        P.IdPedido
    FROM #CotizacionesPagina CP
    INNER JOIN dbo.Cotizaciones C
        ON C.IdCotizacion = CP.IdCotizacion
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    LEFT JOIN dbo.Pedidos P
        ON P.IdCotizacion = C.IdCotizacion
    ORDER BY C.FechaCotizacion DESC, C.IdCotizacion DESC;

    SELECT
        D.IdCotizacion,
        D.IdProducto,
        P.Nombre,
        P.Imagen,
        D.Cantidad,
        D.PrecioUnitario,
        D.Subtotal
    FROM dbo.DetalleCotizacion D
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = D.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = D.IdProducto
    ORDER BY D.IdDetalleCotizacion;

    SELECT
        S.IdCotizacion,
        S.IdProducto,
        P.Nombre,
        P.Imagen,
        S.Cantidad
    FROM dbo.SolicitudCotizacionProductos S
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = S.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = S.IdProducto
    ORDER BY S.IdSolicitudCotizacionProducto;

    SELECT
        I.IdCotizacion,
        I.RutaArchivo,
        I.NombreOriginal,
        I.TipoContenido,
        I.TamanoBytes
    FROM dbo.CotizacionImagenes I
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = I.IdCotizacion
    ORDER BY I.IdCotizacionImagen;

    SELECT COUNT(*) AS TotalItems
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    WHERE CL.IdUsuario = @IdUsuario;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerCotizacionesAdmin
(
    @Pagina INT = 1,
    @TamanoPagina INT = 20
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Pagina = CASE WHEN @Pagina < 1 THEN 1 ELSE @Pagina END;
    SET @TamanoPagina =
        CASE
            WHEN @TamanoPagina < 1 THEN 20
            WHEN @TamanoPagina > 100 THEN 100
            ELSE @TamanoPagina
        END;

    SELECT C.IdCotizacion
    INTO #CotizacionesPagina
    FROM dbo.Cotizaciones C
    ORDER BY C.FechaCotizacion DESC, C.IdCotizacion DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;

    SELECT
        C.IdCotizacion,
        ISNULL(C.NumeroSeguimiento,
            CONCAT('COT-', RIGHT(REPLICATE('0', 10) +
                CONVERT(VARCHAR(10), C.IdCotizacion), 10))) AS NumeroSeguimiento,
        C.IdCliente,
        CONCAT(CL.Nombre, ' ', CL.Apellido) AS Cliente,
        ISNULL(C.FechaCotizacion, GETDATE()) AS FechaSolicitud,
        ISNULL(C.Estado, 'Pendiente') AS Estado,
        C.Total,
        ISNULL(C.Descripcion, '') AS Descripcion,
        ISNULL(C.Preferencias, '') AS Preferencias,
        ISNULL(C.Respuesta, '') AS Respuesta,
        C.FechaRespuesta,
        P.IdPedido
    FROM #CotizacionesPagina CP
    INNER JOIN dbo.Cotizaciones C
        ON C.IdCotizacion = CP.IdCotizacion
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    LEFT JOIN dbo.Pedidos P
        ON P.IdCotizacion = C.IdCotizacion
    ORDER BY C.FechaCotizacion DESC, C.IdCotizacion DESC;

    SELECT
        D.IdCotizacion,
        D.IdProducto,
        P.Nombre,
        P.Imagen,
        D.Cantidad,
        D.PrecioUnitario,
        D.Subtotal
    FROM dbo.DetalleCotizacion D
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = D.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = D.IdProducto
    ORDER BY D.IdDetalleCotizacion;

    SELECT
        S.IdCotizacion,
        S.IdProducto,
        P.Nombre,
        P.Imagen,
        S.Cantidad
    FROM dbo.SolicitudCotizacionProductos S
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = S.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = S.IdProducto
    ORDER BY S.IdSolicitudCotizacionProducto;

    SELECT
        I.IdCotizacion,
        I.RutaArchivo,
        I.NombreOriginal,
        I.TipoContenido,
        I.TamanoBytes
    FROM dbo.CotizacionImagenes I
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = I.IdCotizacion
    ORDER BY I.IdCotizacionImagen;

    SELECT COUNT(*) AS TotalItems
    FROM dbo.Cotizaciones;
END;
GO

PRINT 'Quotation request products and tracking installed.';
GO

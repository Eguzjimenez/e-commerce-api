-- Sprint 3: quotation search, status filters and status-change history.
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

IF OBJECT_ID('dbo.CotizacionEstadoHistorial', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CotizacionEstadoHistorial
    (
        IdCotizacionEstadoHistorial INT IDENTITY(1,1) NOT NULL,
        IdCotizacion INT NOT NULL,
        EstadoAnterior VARCHAR(30) NULL,
        EstadoNuevo VARCHAR(30) NOT NULL,
        FechaCambio DATETIME2(0) NOT NULL
            CONSTRAINT DF_CotizacionEstadoHistorial_FechaCambio
            DEFAULT SYSDATETIME(),
        CONSTRAINT PK_CotizacionEstadoHistorial
            PRIMARY KEY CLUSTERED (IdCotizacionEstadoHistorial),
        CONSTRAINT FK_CotizacionEstadoHistorial_Cotizaciones
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
    WHERE object_id = OBJECT_ID('dbo.CotizacionEstadoHistorial')
      AND name = 'IX_CotizacionEstadoHistorial_CotizacionFecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_CotizacionEstadoHistorial_CotizacionFecha
        ON dbo.CotizacionEstadoHistorial
        (
            IdCotizacion,
            FechaCambio,
            IdCotizacionEstadoHistorial
        )
        INCLUDE (EstadoAnterior, EstadoNuevo);
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Cotizaciones')
      AND name = 'IX_Cotizaciones_ClienteEstadoFecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Cotizaciones_ClienteEstadoFecha
        ON dbo.Cotizaciones
        (
            IdCliente,
            Estado,
            FechaCotizacion DESC,
            IdCotizacion DESC
        )
        INCLUDE (NumeroSeguimiento);
END;
GO

INSERT dbo.CotizacionEstadoHistorial
(
    IdCotizacion,
    EstadoAnterior,
    EstadoNuevo,
    FechaCambio
)
SELECT
    C.IdCotizacion,
    NULL,
    ISNULL(C.Estado, 'Pendiente'),
    CONVERT(DATETIME2(0), ISNULL(C.FechaCotizacion, GETDATE()))
FROM dbo.Cotizaciones C
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.CotizacionEstadoHistorial H
    WHERE H.IdCotizacion = C.IdCotizacion
);
GO

CREATE OR ALTER TRIGGER dbo.TR_Cotizaciones_RegistrarCambioEstado
ON dbo.Cotizaciones
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT dbo.CotizacionEstadoHistorial
    (
        IdCotizacion,
        EstadoAnterior,
        EstadoNuevo,
        FechaCambio
    )
    SELECT
        I.IdCotizacion,
        D.Estado,
        ISNULL(I.Estado, 'Pendiente'),
        SYSDATETIME()
    FROM inserted I
    LEFT JOIN deleted D
        ON D.IdCotizacion = I.IdCotizacion
    WHERE D.IdCotizacion IS NULL
       OR ISNULL(D.Estado, '') <> ISNULL(I.Estado, '');
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerMisCotizaciones
(
    @IdUsuario INT,
    @Pagina INT = 1,
    @TamanoPagina INT = 10,
    @Estado VARCHAR(30) = NULL,
    @Busqueda VARCHAR(100) = NULL
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
    SET @Estado = NULLIF(LTRIM(RTRIM(@Estado)), '');
    SET @Busqueda = NULLIF(LTRIM(RTRIM(@Busqueda)), '');

    DECLARE @PatronBusqueda VARCHAR(306) = NULL;
    IF @Busqueda IS NOT NULL
    BEGIN
        SET @PatronBusqueda =
            '%' +
            REPLACE(
                REPLACE(
                    REPLACE(@Busqueda, '\', '\\'),
                    '%',
                    '\%'),
                '_',
                '\_') +
            '%';
    END;

    SELECT
        C.IdCotizacion,
        C.FechaCotizacion
    INTO #CotizacionesFiltradas
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    WHERE CL.IdUsuario = @IdUsuario
      AND (@Estado IS NULL OR C.Estado = @Estado)
      AND
      (
          @PatronBusqueda IS NULL
          OR C.NumeroSeguimiento LIKE @PatronBusqueda ESCAPE '\'
          OR C.Descripcion LIKE @PatronBusqueda ESCAPE '\'
          OR C.Preferencias LIKE @PatronBusqueda ESCAPE '\'
          OR C.Respuesta LIKE @PatronBusqueda ESCAPE '\'
          OR EXISTS
          (
              SELECT 1
              FROM dbo.SolicitudCotizacionProductos S
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = S.IdProducto
              WHERE S.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
          OR EXISTS
          (
              SELECT 1
              FROM dbo.DetalleCotizacion D
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = D.IdProducto
              WHERE D.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
      );

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesFiltradas_Id
        ON #CotizacionesFiltradas (IdCotizacion);

    SELECT F.IdCotizacion
    INTO #CotizacionesPagina
    FROM #CotizacionesFiltradas F
    ORDER BY F.FechaCotizacion DESC, F.IdCotizacion DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesPagina_Id
        ON #CotizacionesPagina (IdCotizacion);

    SELECT
        C.IdCotizacion,
        ISNULL(
            C.NumeroSeguimiento,
            CONCAT(
                'COT-',
                RIGHT(
                    REPLICATE('0', 10) +
                    CONVERT(VARCHAR(10), C.IdCotizacion),
                    10))) AS NumeroSeguimiento,
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

    SELECT
        H.IdCotizacion,
        H.EstadoAnterior,
        H.EstadoNuevo,
        H.FechaCambio
    FROM dbo.CotizacionEstadoHistorial H
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = H.IdCotizacion
    ORDER BY
        H.IdCotizacion,
        H.FechaCambio,
        H.IdCotizacionEstadoHistorial;

    SELECT COUNT(*) AS TotalItems
    FROM #CotizacionesFiltradas;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerCotizacionesAdmin
(
    @Pagina INT = 1,
    @TamanoPagina INT = 20,
    @Estado VARCHAR(30) = NULL,
    @Busqueda VARCHAR(100) = NULL
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
    SET @Estado = NULLIF(LTRIM(RTRIM(@Estado)), '');
    SET @Busqueda = NULLIF(LTRIM(RTRIM(@Busqueda)), '');

    DECLARE @PatronBusqueda VARCHAR(306) = NULL;
    IF @Busqueda IS NOT NULL
    BEGIN
        SET @PatronBusqueda =
            '%' +
            REPLACE(
                REPLACE(
                    REPLACE(@Busqueda, '\', '\\'),
                    '%',
                    '\%'),
                '_',
                '\_') +
            '%';
    END;

    SELECT
        C.IdCotizacion,
        C.FechaCotizacion
    INTO #CotizacionesFiltradas
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    WHERE (@Estado IS NULL OR C.Estado = @Estado)
      AND
      (
          @PatronBusqueda IS NULL
          OR C.NumeroSeguimiento LIKE @PatronBusqueda ESCAPE '\'
          OR C.Descripcion LIKE @PatronBusqueda ESCAPE '\'
          OR C.Preferencias LIKE @PatronBusqueda ESCAPE '\'
          OR C.Respuesta LIKE @PatronBusqueda ESCAPE '\'
          OR CL.Nombre LIKE @PatronBusqueda ESCAPE '\'
          OR CL.Apellido LIKE @PatronBusqueda ESCAPE '\'
          OR CL.Correo LIKE @PatronBusqueda ESCAPE '\'
          OR EXISTS
          (
              SELECT 1
              FROM dbo.SolicitudCotizacionProductos S
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = S.IdProducto
              WHERE S.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
          OR EXISTS
          (
              SELECT 1
              FROM dbo.DetalleCotizacion D
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = D.IdProducto
              WHERE D.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
      );

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesFiltradas_Id
        ON #CotizacionesFiltradas (IdCotizacion);

    SELECT F.IdCotizacion
    INTO #CotizacionesPagina
    FROM #CotizacionesFiltradas F
    ORDER BY F.FechaCotizacion DESC, F.IdCotizacion DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesPagina_Id
        ON #CotizacionesPagina (IdCotizacion);

    SELECT
        C.IdCotizacion,
        ISNULL(
            C.NumeroSeguimiento,
            CONCAT(
                'COT-',
                RIGHT(
                    REPLICATE('0', 10) +
                    CONVERT(VARCHAR(10), C.IdCotizacion),
                    10))) AS NumeroSeguimiento,
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

    SELECT
        H.IdCotizacion,
        H.EstadoAnterior,
        H.EstadoNuevo,
        H.FechaCambio
    FROM dbo.CotizacionEstadoHistorial H
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = H.IdCotizacion
    ORDER BY
        H.IdCotizacion,
        H.FechaCambio,
        H.IdCotizacionEstadoHistorial;

    SELECT COUNT(*) AS TotalItems
    FROM #CotizacionesFiltradas;
END;
GO

PRINT 'Quotation search, filters and status history installed.';
GO

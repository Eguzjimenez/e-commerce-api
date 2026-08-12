-- Historial de cotizaciones ya gestionadas (respondidas, aceptadas, aprobadas y rechazadas).
-- Fecha: 2026-08-12
-- Base de datos: ConcreInnovaDB
--
-- Agrega el filtro opcional @SoloGestionadas a los listados de cotizaciones.
-- El valor por defecto (0) conserva exactamente el comportamiento actual.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Cotizaciones')
      AND name = 'IX_Cotizaciones_EstadoFecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Cotizaciones_EstadoFecha
        ON dbo.Cotizaciones
        (
            Estado,
            FechaCotizacion DESC,
            IdCotizacion DESC
        )
        INCLUDE (IdCliente, NumeroSeguimiento, Total, FechaRespuesta);
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerMisCotizaciones
(
    @IdUsuario INT,
    @Pagina INT = 1,
    @TamanoPagina INT = 10,
    @Estado VARCHAR(30) = NULL,
    @Busqueda VARCHAR(100) = NULL,
    @SoloGestionadas BIT = 0
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
    SET @SoloGestionadas = ISNULL(@SoloGestionadas, 0);

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
      AND (@SoloGestionadas = 0 OR ISNULL(C.Estado, 'Pendiente') <> 'Pendiente')
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
    @Busqueda VARCHAR(100) = NULL,
    @SoloGestionadas BIT = 0
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
    SET @SoloGestionadas = ISNULL(@SoloGestionadas, 0);

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
      AND (@SoloGestionadas = 0 OR ISNULL(C.Estado, 'Pendiente') <> 'Pendiente')
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

PRINT 'Filtro de cotizaciones gestionadas instalado.';
GO

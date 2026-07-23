-- Sprint 3: quotation response, customer history, acceptance and rejection.
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
    ALTER TABLE dbo.Cotizaciones ADD Descripcion VARCHAR(1000) NULL;
END;
GO

IF COL_LENGTH('dbo.Cotizaciones', 'Respuesta') IS NULL
BEGIN
    ALTER TABLE dbo.Cotizaciones ADD Respuesta VARCHAR(1000) NULL;
END;
GO

IF COL_LENGTH('dbo.Cotizaciones', 'FechaRespuesta') IS NULL
BEGIN
    ALTER TABLE dbo.Cotizaciones ADD FechaRespuesta DATETIME NULL;
END;
GO

IF COL_LENGTH('dbo.Pedidos', 'IdCotizacion') IS NULL
BEGIN
    ALTER TABLE dbo.Pedidos ADD IdCotizacion INT NULL;
END;
GO

IF OBJECT_ID('dbo.CotizacionImagenes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CotizacionImagenes
    (
        IdCotizacionImagen INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_CotizacionImagenes PRIMARY KEY,
        IdCotizacion INT NOT NULL,
        RutaArchivo VARCHAR(500) NOT NULL,
        NombreOriginal VARCHAR(255) NOT NULL,
        TipoContenido VARCHAR(100) NOT NULL,
        TamanoBytes BIGINT NOT NULL,
        FechaCarga DATETIME NOT NULL
            CONSTRAINT DF_CotizacionImagenes_FechaCarga DEFAULT GETDATE(),
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
    FROM sys.foreign_keys
    WHERE parent_object_id = OBJECT_ID('dbo.Pedidos')
      AND name = 'FK_Pedidos_Cotizaciones'
)
BEGIN
    ALTER TABLE dbo.Pedidos WITH CHECK
        ADD CONSTRAINT FK_Pedidos_Cotizaciones
        FOREIGN KEY (IdCotizacion)
        REFERENCES dbo.Cotizaciones (IdCotizacion);
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Pedidos')
      AND name = 'UX_Pedidos_IdCotizacion'
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_Pedidos_IdCotizacion
        ON dbo.Pedidos (IdCotizacion)
        WHERE IdCotizacion IS NOT NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Cotizaciones')
      AND name = 'IX_Cotizaciones_IdCliente_FechaCotizacion'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Cotizaciones_IdCliente_FechaCotizacion
        ON dbo.Cotizaciones (IdCliente, FechaCotizacion DESC)
        INCLUDE (Estado, Total);
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.DetalleCotizacion')
      AND name = 'IX_DetalleCotizacion_IdCotizacion'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_DetalleCotizacion_IdCotizacion
        ON dbo.DetalleCotizacion (IdCotizacion);
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

IF TYPE_ID('dbo.TVP_CotizacionProducto') IS NULL
BEGIN
    EXEC
    (
        'CREATE TYPE dbo.TVP_CotizacionProducto AS TABLE
        (
            IdProducto INT NOT NULL,
            Cantidad INT NOT NULL,
            PrecioUnitario DECIMAL(10,2) NOT NULL
        );'
    );
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

    SELECT
        C.IdCotizacion
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
        C.IdCliente,
        CONCAT(CL.Nombre, ' ', CL.Apellido) AS Cliente,
        ISNULL(C.FechaCotizacion, GETDATE()) AS FechaSolicitud,
        ISNULL(C.Estado, 'Pendiente') AS Estado,
        C.Total,
        ISNULL(C.Descripcion, '') AS Descripcion,
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
        C.IdCliente,
        CONCAT(CL.Nombre, ' ', CL.Apellido) AS Cliente,
        ISNULL(C.FechaCotizacion, GETDATE()) AS FechaSolicitud,
        ISNULL(C.Estado, 'Pendiente') AS Estado,
        C.Total,
        ISNULL(C.Descripcion, '') AS Descripcion,
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

CREATE OR ALTER PROCEDURE dbo.SP_ResponderCotizacion
(
    @IdCotizacion INT,
    @Respuesta VARCHAR(1000),
    @Productos dbo.TVP_CotizacionProducto READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);

        SELECT @Estado = C.Estado
        FROM dbo.Cotizaciones C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.IdCotizacion = @IdCotizacion;

        IF @Estado IS NULL
        BEGIN
            THROW 50001, 'COTIZACION_NO_EXISTE', 1;
        END;

        IF @Estado NOT IN ('Pendiente', 'Respondida')
        BEGIN
            THROW 50002, 'COTIZACION_ESTADO_INVALIDO', 1;
        END;

        IF NULLIF(LTRIM(RTRIM(@Respuesta)), '') IS NULL
        BEGIN
            THROW 50003, 'RESPUESTA_REQUERIDA', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @Productos)
        BEGIN
            THROW 50004, 'PRODUCTOS_REQUERIDOS', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @Productos Q
            LEFT JOIN dbo.Productos P
                ON P.IdProducto = Q.IdProducto
               AND P.Estado = 'Activo'
            WHERE P.IdProducto IS NULL
               OR Q.Cantidad <= 0
               OR Q.PrecioUnitario <= 0
        )
        BEGIN
            THROW 50005, 'PRODUCTO_NO_DISPONIBLE', 1;
        END;

        SELECT
            @Total = SUM(
                CONVERT(DECIMAL(18,2), Q.Cantidad * Q.PrecioUnitario))
        FROM @Productos Q;

        DELETE FROM dbo.DetalleCotizacion
        WHERE IdCotizacion = @IdCotizacion;

        INSERT dbo.DetalleCotizacion
        (
            IdCotizacion,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT
            @IdCotizacion,
            Q.IdProducto,
            Q.Cantidad,
            Q.PrecioUnitario,
            CONVERT(DECIMAL(18,2), Q.Cantidad * Q.PrecioUnitario)
        FROM @Productos Q;

        UPDATE dbo.Cotizaciones
        SET
            Respuesta = LTRIM(RTRIM(@Respuesta)),
            FechaRespuesta = GETDATE(),
            Estado = 'Respondida',
            Total = @Total
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'Cotizacion respondida correctamente.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            'Respondida' AS Estado,
            @Total AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            '' AS Estado,
            CAST(0 AS DECIMAL(18,2)) AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_DecidirCotizacion
(
    @IdUsuario INT,
    @IdCotizacion INT,
    @Aceptar BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @IdCliente INT;
        DECLARE @Estado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);
        DECLARE @IdPedido INT = NULL;
        DECLARE @DireccionEntrega VARCHAR(255);

        SELECT
            @IdCliente = C.IdCliente,
            @Estado = C.Estado,
            @Total = C.Total,
            @DireccionEntrega = ISNULL(
                NULLIF(LTRIM(RTRIM(CL.Direccion)), ''),
                'Pendiente de confirmar')
        FROM dbo.Cotizaciones C WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.Clientes CL
            ON CL.IdCliente = C.IdCliente
        INNER JOIN dbo.Usuarios U
            ON U.IdUsuario = CL.IdUsuario
           AND U.Estado = 'Activo'
        WHERE C.IdCotizacion = @IdCotizacion
          AND CL.IdUsuario = @IdUsuario;

        IF @IdCliente IS NULL
        BEGIN
            THROW 50011, 'COTIZACION_NO_PERTENECE_AL_USUARIO', 1;
        END;

        IF @Estado <> 'Respondida'
        BEGIN
            THROW 50012, 'COTIZACION_ESTADO_INVALIDO', 1;
        END;

        IF @Aceptar = 0
        BEGIN
            UPDATE dbo.Cotizaciones
            SET Estado = 'Rechazada'
            WHERE IdCotizacion = @IdCotizacion;

            COMMIT TRANSACTION;

            SELECT
                1 AS Exitoso,
                'Cotizacion rechazada correctamente.' AS Mensaje,
                @IdCotizacion AS IdCotizacion,
                'Rechazada' AS Estado,
                @Total AS Total,
                CAST(NULL AS INT) AS IdPedido;
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.DetalleCotizacion
            WHERE IdCotizacion = @IdCotizacion
        )
        BEGIN
            THROW 50013, 'COTIZACION_SIN_PRODUCTOS', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.DetalleCotizacion D
            LEFT JOIN dbo.Productos P WITH (UPDLOCK, HOLDLOCK)
                ON P.IdProducto = D.IdProducto
            WHERE D.IdCotizacion = @IdCotizacion
              AND
              (
                  P.IdProducto IS NULL
                  OR P.Estado <> 'Activo'
                  OR P.Stock < D.Cantidad
              )
        )
        BEGIN
            THROW 50014, 'STOCK_INSUFICIENTE', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Pedidos
            WHERE IdCotizacion = @IdCotizacion
        )
        BEGIN
            THROW 50015, 'COTIZACION_YA_PROCESADA', 1;
        END;

        SELECT @Total = SUM(D.Subtotal)
        FROM dbo.DetalleCotizacion D
        WHERE D.IdCotizacion = @IdCotizacion;

        INSERT dbo.Pedidos
        (
            IdCliente,
            FechaPedido,
            Estado,
            DireccionEntrega,
            Total,
            IdCotizacion
        )
        VALUES
        (
            @IdCliente,
            GETDATE(),
            'Pendiente',
            @DireccionEntrega,
            @Total,
            @IdCotizacion
        );

        SET @IdPedido = SCOPE_IDENTITY();

        INSERT dbo.DetallePedido
        (
            IdPedido,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT
            @IdPedido,
            D.IdProducto,
            D.Cantidad,
            D.PrecioUnitario,
            D.Subtotal
        FROM dbo.DetalleCotizacion D
        WHERE D.IdCotizacion = @IdCotizacion;

        UPDATE P
        SET P.Stock = P.Stock - D.Cantidad
        FROM dbo.Productos P
        INNER JOIN dbo.DetalleCotizacion D
            ON D.IdProducto = P.IdProducto
        WHERE D.IdCotizacion = @IdCotizacion;

        UPDATE dbo.Cotizaciones
        SET
            Estado = 'Aceptada',
            Total = @Total
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'Cotizacion aceptada y pedido creado correctamente.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            'Aceptada' AS Estado,
            @Total AS Total,
            @IdPedido AS IdPedido;

        SELECT
            D.IdProducto,
            P.Nombre,
            P.Imagen,
            D.Cantidad,
            D.PrecioUnitario,
            D.Subtotal
        FROM dbo.DetalleCotizacion D
        INNER JOIN dbo.Productos P
            ON P.IdProducto = D.IdProducto
        WHERE D.IdCotizacion = @IdCotizacion
        ORDER BY D.IdDetalleCotizacion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            '' AS Estado,
            CAST(0 AS DECIMAL(18,2)) AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END CATCH;
END;
GO

PRINT 'Quotation history and decision flow installed.';
GO

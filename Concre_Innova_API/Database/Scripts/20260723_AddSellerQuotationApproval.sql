-- Sprint 3: seller approval/rejection and explicit order conversion.
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

-- Quotations processed by the previous workflow already have a formal order.
-- They are migrated to the equivalent final approval state without notifying
-- the customer again.
IF EXISTS
(
    SELECT 1
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Pedidos P
        ON P.IdCotizacion = C.IdCotizacion
    WHERE C.Estado = 'Aceptada'
)
BEGIN
    DECLARE @CotizacionesMigradas TABLE
    (
        IdCotizacion INT NOT NULL PRIMARY KEY
    );

    INSERT @CotizacionesMigradas (IdCotizacion)
    SELECT C.IdCotizacion
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Pedidos P
        ON P.IdCotizacion = C.IdCotizacion
    WHERE C.Estado = 'Aceptada';

    DISABLE TRIGGER dbo.TR_Cotizaciones_RegistrarCambioEstado
        ON dbo.Cotizaciones;

    BEGIN TRY
        UPDATE C
        SET C.Estado = 'Aprobada'
        FROM dbo.Cotizaciones C
        INNER JOIN @CotizacionesMigradas M
            ON M.IdCotizacion = C.IdCotizacion;

        INSERT dbo.CotizacionEstadoHistorial
        (
            IdCotizacion,
            EstadoAnterior,
            EstadoNuevo,
            FechaCambio
        )
        SELECT
            M.IdCotizacion,
            'Aceptada',
            'Aprobada',
            SYSDATETIME()
        FROM @CotizacionesMigradas M;

        ENABLE TRIGGER dbo.TR_Cotizaciones_RegistrarCambioEstado
            ON dbo.Cotizaciones;
    END TRY
    BEGIN CATCH
        ENABLE TRIGGER dbo.TR_Cotizaciones_RegistrarCambioEstado
            ON dbo.Cotizaciones;
        THROW;
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
        DECLARE @NuevoEstado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);

        SELECT
            @IdCliente = C.IdCliente,
            @Estado = C.Estado,
            @Total = C.Total
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

        IF @Aceptar = 1
           AND NOT EXISTS
           (
               SELECT 1
               FROM dbo.DetalleCotizacion
               WHERE IdCotizacion = @IdCotizacion
           )
        BEGIN
            THROW 50013, 'COTIZACION_SIN_PRODUCTOS', 1;
        END;

        SET @NuevoEstado =
            CASE WHEN @Aceptar = 1 THEN 'Aceptada' ELSE 'Rechazada' END;

        UPDATE dbo.Cotizaciones
        SET Estado = @NuevoEstado
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            CASE
                WHEN @Aceptar = 1
                    THEN 'Cotizacion aceptada y enviada a revision de ventas.'
                ELSE 'Cotizacion rechazada correctamente.'
            END AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            @NuevoEstado AS Estado,
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

CREATE OR ALTER PROCEDURE dbo.SP_ResolverCotizacionVendedor
(
    @IdCotizacion INT,
    @Aprobar BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado VARCHAR(30);
        DECLARE @NuevoEstado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);

        SELECT
            @Estado = C.Estado,
            @Total = C.Total
        FROM dbo.Cotizaciones C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.IdCotizacion = @IdCotizacion;

        IF @Estado IS NULL
        BEGIN
            THROW 50021, 'COTIZACION_NO_EXISTE', 1;
        END;

        IF @Estado <> 'Aceptada'
        BEGIN
            THROW 50022, 'COTIZACION_REQUIERE_ACEPTACION', 1;
        END;

        IF @Aprobar = 1
           AND NOT EXISTS
           (
               SELECT 1
               FROM dbo.DetalleCotizacion
               WHERE IdCotizacion = @IdCotizacion
           )
        BEGIN
            THROW 50023, 'COTIZACION_SIN_PRODUCTOS', 1;
        END;

        SET @NuevoEstado =
            CASE WHEN @Aprobar = 1 THEN 'Aprobada' ELSE 'Rechazada' END;

        UPDATE dbo.Cotizaciones
        SET Estado = @NuevoEstado
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            CASE
                WHEN @Aprobar = 1
                    THEN 'Cotizacion aprobada por ventas.'
                ELSE 'Cotizacion rechazada por ventas.'
            END AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            @NuevoEstado AS Estado,
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

CREATE OR ALTER PROCEDURE dbo.SP_ConvertirCotizacionEnPedido
(
    @IdCotizacion INT
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
        DECLARE @IdPedido INT;
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
        WHERE C.IdCotizacion = @IdCotizacion;

        IF @IdCliente IS NULL
        BEGIN
            THROW 50031, 'COTIZACION_NO_EXISTE', 1;
        END;

        IF @Estado <> 'Aprobada'
        BEGIN
            THROW 50032, 'COTIZACION_NO_APROBADA', 1;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.DetalleCotizacion
            WHERE IdCotizacion = @IdCotizacion
        )
        BEGIN
            THROW 50033, 'COTIZACION_SIN_PRODUCTOS', 1;
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
            THROW 50034, 'STOCK_INSUFICIENTE', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Pedidos
            WHERE IdCotizacion = @IdCotizacion
        )
        BEGIN
            THROW 50035, 'COTIZACION_YA_PROCESADA', 1;
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
        SET Total = @Total
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'Cotizacion convertida en pedido correctamente.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            'Aprobada' AS Estado,
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

PRINT 'Seller quotation approval and order conversion installed.';
GO

-- Keeps quoted-order reservations and regular purchases on one stock balance.
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

-- Productos.Stock is the source of truth. Inventario remains synchronized for
-- compatibility with older administrative queries.
UPDATE I
SET
    I.CantidadDisponible = ISNULL(P.Stock, 0),
    I.FechaActualizacion = GETDATE()
FROM dbo.Inventario I
INNER JOIN dbo.Productos P
    ON P.IdProducto = I.IdProducto
WHERE I.CantidadDisponible <> ISNULL(P.Stock, 0);
GO

CREATE OR ALTER TRIGGER dbo.TR_Productos_SincronizarInventarioStock
ON dbo.Productos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(Stock)
    BEGIN
        RETURN;
    END;

    UPDATE I
    SET
        I.CantidadDisponible = ISNULL(N.Stock, 0),
        I.FechaActualizacion = GETDATE()
    FROM dbo.Inventario I
    INNER JOIN inserted N
        ON N.IdProducto = I.IdProducto
    WHERE I.CantidadDisponible <> ISNULL(N.Stock, 0);
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
        DECLARE @ProductosEsperados INT;

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

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Pedidos
            WHERE IdCotizacion = @IdCotizacion
        )
        BEGIN
            THROW 50035, 'COTIZACION_YA_PROCESADA', 1;
        END;

        SELECT
            D.IdProducto,
            SUM(D.Cantidad) AS Cantidad
        INTO #ProductosReservados
        FROM dbo.DetalleCotizacion D
        WHERE D.IdCotizacion = @IdCotizacion
        GROUP BY D.IdProducto;

        IF NOT EXISTS (SELECT 1 FROM #ProductosReservados)
        BEGIN
            THROW 50033, 'COTIZACION_SIN_PRODUCTOS', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM #ProductosReservados
            WHERE Cantidad <= 0
        )
        BEGIN
            THROW 50036, 'CANTIDAD_INVALIDA', 1;
        END;

        SELECT @ProductosEsperados = COUNT(*)
        FROM #ProductosReservados;

        UPDATE P WITH (UPDLOCK, HOLDLOCK)
        SET P.Stock = P.Stock - R.Cantidad
        FROM dbo.Productos P
        INNER JOIN #ProductosReservados R
            ON R.IdProducto = P.IdProducto
        WHERE P.Estado = 'Activo'
          AND ISNULL(P.Stock, 0) >= R.Cantidad;

        IF @@ROWCOUNT <> @ProductosEsperados
        BEGIN
            THROW 50034, 'STOCK_INSUFICIENTE', 1;
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

        SET @IdPedido = CONVERT(INT, SCOPE_IDENTITY());

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
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

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

CREATE OR ALTER PROCEDURE dbo.SP_RegistrarPedido
(
    @IdUsuario INT,
    @DireccionEntrega VARCHAR(255),
    @MetodoPago VARCHAR(50),
    @Carrito dbo.TVP_PedidoItem READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCliente INT;
    DECLARE @IdPedido INT;
    DECLARE @Total DECIMAL(10,2);
    DECLARE @ProductosEsperados INT;
    DECLARE @VariantesEsperadas INT;

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

        IF NOT EXISTS (SELECT 1 FROM @Carrito)
        BEGIN
            THROW 50002, 'CARRITO_VACIO', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @Carrito
            WHERE IdProducto <= 0
               OR Cantidad <= 0
        )
        BEGIN
            THROW 50003, 'ITEM_INVALIDO', 1;
        END;

        SELECT
            C.IdProducto,
            C.IdVariante,
            SUM(C.Cantidad) AS Cantidad,
            MAX(NULLIF(C.NombreVariante, '')) AS NombreVariante,
            MAX(NULLIF(C.Tamano, '')) AS Tamano,
            MAX(NULLIF(C.Material, '')) AS Material,
            MAX(NULLIF(C.Color, '')) AS Color
        INTO #ItemsPedido
        FROM @Carrito C
        GROUP BY
            C.IdProducto,
            C.IdVariante;

        SELECT
            I.IdProducto,
            SUM(I.Cantidad) AS Cantidad
        INTO #ProductosRequeridos
        FROM #ItemsPedido I
        GROUP BY I.IdProducto;

        SELECT
            I.IdProducto,
            I.IdVariante,
            SUM(I.Cantidad) AS Cantidad
        INTO #VariantesRequeridas
        FROM #ItemsPedido I
        WHERE I.IdVariante IS NOT NULL
        GROUP BY
            I.IdProducto,
            I.IdVariante;

        SELECT
            @ProductosEsperados = COUNT(*)
        FROM #ProductosRequeridos;

        SELECT
            @VariantesEsperadas = COUNT(*)
        FROM #VariantesRequeridas;

        SELECT TOP (1)
            @IdCliente = IdCliente
        FROM dbo.Clientes
        WHERE IdUsuario = @IdUsuario
          AND ISNULL(Estado, 'Activo') = 'Activo'
        ORDER BY IdCliente DESC;

        IF @IdCliente IS NULL
        BEGIN
            INSERT dbo.Clientes
            (
                IdUsuario,
                Nombre,
                Apellido,
                Correo,
                Telefono,
                Direccion,
                Estado,
                FechaRegistro
            )
            SELECT
                IdUsuario,
                Nombre,
                Apellido,
                Correo,
                Telefono,
                @DireccionEntrega,
                'Activo',
                GETDATE()
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario;

            SET @IdCliente = CONVERT(INT, SCOPE_IDENTITY());
        END;

        SELECT
            @Total = SUM(COALESCE(V.Precio, P.Precio) * I.Cantidad)
        FROM #ItemsPedido I
        INNER JOIN dbo.Productos P
            ON P.IdProducto = I.IdProducto
        LEFT JOIN dbo.ProductoVariantes V
            ON V.IdVariante = I.IdVariante
           AND V.IdProducto = I.IdProducto
           AND V.Estado = 'Activo'
        WHERE P.Estado = 'Activo';

        IF @Total IS NULL
        BEGIN
            THROW 50004, 'STOCK_INSUFICIENTE', 1;
        END;

        UPDATE P WITH (UPDLOCK, HOLDLOCK)
        SET P.Stock = P.Stock - R.Cantidad
        FROM dbo.Productos P
        INNER JOIN #ProductosRequeridos R
            ON R.IdProducto = P.IdProducto
        WHERE P.Estado = 'Activo'
          AND ISNULL(P.Stock, 0) >= R.Cantidad;

        IF @@ROWCOUNT <> @ProductosEsperados
        BEGIN
            THROW 50004, 'STOCK_INSUFICIENTE', 1;
        END;

        UPDATE V WITH (UPDLOCK, HOLDLOCK)
        SET V.Stock = V.Stock - R.Cantidad
        FROM dbo.ProductoVariantes V
        INNER JOIN #VariantesRequeridas R
            ON R.IdVariante = V.IdVariante
           AND R.IdProducto = V.IdProducto
        WHERE V.Estado = 'Activo'
          AND V.Stock >= R.Cantidad;

        IF @@ROWCOUNT <> @VariantesEsperadas
        BEGIN
            THROW 50004, 'STOCK_INSUFICIENTE', 1;
        END;

        INSERT dbo.Pedidos
        (
            IdCliente,
            FechaPedido,
            Estado,
            DireccionEntrega,
            Total
        )
        VALUES
        (
            @IdCliente,
            GETDATE(),
            'Pendiente',
            @DireccionEntrega,
            @Total
        );

        SET @IdPedido = CONVERT(INT, SCOPE_IDENTITY());

        INSERT dbo.DetallePedido
        (
            IdPedido,
            IdProducto,
            IdVariante,
            NombreVariante,
            Tamano,
            Material,
            Color,
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT
            @IdPedido,
            I.IdProducto,
            I.IdVariante,
            COALESCE(V.NombreVariante, I.NombreVariante),
            COALESCE(V.Tamano, I.Tamano, P.Tamano),
            COALESCE(V.Material, I.Material, P.Material),
            I.Color,
            I.Cantidad,
            COALESCE(V.Precio, P.Precio),
            COALESCE(V.Precio, P.Precio) * I.Cantidad
        FROM #ItemsPedido I
        INNER JOIN dbo.Productos P
            ON P.IdProducto = I.IdProducto
        LEFT JOIN dbo.ProductoVariantes V
            ON V.IdVariante = I.IdVariante
           AND V.IdProducto = I.IdProducto;

        INSERT dbo.Ventas
        (
            IdPedido,
            FechaVenta,
            MetodoPago,
            EstadoPago,
            Total
        )
        VALUES
        (
            @IdPedido,
            GETDATE(),
            @MetodoPago,
            'Pendiente',
            @Total
        );

        INSERT dbo.Bitacora
        (
            IdUsuario,
            TablaAfectada,
            Operacion,
            Descripcion,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            'Pedidos',
            'INSERT',
            CONCAT(
                'Pedido #',
                @IdPedido,
                ' creado. Cliente: ',
                @IdCliente,
                '. Metodo de pago: ',
                @MetodoPago,
                '.'),
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'PEDIDO_REGISTRADO' AS Mensaje,
            @IdPedido AS IdPedido,
            @IdCliente AS IdCliente,
            @Total AS Total;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_CancelarPedido
(
    @IdPedido INT,
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @EstadoActual VARCHAR(50);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @EstadoActual = Estado
        FROM dbo.Pedidos WITH (UPDLOCK, HOLDLOCK)
        WHERE IdPedido = @IdPedido;

        IF @EstadoActual IS NULL
        BEGIN
            THROW 51004, 'PEDIDO_NO_ENCONTRADO', 1;
        END;

        IF @EstadoActual IN ('Cancelado', 'Entregado')
        BEGIN
            THROW 51005, 'PEDIDO_NO_CANCELABLE', 1;
        END;

        SELECT
            IdProducto,
            SUM(Cantidad) AS Cantidad
        INTO #ProductosDevueltos
        FROM dbo.DetallePedido
        WHERE IdPedido = @IdPedido
        GROUP BY IdProducto;

        SELECT
            IdVariante,
            SUM(Cantidad) AS Cantidad
        INTO #VariantesDevueltas
        FROM dbo.DetallePedido
        WHERE IdPedido = @IdPedido
          AND IdVariante IS NOT NULL
        GROUP BY IdVariante;

        UPDATE P
        SET P.Stock = ISNULL(P.Stock, 0) + D.Cantidad
        FROM dbo.Productos P
        INNER JOIN #ProductosDevueltos D
            ON D.IdProducto = P.IdProducto;

        UPDATE V
        SET V.Stock = V.Stock + D.Cantidad
        FROM dbo.ProductoVariantes V
        INNER JOIN #VariantesDevueltas D
            ON D.IdVariante = V.IdVariante;

        UPDATE dbo.Pedidos
        SET Estado = 'Cancelado'
        WHERE IdPedido = @IdPedido;

        INSERT dbo.Bitacora
        (
            IdUsuario,
            TablaAfectada,
            Operacion,
            Descripcion,
            FechaHora
        )
        VALUES
        (
            @IdUsuario,
            'Pedidos',
            'CANCEL',
            CONCAT(
                'Pedido #',
                @IdPedido,
                ' cancelado. Estado previo: "',
                @EstadoActual,
                '".'),
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'PEDIDO_CANCELADO' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH;
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
        SUM(C.Cantidad) AS Cantidad
    INTO #ProductosCarrito
    FROM #ItemsCarrito C
    GROUP BY C.IdProducto;

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
            WHEN ISNULL(P.Stock, 0) < ISNULL(V.Stock, 0)
                THEN ISNULL(P.Stock, 0)
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
            WHEN ISNULL(P.Estado, 'Activo') <> 'Activo'
                THEN 'PRODUCTO_NO_DISPONIBLE'
            WHEN C.IdVariante IS NOT NULL AND V.IdVariante IS NULL
                THEN 'VARIANTE_NO_EXISTE'
            WHEN C.IdVariante IS NOT NULL AND V.Estado <> 'Activo'
                THEN 'VARIANTE_NO_DISPONIBLE'
            WHEN ISNULL(P.Stock, 0) <= 0 THEN 'SIN_STOCK'
            WHEN ISNULL(P.Stock, 0) < T.Cantidad THEN 'STOCK_INSUFICIENTE'
            WHEN C.IdVariante IS NOT NULL AND ISNULL(V.Stock, 0) <= 0
                THEN 'SIN_STOCK'
            WHEN C.IdVariante IS NOT NULL AND ISNULL(V.Stock, 0) < C.Cantidad
                THEN 'STOCK_INSUFICIENTE'
            ELSE 'DISPONIBLE'
        END AS Estado
    FROM #ItemsCarrito C
    INNER JOIN #ProductosCarrito T
        ON T.IdProducto = C.IdProducto
    LEFT JOIN dbo.Productos P
        ON P.IdProducto = C.IdProducto
    LEFT JOIN dbo.ProductoVariantes V
        ON V.IdVariante = C.IdVariante
       AND V.IdProducto = C.IdProducto;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerCatalogoProductos
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            P.IdProducto,
            P.Nombre,
            P.Descripcion,
            P.Precio,
            P.Imagen,
            C.IdCategoria,
            C.NombreCategoria,
            ISNULL(P.Stock, 0) AS Stock,
            CASE
                WHEN ISNULL(P.Stock, 0) > 10 THEN 'Disponible'
                WHEN ISNULL(P.Stock, 0) > 0
                    THEN CONCAT(ISNULL(P.Stock, 0), ' unidades')
                ELSE 'Agotado'
            END AS Disponibilidad
        FROM dbo.Productos P
        INNER JOIN dbo.Categorias C
            ON P.IdCategoria = C.IdCategoria
        WHERE P.Estado = 'Activo'
        ORDER BY P.Nombre;
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END;
GO

PRINT 'Reserva de stock para cotizaciones y pedidos instalada correctamente.';
GO

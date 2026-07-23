-- Historial de pedidos: filtros por fecha, atributos comprados y recompra.
-- Fecha: 2026-07-23
-- Base de datos: ConcreInnovaDB

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

IF COL_LENGTH('DetallePedido', 'IdVariante') IS NULL
BEGIN
    ALTER TABLE DetallePedido ADD IdVariante INT NULL;
END
GO

IF COL_LENGTH('DetallePedido', 'NombreVariante') IS NULL
BEGIN
    ALTER TABLE DetallePedido ADD NombreVariante VARCHAR(120) NULL;
END
GO

IF COL_LENGTH('DetallePedido', 'Tamano') IS NULL
BEGIN
    ALTER TABLE DetallePedido ADD Tamano VARCHAR(80) NULL;
END
GO

IF COL_LENGTH('DetallePedido', 'Material') IS NULL
BEGIN
    ALTER TABLE DetallePedido ADD Material VARCHAR(80) NULL;
END
GO

IF COL_LENGTH('DetallePedido', 'Color') IS NULL
BEGIN
    ALTER TABLE DetallePedido ADD Color VARCHAR(80) NULL;
END
GO

UPDATE DP
SET
    DP.Tamano = COALESCE(NULLIF(DP.Tamano, ''), P.Tamano),
    DP.Material = COALESCE(NULLIF(DP.Material, ''), P.Material)
FROM DetallePedido DP
INNER JOIN Productos P
    ON P.IdProducto = DP.IdProducto
WHERE
    DP.Tamano IS NULL
    OR DP.Tamano = ''
    OR DP.Material IS NULL
    OR DP.Material = '';
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Pedidos_IdCliente_FechaPedido'
      AND object_id = OBJECT_ID('Pedidos')
)
BEGIN
    CREATE INDEX IX_Pedidos_IdCliente_FechaPedido
        ON Pedidos (IdCliente, FechaPedido DESC)
        INCLUDE (Estado, DireccionEntrega, Total);
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_DetallePedido_IdVariante'
      AND object_id = OBJECT_ID('DetallePedido')
)
BEGIN
    CREATE INDEX IX_DetallePedido_IdVariante
        ON DetallePedido (IdVariante)
        WHERE IdVariante IS NOT NULL;
END
GO

IF TYPE_ID(N'dbo.TVP_PedidoItem') IS NULL
BEGIN
    EXEC
    (
        N'CREATE TYPE dbo.TVP_PedidoItem AS TABLE
        (
            IdProducto INT NOT NULL,
            IdVariante INT NULL,
            Cantidad INT NOT NULL,
            NombreVariante VARCHAR(120) NULL,
            Tamano VARCHAR(80) NULL,
            Material VARCHAR(80) NULL,
            Color VARCHAR(80) NULL
        );'
    );
END
GO

CREATE OR ALTER PROCEDURE SP_ValidarStockCarrito
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
        CASE
            WHEN C.IdVariante IS NULL THEN P.Nombre
            ELSE CONCAT(P.Nombre, ' - ', V.NombreVariante)
        END AS Nombre,
        C.Cantidad AS CantidadSolicitada,
        CASE
            WHEN C.IdVariante IS NULL THEN ISNULL(P.Stock, 0)
            ELSE ISNULL(V.Stock, 0)
        END AS StockDisponible,
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
    LEFT JOIN Productos P
        ON P.IdProducto = C.IdProducto
    LEFT JOIN ProductoVariantes V
        ON V.IdVariante = C.IdVariante
       AND V.IdProducto = C.IdProducto;
END
GO

CREATE OR ALTER PROCEDURE SP_RegistrarPedido
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

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Usuarios
            WHERE IdUsuario = @IdUsuario
              AND Estado = 'Activo'
        )
        BEGIN
            THROW 50001, 'USUARIO_NO_EXISTE', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM @Carrito)
        BEGIN
            THROW 50002, 'CARRITO_VACIO', 1;
        END

        IF EXISTS
        (
            SELECT 1
            FROM @Carrito
            WHERE IdProducto <= 0
               OR Cantidad <= 0
        )
        BEGIN
            THROW 50003, 'ITEM_INVALIDO', 1;
        END

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

        SELECT TOP (1)
            @IdCliente = IdCliente
        FROM Clientes
        WHERE IdUsuario = @IdUsuario
          AND ISNULL(Estado, 'Activo') = 'Activo'
        ORDER BY IdCliente DESC;

        IF @IdCliente IS NULL
        BEGIN
            INSERT INTO Clientes
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
            FROM Usuarios
            WHERE IdUsuario = @IdUsuario;

            SET @IdCliente = CONVERT(INT, SCOPE_IDENTITY());
        END

        IF EXISTS
        (
            SELECT 1
            FROM #ItemsPedido I
            LEFT JOIN Productos P
                ON P.IdProducto = I.IdProducto
            LEFT JOIN ProductoVariantes V
                ON V.IdVariante = I.IdVariante
               AND V.IdProducto = I.IdProducto
            WHERE
                P.IdProducto IS NULL
                OR ISNULL(P.Estado, 'Activo') <> 'Activo'
                OR ISNULL(P.Stock, 0) < I.Cantidad
                OR
                (
                    I.IdVariante IS NOT NULL
                    AND
                    (
                        V.IdVariante IS NULL
                        OR V.Estado <> 'Activo'
                        OR ISNULL(V.Stock, 0) < I.Cantidad
                    )
                )
        )
        BEGIN
            THROW 50004, 'STOCK_INSUFICIENTE', 1;
        END

        SELECT
            @Total = SUM(COALESCE(V.Precio, P.Precio) * I.Cantidad)
        FROM #ItemsPedido I
        INNER JOIN Productos P
            ON P.IdProducto = I.IdProducto
        LEFT JOIN ProductoVariantes V
            ON V.IdVariante = I.IdVariante
           AND V.IdProducto = I.IdProducto;

        INSERT INTO Pedidos
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

        INSERT INTO DetallePedido
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
        INNER JOIN Productos P
            ON P.IdProducto = I.IdProducto
        LEFT JOIN ProductoVariantes V
            ON V.IdVariante = I.IdVariante
           AND V.IdProducto = I.IdProducto;

        UPDATE P
        SET P.Stock = P.Stock - S.Cantidad
        FROM Productos P
        INNER JOIN
        (
            SELECT IdProducto, SUM(Cantidad) AS Cantidad
            FROM #ItemsPedido
            GROUP BY IdProducto
        ) S
            ON S.IdProducto = P.IdProducto;

        UPDATE V
        SET V.Stock = V.Stock - S.Cantidad
        FROM ProductoVariantes V
        INNER JOIN
        (
            SELECT IdVariante, SUM(Cantidad) AS Cantidad
            FROM #ItemsPedido
            WHERE IdVariante IS NOT NULL
            GROUP BY IdVariante
        ) S
            ON S.IdVariante = V.IdVariante;

        INSERT INTO Ventas
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

        INSERT INTO Bitacora
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
                '.'
            ),
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
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE SP_ObtenerMisPedidos
(
    @IdUsuario INT,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Usuarios
        WHERE IdUsuario = @IdUsuario
          AND Estado = 'Activo'
    )
    BEGIN
        SELECT
            0 AS Exitoso,
            'USUARIO_NO_EXISTE' AS Mensaje;

        RETURN;
    END

    SELECT
        P.IdPedido,
        P.FechaPedido,
        ISNULL(P.Estado, 'Pendiente') AS Estado,
        ISNULL(P.DireccionEntrega, '') AS DireccionEntrega,
        ISNULL(V.MetodoPago, '') AS MetodoPago,
        ISNULL(V.EstadoPago, '') AS EstadoPago,
        P.Total,
        DP.IdDetallePedido,
        DP.IdProducto,
        DP.IdVariante,
        COALESCE(PR.Nombre, CONCAT('Producto #', DP.IdProducto)) AS Nombre,
        ISNULL(DP.NombreVariante, '') AS NombreVariante,
        COALESCE(NULLIF(DP.Tamano, ''), PR.Tamano, '') AS Tamano,
        COALESCE(NULLIF(DP.Material, ''), PR.Material, '') AS Material,
        ISNULL(DP.Color, '') AS Color,
        ISNULL(PV.Imagen, PR.Imagen) AS Imagen,
        DP.Cantidad,
        DP.PrecioUnitario,
        DP.Subtotal
    FROM Pedidos P
    INNER JOIN Clientes C
        ON C.IdCliente = P.IdCliente
       AND C.IdUsuario = @IdUsuario
    INNER JOIN DetallePedido DP
        ON P.IdPedido = DP.IdPedido
    LEFT JOIN Productos PR
        ON DP.IdProducto = PR.IdProducto
    LEFT JOIN ProductoVariantes PV
        ON PV.IdVariante = DP.IdVariante
       AND PV.IdProducto = DP.IdProducto
    OUTER APPLY
    (
        SELECT TOP (1)
            VE.MetodoPago,
            VE.EstadoPago
        FROM Ventas VE
        WHERE VE.IdPedido = P.IdPedido
        ORDER BY VE.IdVenta DESC
    ) V
    WHERE
        (@FechaDesde IS NULL OR P.FechaPedido >= @FechaDesde)
        AND
        (
            @FechaHasta IS NULL
            OR P.FechaPedido < DATEADD(DAY, 1, @FechaHasta)
        )
    ORDER BY
        P.FechaPedido DESC,
        P.IdPedido DESC,
        DP.IdDetallePedido ASC;
END
GO

CREATE OR ALTER PROCEDURE SP_PrepararRecompraPedido
(
    @IdUsuario INT,
    @IdPedido INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Usuarios
        WHERE IdUsuario = @IdUsuario
          AND Estado = 'Activo'
    )
    BEGIN
        SELECT
            0 AS Exitoso,
            'USUARIO_NO_EXISTE' AS Mensaje;

        RETURN;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM Pedidos P
        INNER JOIN Clientes C
            ON C.IdCliente = P.IdCliente
        WHERE P.IdPedido = @IdPedido
          AND C.IdUsuario = @IdUsuario
    )
    BEGIN
        SELECT
            0 AS Exitoso,
            'PEDIDO_NO_ENCONTRADO' AS Mensaje;

        RETURN;
    END

    SELECT
        DP.IdProducto,
        DP.IdVariante,
        COALESCE(P.Nombre, CONCAT('Producto #', DP.IdProducto)) AS Nombre,
        ISNULL(CONVERT(VARCHAR(MAX), P.Descripcion), '') AS Descripcion,
        COALESCE(V.Precio, P.Precio, DP.PrecioUnitario) AS Precio,
        ISNULL(V.Imagen, P.Imagen) AS Imagen,
        COALESCE(NULLIF(DP.NombreVariante, ''), V.NombreVariante, '') AS NombreVariante,
        COALESCE(NULLIF(DP.Tamano, ''), V.Tamano, P.Tamano, '') AS Tamano,
        COALESCE(NULLIF(DP.Material, ''), V.Material, P.Material, '') AS Material,
        ISNULL(DP.Color, '') AS Color,
        DP.Cantidad,
        CAST
        (
            CASE
                WHEN P.IdProducto IS NULL THEN 0
                WHEN ISNULL(P.Estado, 'Activo') <> 'Activo' THEN 0
                WHEN ISNULL(P.Stock, 0) < DP.Cantidad THEN 0
                WHEN DP.IdVariante IS NOT NULL AND V.IdVariante IS NULL THEN 0
                WHEN DP.IdVariante IS NOT NULL AND V.Estado <> 'Activo' THEN 0
                WHEN DP.IdVariante IS NOT NULL AND V.Stock < DP.Cantidad THEN 0
                ELSE 1
            END
            AS BIT
        ) AS Disponible,
        CASE
            WHEN P.IdProducto IS NULL THEN 'El producto ya no existe.'
            WHEN ISNULL(P.Estado, 'Activo') <> 'Activo' THEN 'El producto no esta activo.'
            WHEN ISNULL(P.Stock, 0) < DP.Cantidad THEN 'No hay stock suficiente.'
            WHEN DP.IdVariante IS NOT NULL AND V.IdVariante IS NULL THEN 'La variante ya no existe.'
            WHEN DP.IdVariante IS NOT NULL AND V.Estado <> 'Activo' THEN 'La variante no esta activa.'
            WHEN DP.IdVariante IS NOT NULL AND V.Stock < DP.Cantidad THEN 'No hay stock suficiente para la variante.'
            ELSE ''
        END AS MotivoNoDisponible
    FROM DetallePedido DP
    LEFT JOIN Productos P
        ON P.IdProducto = DP.IdProducto
    LEFT JOIN ProductoVariantes V
        ON V.IdVariante = DP.IdVariante
       AND V.IdProducto = DP.IdProducto
    WHERE DP.IdPedido = @IdPedido
    ORDER BY DP.IdDetallePedido;
END
GO

PRINT 'Historial, filtros, estados y recompra de pedidos actualizados.';
GO

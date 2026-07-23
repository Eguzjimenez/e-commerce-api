-- Script para relacionar Clientes con Usuarios y actualizar pedidos.
-- Fecha: 2026-07-23
-- Descripcion: agrega Clientes.IdUsuario, migra datos por correo y actualiza los SP de pedidos.

IF COL_LENGTH('Clientes', 'IdUsuario') IS NULL
BEGIN
    ALTER TABLE Clientes ADD IdUsuario INT NULL;
END
GO

UPDATE C
SET C.IdUsuario = U.IdUsuario
FROM Clientes C
INNER JOIN Usuarios U
    ON U.Correo = C.Correo
WHERE C.IdUsuario IS NULL;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Clientes_Usuarios_IdUsuario'
)
BEGIN
    ALTER TABLE Clientes
    ADD CONSTRAINT FK_Clientes_Usuarios_IdUsuario
        FOREIGN KEY (IdUsuario) REFERENCES Usuarios (IdUsuario);
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Clientes_IdUsuario'
      AND object_id = OBJECT_ID('Clientes')
)
BEGIN
    CREATE INDEX IX_Clientes_IdUsuario
        ON Clientes (IdUsuario)
        WHERE IdUsuario IS NOT NULL;
END
GO

CREATE OR ALTER PROCEDURE SP_RegistrarPedido
(
    @IdUsuario INT,
    @DireccionEntrega VARCHAR(255),
    @MetodoPago VARCHAR(50),
    @Carrito TVP_Carrito READONLY
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
            RAISERROR('USUARIO_NO_EXISTE', 16, 1);
        END

        IF NOT EXISTS (SELECT 1 FROM @Carrito)
        BEGIN
            RAISERROR('CARRITO_VACIO', 16, 1);
        END

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
            FROM @Carrito C
            LEFT JOIN Productos P
                ON P.IdProducto = C.IdProducto
            WHERE
                P.IdProducto IS NULL
                OR C.Cantidad <= 0
                OR ISNULL(P.Stock, 0) < C.Cantidad
                OR ISNULL(P.Estado, 'Activo') <> 'Activo'
        )
        BEGIN
            RAISERROR('STOCK_INSUFICIENTE', 16, 1);
        END

        SELECT
            @Total = SUM(P.Precio * C.Cantidad)
        FROM @Carrito C
        INNER JOIN Productos P
            ON P.IdProducto = C.IdProducto;

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
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT
            @IdPedido,
            C.IdProducto,
            C.Cantidad,
            P.Precio,
            P.Precio * C.Cantidad
        FROM @Carrito C
        INNER JOIN Productos P
            ON P.IdProducto = C.IdProducto;

        UPDATE P
        SET P.Stock = P.Stock - C.Cantidad
        FROM Productos P
        INNER JOIN @Carrito C
            ON P.IdProducto = C.IdProducto;

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
            CONCAT('Pedido #', @IdPedido, ' creado. Cliente: ', @IdCliente, '. Metodo de pago: ', @MetodoPago, '.'),
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
END;
GO

CREATE OR ALTER PROCEDURE SP_ObtenerMisPedidos
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdCliente INT;

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

    SELECT TOP (1)
        @IdCliente = IdCliente
    FROM Clientes
    WHERE IdUsuario = @IdUsuario
      AND ISNULL(Estado, 'Activo') = 'Activo'
    ORDER BY IdCliente DESC;

    IF @IdCliente IS NULL
    BEGIN
        SELECT
            CAST(NULL AS INT) AS IdPedido,
            CAST(NULL AS DATETIME) AS FechaPedido,
            CAST(NULL AS VARCHAR(50)) AS Estado,
            CAST(NULL AS VARCHAR(255)) AS DireccionEntrega,
            CAST(NULL AS VARCHAR(50)) AS MetodoPago,
            CAST(NULL AS VARCHAR(50)) AS EstadoPago,
            CAST(NULL AS DECIMAL(10,2)) AS Total,
            CAST(NULL AS INT) AS IdDetallePedido,
            CAST(NULL AS INT) AS IdProducto,
            CAST(NULL AS VARCHAR(150)) AS Nombre,
            CAST(NULL AS VARCHAR(255)) AS Imagen,
            CAST(NULL AS INT) AS Cantidad,
            CAST(NULL AS DECIMAL(10,2)) AS PrecioUnitario,
            CAST(NULL AS DECIMAL(10,2)) AS Subtotal
        WHERE 1 = 0;

        RETURN;
    END

    SELECT
        P.IdPedido,
        P.FechaPedido,
        P.Estado,
        P.DireccionEntrega,
        ISNULL(V.MetodoPago, '') AS MetodoPago,
        ISNULL(V.EstadoPago, '') AS EstadoPago,
        P.Total,
        DP.IdDetallePedido,
        DP.IdProducto,
        PR.Nombre,
        PR.Imagen,
        DP.Cantidad,
        DP.PrecioUnitario,
        DP.Subtotal
    FROM Pedidos P
    INNER JOIN DetallePedido DP
        ON P.IdPedido = DP.IdPedido
    INNER JOIN Productos PR
        ON DP.IdProducto = PR.IdProducto
    LEFT JOIN Ventas V
        ON V.IdPedido = P.IdPedido
    WHERE P.IdCliente = @IdCliente
    ORDER BY
        P.FechaPedido DESC,
        DP.IdDetallePedido ASC;
END
GO

PRINT 'Clientes.IdUsuario y SP de pedidos actualizados.';
GO

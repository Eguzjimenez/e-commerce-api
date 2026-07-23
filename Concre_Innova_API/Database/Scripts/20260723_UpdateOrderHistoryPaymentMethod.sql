-- Script para actualizar el historial de pedidos con metodo de pago.
-- Fecha: 2026-07-23
-- Descripcion: asegura que SP_ObtenerMisPedidos devuelva MetodoPago y EstadoPago.

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
        @IdCliente = C.IdCliente
    FROM Clientes C
    WHERE C.IdUsuario = @IdUsuario
      AND ISNULL(C.Estado, 'Activo') = 'Activo'
    ORDER BY C.IdCliente DESC;

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

PRINT 'SP_ObtenerMisPedidos actualizado con metodo de pago.';
GO

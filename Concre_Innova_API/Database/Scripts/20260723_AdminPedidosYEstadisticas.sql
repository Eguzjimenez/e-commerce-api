-- Gestion administrativa de pedidos y estadisticas del negocio.
-- Fecha: 2026-07-23
-- Base de datos: ConcreInnovaDB

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

DECLARE @Permisos TABLE (
    Codigo VARCHAR(120),
    Nombre VARCHAR(120),
    Modulo VARCHAR(80),
    Descripcion VARCHAR(255)
);

INSERT INTO @Permisos (Codigo, Nombre, Modulo, Descripcion)
VALUES
('pedidos.ver', 'Ver pedidos', 'Pedidos', 'Consultar listado y detalle de pedidos.'),
('pedidos.actualizar', 'Actualizar estado de pedidos', 'Pedidos', 'Cambiar el estado de un pedido.'),
('pedidos.cancelar', 'Cancelar pedidos', 'Pedidos', 'Cancelar pedidos y restaurar el stock.'),
('estadisticas.ver', 'Ver estadisticas', 'Estadisticas', 'Consultar estadisticas del negocio.');

INSERT INTO Permisos (Codigo, Nombre, Modulo, Descripcion)
SELECT p.Codigo, p.Nombre, p.Modulo, p.Descripcion
FROM @Permisos p
WHERE NOT EXISTS (
    SELECT 1 FROM Permisos existing WHERE existing.Codigo = p.Codigo
);
GO

INSERT INTO RolPermisos (IdRol, IdPermiso)
SELECT 1, p.IdPermiso
FROM Permisos p
WHERE p.Codigo IN ('pedidos.ver', 'pedidos.actualizar', 'pedidos.cancelar', 'estadisticas.ver')
    AND NOT EXISTS (
        SELECT 1
        FROM RolPermisos rp
        WHERE rp.IdRol = 1
            AND rp.IdPermiso = p.IdPermiso
    );
GO

CREATE OR ALTER PROCEDURE SP_ObtenerPedidosAdmin
(
    @Busqueda NVARCHAR(150) = NULL,
    @Estado VARCHAR(50) = NULL,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL,
    @Pagina INT = 1,
    @TamanoPagina INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BusquedaNormalizada NVARCHAR(150) = NULLIF(LTRIM(RTRIM(@Busqueda)), '');
    DECLARE @BusquedaPattern NVARCHAR(160) = NULL;
    DECLARE @PaginaValida INT = CASE WHEN ISNULL(@Pagina, 1) < 1 THEN 1 ELSE @Pagina END;
    DECLARE @TamanoPaginaValido INT = CASE WHEN ISNULL(@TamanoPagina, 10) < 1 THEN 10 ELSE @TamanoPagina END;
    DECLARE @Offset INT = (@PaginaValida - 1) * @TamanoPaginaValido;

    IF @BusquedaNormalizada IS NOT NULL
    BEGIN
        SET @BusquedaPattern =
            '%' +
            REPLACE(REPLACE(REPLACE(REPLACE(@BusquedaNormalizada, '\', '\\'), '%', '\%'), '_', '\_'), '[', '\[') +
            '%';
    END

    SELECT
        P.IdPedido,
        P.FechaPedido,
        P.Estado,
        P.DireccionEntrega,
        P.Total,
        C.IdCliente,
        LTRIM(RTRIM(CONCAT(ISNULL(C.Nombre, ''), ' ', ISNULL(C.Apellido, '')))) AS NombreCliente,
        ISNULL(C.Correo, '') AS CorreoCliente,
        ISNULL(V.MetodoPago, '') AS MetodoPago,
        COUNT(1) OVER() AS TotalItems
    FROM Pedidos P
    INNER JOIN Clientes C
        ON C.IdCliente = P.IdCliente
    OUTER APPLY
    (
        SELECT TOP (1) VE.MetodoPago
        FROM Ventas VE
        WHERE VE.IdPedido = P.IdPedido
        ORDER BY VE.IdVenta DESC
    ) V
    WHERE
        (
            @BusquedaPattern IS NULL
            OR CAST(P.IdPedido AS VARCHAR(20)) LIKE @BusquedaPattern ESCAPE '\'
            OR LTRIM(RTRIM(CONCAT(ISNULL(C.Nombre, ''), ' ', ISNULL(C.Apellido, '')))) COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
            OR ISNULL(C.Correo, '') COLLATE Latin1_General_CI_AI LIKE @BusquedaPattern ESCAPE '\'
        )
        AND (@Estado IS NULL OR P.Estado = @Estado)
        AND (@FechaDesde IS NULL OR P.FechaPedido >= @FechaDesde)
        AND (@FechaHasta IS NULL OR P.FechaPedido < DATEADD(DAY, 1, @FechaHasta))
    ORDER BY
        P.FechaPedido DESC,
        P.IdPedido DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPaginaValido ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE SP_ObtenerPedidoAdminDetalle
(
    @IdPedido INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.IdPedido,
        P.FechaPedido,
        P.Estado,
        P.DireccionEntrega,
        P.Total,
        C.IdCliente,
        LTRIM(RTRIM(CONCAT(ISNULL(C.Nombre, ''), ' ', ISNULL(C.Apellido, '')))) AS NombreCliente,
        ISNULL(C.Correo, '') AS CorreoCliente,
        ISNULL(C.Telefono, '') AS TelefonoCliente,
        ISNULL(V.MetodoPago, '') AS MetodoPago,
        ISNULL(V.EstadoPago, '') AS EstadoPago
    FROM Pedidos P
    INNER JOIN Clientes C
        ON C.IdCliente = P.IdCliente
    OUTER APPLY
    (
        SELECT TOP (1) VE.MetodoPago, VE.EstadoPago
        FROM Ventas VE
        WHERE VE.IdPedido = P.IdPedido
        ORDER BY VE.IdVenta DESC
    ) V
    WHERE P.IdPedido = @IdPedido;

    SELECT
        DP.IdDetallePedido,
        DP.IdProducto,
        DP.IdVariante,
        COALESCE(PR.Nombre, CONCAT('Producto #', DP.IdProducto)) AS Nombre,
        ISNULL(DP.NombreVariante, '') AS NombreVariante,
        ISNULL(PR.Imagen, '') AS Imagen,
        DP.Cantidad,
        DP.PrecioUnitario,
        DP.Subtotal
    FROM DetallePedido DP
    LEFT JOIN Productos PR
        ON PR.IdProducto = DP.IdProducto
    WHERE DP.IdPedido = @IdPedido
    ORDER BY DP.IdDetallePedido;
END
GO

CREATE OR ALTER PROCEDURE SP_ActualizarEstadoPedido
(
    @IdPedido INT,
    @NuevoEstado VARCHAR(50),
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
        FROM Pedidos WITH (UPDLOCK, ROWLOCK)
        WHERE IdPedido = @IdPedido;

        IF @EstadoActual IS NULL
        BEGIN
            THROW 51001, 'PEDIDO_NO_ENCONTRADO', 1;
        END

        IF @EstadoActual IN ('Cancelado', 'Entregado')
        BEGIN
            THROW 51002, 'PEDIDO_NO_MODIFICABLE', 1;
        END

        IF @NuevoEstado NOT IN ('Pendiente', 'En proceso', 'Enviado', 'Entregado')
        BEGIN
            THROW 51003, 'ESTADO_INVALIDO', 1;
        END

        UPDATE Pedidos
        SET Estado = @NuevoEstado
        WHERE IdPedido = @IdPedido;

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
            'UPDATE',
            CONCAT('Pedido #', @IdPedido, ' actualizado de "', @EstadoActual, '" a "', @NuevoEstado, '".'),
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'ESTADO_ACTUALIZADO' AS Mensaje;
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

CREATE OR ALTER PROCEDURE SP_CancelarPedido
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
        FROM Pedidos WITH (UPDLOCK, ROWLOCK)
        WHERE IdPedido = @IdPedido;

        IF @EstadoActual IS NULL
        BEGIN
            THROW 51004, 'PEDIDO_NO_ENCONTRADO', 1;
        END

        IF @EstadoActual IN ('Cancelado', 'Entregado')
        BEGIN
            THROW 51005, 'PEDIDO_NO_CANCELABLE', 1;
        END

        UPDATE PR
        SET PR.Stock = PR.Stock + S.Cantidad
        FROM Productos PR
        INNER JOIN
        (
            SELECT IdProducto, SUM(Cantidad) AS Cantidad
            FROM DetallePedido
            WHERE IdPedido = @IdPedido
                AND IdVariante IS NULL
            GROUP BY IdProducto
        ) S
            ON S.IdProducto = PR.IdProducto;

        UPDATE V
        SET V.Stock = V.Stock + S.Cantidad
        FROM ProductoVariantes V
        INNER JOIN
        (
            SELECT IdVariante, SUM(Cantidad) AS Cantidad
            FROM DetallePedido
            WHERE IdPedido = @IdPedido
                AND IdVariante IS NOT NULL
            GROUP BY IdVariante
        ) S
            ON S.IdVariante = V.IdVariante;

        UPDATE Pedidos
        SET Estado = 'Cancelado'
        WHERE IdPedido = @IdPedido;

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
            'CANCEL',
            CONCAT('Pedido #', @IdPedido, ' cancelado. Estado previo: "', @EstadoActual, '".'),
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'PEDIDO_CANCELADO' AS Mensaje;
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

CREATE OR ALTER PROCEDURE SP_EstadisticasResumenNegocio
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InicioMesActual DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
    DECLARE @InicioMesAnterior DATE = DATEADD(MONTH, -1, @InicioMesActual);

    DECLARE @VentasMesActual DECIMAL(12, 2) = ISNULL(
        (
            SELECT SUM(Total)
            FROM Pedidos
            WHERE FechaPedido >= @InicioMesActual
                AND FechaPedido < DATEADD(MONTH, 1, @InicioMesActual)
                AND Estado <> 'Cancelado'
        ), 0);

    DECLARE @VentasMesAnterior DECIMAL(12, 2) = ISNULL(
        (
            SELECT SUM(Total)
            FROM Pedidos
            WHERE FechaPedido >= @InicioMesAnterior
                AND FechaPedido < @InicioMesActual
                AND Estado <> 'Cancelado'
        ), 0);

    DECLARE @VariacionPorcentaje DECIMAL(10, 2) =
        CASE
            WHEN @VentasMesAnterior > 0
                THEN ((@VentasMesActual - @VentasMesAnterior) / @VentasMesAnterior) * 100
            ELSE 0
        END;

    DECLARE @ProductoDestacado VARCHAR(150) = (
        SELECT TOP (1) PR.Nombre
        FROM DetallePedido DP
        INNER JOIN Pedidos P
            ON P.IdPedido = DP.IdPedido
        INNER JOIN Productos PR
            ON PR.IdProducto = DP.IdProducto
        WHERE P.Estado <> 'Cancelado'
        GROUP BY PR.Nombre
        ORDER BY SUM(DP.Cantidad) DESC
    );

    DECLARE @ClientesFrecuentes INT = (
        SELECT COUNT(1)
        FROM
        (
            SELECT IdCliente
            FROM Pedidos
            WHERE Estado <> 'Cancelado'
            GROUP BY IdCliente
            HAVING COUNT(1) > 1
        ) Frecuentes
    );

    SELECT
        @VentasMesActual AS VentasMesActual,
        @VariacionPorcentaje AS VariacionMesAnteriorPorcentaje,
        ISNULL(@ProductoDestacado, '') AS ProductoDestacado,
        @ClientesFrecuentes AS ClientesFrecuentes;
END
GO

CREATE OR ALTER PROCEDURE SP_EstadisticasClientesFrecuentes
(
    @Top INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
        C.IdCliente,
        LTRIM(RTRIM(CONCAT(ISNULL(C.Nombre, ''), ' ', ISNULL(C.Apellido, '')))) AS NombreCliente,
        COUNT(1) AS CantidadPedidos,
        SUM(P.Total) AS TotalComprado
    FROM Pedidos P
    INNER JOIN Clientes C
        ON C.IdCliente = P.IdCliente
    WHERE P.Estado <> 'Cancelado'
    GROUP BY C.IdCliente, C.Nombre, C.Apellido
    HAVING COUNT(1) > 1
    ORDER BY COUNT(1) DESC, SUM(P.Total) DESC;
END
GO

CREATE OR ALTER PROCEDURE SP_EstadisticasPorCategoria
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH VentasPorCategoria AS
    (
        SELECT
            ISNULL(CAT.NombreCategoria, 'Sin categoria') AS NombreCategoria,
            SUM(DP.Subtotal) AS TotalVendido
        FROM DetallePedido DP
        INNER JOIN Pedidos P
            ON P.IdPedido = DP.IdPedido
        INNER JOIN Productos PR
            ON PR.IdProducto = DP.IdProducto
        LEFT JOIN Categorias CAT
            ON CAT.IdCategoria = PR.IdCategoria
        WHERE P.Estado <> 'Cancelado'
        GROUP BY CAT.NombreCategoria
    )
    SELECT
        NombreCategoria,
        TotalVendido,
        CASE
            WHEN SUM(TotalVendido) OVER() > 0
                THEN (TotalVendido / SUM(TotalVendido) OVER()) * 100
            ELSE 0
        END AS PorcentajeDelTotal
    FROM VentasPorCategoria
    ORDER BY TotalVendido DESC;
END
GO

CREATE OR ALTER PROCEDURE SP_EstadisticasProductosDestacados
(
    @Top INT = 5
)
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH VentasPorProducto AS
    (
        SELECT
            PR.Nombre AS NombreProducto,
            SUM(DP.Cantidad) AS CantidadVendida
        FROM DetallePedido DP
        INNER JOIN Pedidos P
            ON P.IdPedido = DP.IdPedido
        INNER JOIN Productos PR
            ON PR.IdProducto = DP.IdProducto
        WHERE P.Estado <> 'Cancelado'
        GROUP BY PR.Nombre
    )
    SELECT TOP (@Top)
        NombreProducto,
        CantidadVendida,
        CASE
            WHEN MAX(CantidadVendida) OVER() > 0
                THEN (CAST(CantidadVendida AS DECIMAL(10, 2)) / MAX(CantidadVendida) OVER()) * 100
            ELSE 0
        END AS PorcentajeRelativo
    FROM VentasPorProducto
    ORDER BY CantidadVendida DESC;
END
GO

PRINT 'Permisos, procedimientos de gestion de pedidos y estadisticas creados/actualizados.';
GO

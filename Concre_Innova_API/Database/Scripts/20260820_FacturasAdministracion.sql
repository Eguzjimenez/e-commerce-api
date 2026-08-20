/* ===========================================================================
   20260820 - Facturas para administracion

   El administrador veia el pedido pero no si su cobro estaba pagado, pendiente
   o vencido. Este script convierte Ventas en la factura consultable:

   1. Permisos 'facturas.ver' y 'facturas.gestionar' para Administrador.
   2. Ventas.FechaVencimiento y Ventas.Observaciones.
   3. SP_ObtenerFacturasAdmin  : listado paginado con filtros y totales.
   4. SP_ObtenerFacturaDetalle : factura con su pedido, cliente y pagos.
   5. SP_ActualizarEstadoFactura: cambia el estado dejando rastro en Bitacora.

   Idempotente: puede ejecutarse varias veces.
   =========================================================================== */

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

/* 1. Permisos ------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM dbo.Permisos WHERE Codigo = 'facturas.ver')
    INSERT INTO dbo.Permisos (Codigo, Nombre, Descripcion, Modulo, Estado)
    VALUES ('facturas.ver', N'Ver facturas',
            N'Consultar las facturas y su estado de cobro.', N'Facturas', 'Activo');
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Permisos WHERE Codigo = 'facturas.gestionar')
    INSERT INTO dbo.Permisos (Codigo, Nombre, Descripcion, Modulo, Estado)
    VALUES ('facturas.gestionar', N'Gestionar facturas',
            N'Marcar facturas como pagadas, pendientes o en revision.', N'Facturas', 'Activo');
GO

INSERT INTO dbo.RolPermisos (IdRol, IdPermiso)
SELECT R.IdRol, P.IdPermiso
FROM dbo.Roles R
CROSS JOIN dbo.Permisos P
WHERE R.NombreRol = 'Administrador'
  AND P.Codigo IN ('facturas.ver', 'facturas.gestionar')
  AND NOT EXISTS (SELECT 1 FROM dbo.RolPermisos RP
                  WHERE RP.IdRol = R.IdRol AND RP.IdPermiso = P.IdPermiso);
GO

/* 2. Columnas nuevas ------------------------------------------------------ */
IF COL_LENGTH('dbo.Ventas', 'FechaVencimiento') IS NULL
    ALTER TABLE dbo.Ventas ADD FechaVencimiento DATETIME NULL;
GO

IF COL_LENGTH('dbo.Ventas', 'Observaciones') IS NULL
    ALTER TABLE dbo.Ventas ADD Observaciones VARCHAR(400) NULL;
GO

-- Las facturas existentes reciben un plazo de 15 dias desde su emision.
UPDATE dbo.Ventas
SET FechaVencimiento = DATEADD(DAY, 15, FechaVenta)
WHERE FechaVencimiento IS NULL;
GO

/* 3. Listado -------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerFacturasAdmin
(
    @Busqueda     NVARCHAR(120) = NULL,
    @Estado       VARCHAR(30)   = NULL,  -- pagada | pendiente | vencida | revision
    @Desde        DATE          = NULL,
    @Hasta        DATE          = NULL,
    @Pagina       INT           = 1,
    @TamanoPagina INT           = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;
    DECLARE @Filtro NVARCHAR(140) =
        CASE WHEN NULLIF(LTRIM(RTRIM(@Busqueda)), '') IS NULL THEN NULL
             ELSE '%' + LTRIM(RTRIM(@Busqueda)) + '%' END;

    ;WITH Base AS (
        SELECT
            V.IdVenta,
            V.IdPedido,
            V.FechaVenta,
            V.FechaVencimiento,
            V.MetodoPago,
            V.EstadoPago,
            V.Total,
            V.Observaciones,
            P.Estado                        AS EstadoPedido,
            P.IdCliente,
            LTRIM(RTRIM(ISNULL(C.Nombre, '') + ' ' + ISNULL(C.Apellido, ''))) AS Cliente,
            C.Correo                        AS CorreoCliente,
            (SELECT COUNT(1) FROM dbo.Pagos PG WHERE PG.IdVenta = V.IdVenta) AS TotalPagos,
            (SELECT SUM(PG.Monto) FROM dbo.Pagos PG WHERE PG.IdVenta = V.IdVenta) AS MontoPagado
        FROM dbo.Ventas V
        INNER JOIN dbo.Pedidos P  ON P.IdPedido = V.IdPedido
        LEFT  JOIN dbo.Clientes C ON C.IdCliente = P.IdCliente
    ),
    Clasificada AS (
        SELECT
            Base.*,
            CASE
                WHEN EstadoPago = 'Pagada'          THEN 'pagada'
                WHEN EstadoPago = 'En verificacion' THEN 'revision'
                WHEN FechaVencimiento IS NOT NULL
                     AND FechaVencimiento < GETDATE() THEN 'vencida'
                ELSE 'pendiente'
            END AS EstadoFactura,
            DATEDIFF(DAY, GETDATE(), FechaVencimiento) AS DiasParaVencer
        FROM Base
    ),
    Filtrada AS (
        SELECT *
        FROM Clasificada
        WHERE (@Filtro IS NULL
               OR Cliente LIKE @Filtro
               OR CorreoCliente LIKE @Filtro
               OR CAST(IdVenta AS VARCHAR(20)) LIKE @Filtro
               OR CAST(IdPedido AS VARCHAR(20)) LIKE @Filtro)
          AND (NULLIF(@Estado, '') IS NULL OR EstadoFactura = @Estado)
          AND (@Desde IS NULL OR CAST(FechaVenta AS DATE) >= @Desde)
          AND (@Hasta IS NULL OR CAST(FechaVenta AS DATE) <= @Hasta)
    )
    SELECT
        IdVenta, IdPedido, FechaVenta, FechaVencimiento, MetodoPago, EstadoPago,
        Total, Observaciones, EstadoPedido, IdCliente, Cliente, CorreoCliente,
        TotalPagos, ISNULL(MontoPagado, 0) AS MontoPagado,
        EstadoFactura, DiasParaVencer,
        COUNT(1) OVER ()                                       AS TotalItems,
        SUM(CASE WHEN EstadoFactura = 'pagada'    THEN 1 ELSE 0 END) OVER () AS TotalPagadas,
        SUM(CASE WHEN EstadoFactura = 'pendiente' THEN 1 ELSE 0 END) OVER () AS TotalPendientes,
        SUM(CASE WHEN EstadoFactura = 'vencida'   THEN 1 ELSE 0 END) OVER () AS TotalVencidas,
        SUM(CASE WHEN EstadoFactura = 'revision'  THEN 1 ELSE 0 END) OVER () AS TotalEnRevision,
        SUM(CASE WHEN EstadoFactura <> 'pagada' THEN Total ELSE 0 END) OVER () AS MontoPorCobrar
    FROM Filtrada
    ORDER BY
        CASE EstadoFactura
            WHEN 'vencida' THEN 0 WHEN 'revision' THEN 1
            WHEN 'pendiente' THEN 2 ELSE 3 END,
        FechaVenta DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

/* 4. Detalle -------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerFacturaDetalle
(
    @IdVenta INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        V.IdVenta, V.IdPedido, V.FechaVenta, V.FechaVencimiento,
        V.MetodoPago, V.EstadoPago, V.Total, V.Observaciones,
        P.Estado           AS EstadoPedido,
        P.FechaPedido,
        P.DireccionEntrega,
        LTRIM(RTRIM(ISNULL(C.Nombre, '') + ' ' + ISNULL(C.Apellido, ''))) AS Cliente,
        C.Correo           AS CorreoCliente,
        C.Telefono         AS TelefonoCliente,
        CASE
            WHEN V.EstadoPago = 'Pagada'          THEN 'pagada'
            WHEN V.EstadoPago = 'En verificacion' THEN 'revision'
            WHEN V.FechaVencimiento IS NOT NULL
                 AND V.FechaVencimiento < GETDATE() THEN 'vencida'
            ELSE 'pendiente'
        END AS EstadoFactura
    FROM dbo.Ventas V
    INNER JOIN dbo.Pedidos P  ON P.IdPedido = V.IdPedido
    LEFT  JOIN dbo.Clientes C ON C.IdCliente = P.IdCliente
    WHERE V.IdVenta = @IdVenta;

    SELECT
        D.IdDetallePedido AS IdDetalle,
        D.IdProducto,
        ISNULL(PR.Nombre, CONCAT('Producto #', D.IdProducto)) AS NombreProducto,
        D.NombreVariante,
        D.Cantidad,
        D.PrecioUnitario,
        D.Subtotal
    FROM dbo.DetallePedido D
    INNER JOIN dbo.Ventas V     ON V.IdPedido = D.IdPedido
    LEFT  JOIN dbo.Productos PR ON PR.IdProducto = D.IdProducto
    WHERE V.IdVenta = @IdVenta
    ORDER BY D.IdDetallePedido;

    SELECT
        PG.IdPago, PG.Monto, PG.FechaPago, PG.MetodoPago,
        PG.Referencia, PG.ComprobanteArchivo
    FROM dbo.Pagos PG
    WHERE PG.IdVenta = @IdVenta
    ORDER BY PG.FechaPago DESC;
END;
GO

/* 5. Cambio de estado ----------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.SP_ActualizarEstadoFactura
(
    @IdVenta       INT,
    @EstadoPago    VARCHAR(30),
    @Observaciones VARCHAR(400) = NULL,
    @IdUsuario     INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @EstadoPago NOT IN ('Pagada', 'Pendiente', 'En verificacion', 'Anulada')
        BEGIN
            SELECT 0 AS Codigo, 'ESTADO_INVALIDO' AS Mensaje;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.Ventas WHERE IdVenta = @IdVenta)
        BEGIN
            SELECT 0 AS Codigo, 'FACTURA_NO_ENCONTRADA' AS Mensaje;
            RETURN;
        END

        DECLARE @Anterior VARCHAR(30) =
            (SELECT EstadoPago FROM dbo.Ventas WHERE IdVenta = @IdVenta);

        BEGIN TRANSACTION;

        UPDATE dbo.Ventas
        SET EstadoPago    = @EstadoPago,
            Observaciones = NULLIF(LTRIM(RTRIM(ISNULL(@Observaciones, ''))), '')
        WHERE IdVenta = @IdVenta;

        INSERT INTO dbo.Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora)
        VALUES (@IdUsuario, 'Ventas', 'UPDATE',
                CONCAT('Factura #', @IdVenta, ' paso de ', @Anterior, ' a ', @EstadoPago, '.'),
                GETDATE());

        COMMIT TRANSACTION;

        SELECT 1 AS Codigo, 'FACTURA_ACTUALIZADA' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO

PRINT 'Facturas de administracion instaladas.';
GO

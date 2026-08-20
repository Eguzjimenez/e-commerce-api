-- Registro de clientes con apellido y direccion, relacion Usuarios-Clientes
-- consistente, y comprobante de pago para SINPE Movil.
-- Fecha: 2026-08-14
-- Base de datos: ConcreInnovaDB
--
-- Idempotente: puede ejecutarse varias veces sin duplicar datos.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ======================================================
-- 1. Comprobante de pago (SINPE Movil)
-- ======================================================

IF COL_LENGTH('dbo.Pagos', 'ComprobanteArchivo') IS NULL
BEGIN
    ALTER TABLE dbo.Pagos ADD ComprobanteArchivo VARCHAR(255) NULL;
END;
GO

IF COL_LENGTH('dbo.Pagos', 'IdUsuarioRegistro') IS NULL
BEGIN
    ALTER TABLE dbo.Pagos ADD IdUsuarioRegistro INT NULL;

    ALTER TABLE dbo.Pagos
    ADD CONSTRAINT FK_Pagos_UsuarioRegistro
        FOREIGN KEY (IdUsuarioRegistro) REFERENCES dbo.Usuarios (IdUsuario);
END;
GO

-- ======================================================
-- 2. Relacion Usuarios - Clientes
--    Todo usuario con rol Cliente debe tener su ficha, que es donde
--    vive la direccion de entrega que el checkout reconoce sola.
-- ======================================================

INSERT INTO dbo.Clientes (IdUsuario, Nombre, Apellido, Correo, Telefono, Direccion, Estado, FechaRegistro)
SELECT U.IdUsuario, U.Nombre, U.Apellido, U.Correo, U.Telefono, NULL, 'Activo', GETDATE()
FROM dbo.Usuarios U
WHERE U.IdRol = 3
  AND NOT EXISTS (SELECT 1 FROM dbo.Clientes C WHERE C.IdUsuario = U.IdUsuario);
GO

-- Alta de cliente: crea la cuenta y su ficha en una sola transaccion, de modo
-- que la direccion queda asociada desde el primer momento.
CREATE OR ALTER PROCEDURE dbo.SP_RegistrarCliente
(
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Correo VARCHAR(150),
    @Contrasena VARCHAR(255),
    @Telefono VARCHAR(20),
    @Direccion VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.Usuarios WHERE Correo = @Correo)
        BEGIN
            SELECT 0 AS Codigo, 'El correo ya se encuentra registrado.' AS Mensaje,
                   CAST(NULL AS INT) AS IdUsuario;
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @ContrasenaHash VARCHAR(64) =
            CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Contrasena), 2);

        INSERT INTO dbo.Usuarios (Nombre, Apellido, Correo, ContrasenaHash, Telefono, IdRol)
        VALUES (@Nombre, @Apellido, @Correo, @ContrasenaHash, @Telefono, 3);

        DECLARE @IdUsuario INT = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.Clientes
            (IdUsuario, Nombre, Apellido, Correo, Telefono, Direccion, Estado, FechaRegistro)
        VALUES
            (@IdUsuario, @Nombre, @Apellido, @Correo, @Telefono, @Direccion, 'Activo', GETDATE());

        COMMIT TRANSACTION;

        SELECT 1 AS Codigo, 'Cuenta creada correctamente.' AS Mensaje, @IdUsuario AS IdUsuario;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT -1 AS Codigo, ERROR_MESSAGE() AS Mensaje, CAST(NULL AS INT) AS IdUsuario;
    END CATCH
END;
GO

-- Mantiene al dia la direccion del cliente cuando confirma una entrega distinta.
CREATE OR ALTER PROCEDURE dbo.SP_ActualizarDireccionCliente
(
    @IdUsuario INT,
    @Direccion VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE dbo.Clientes
        SET Direccion = @Direccion
        WHERE IdUsuario = @IdUsuario;

        SELECT 1 AS Codigo, 'DIRECCION_ACTUALIZADA' AS Mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO

-- ======================================================
-- 3. Registro del comprobante de pago
-- ======================================================

CREATE OR ALTER PROCEDURE dbo.SP_RegistrarComprobantePago
(
    @IdPedido INT,
    @IdUsuario INT,
    @Referencia VARCHAR(100),
    @ComprobanteArchivo VARCHAR(255) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE @IdVenta INT;
        DECLARE @Monto DECIMAL(18, 2);
        DECLARE @MetodoPago VARCHAR(50);

        SELECT TOP (1)
            @IdVenta = V.IdVenta,
            @Monto = V.Total,
            @MetodoPago = V.MetodoPago
        FROM dbo.Ventas V
        INNER JOIN dbo.Pedidos P ON P.IdPedido = V.IdPedido
        INNER JOIN dbo.Clientes C ON C.IdCliente = P.IdCliente
        WHERE V.IdPedido = @IdPedido
          AND C.IdUsuario = @IdUsuario
        ORDER BY V.IdVenta DESC;

        IF @IdVenta IS NULL
        BEGIN
            SELECT 0 AS Codigo, 'VENTA_NO_ENCONTRADA' AS Mensaje;
            RETURN;
        END

        -- SINPE Movil se liquida por transferencia, asi que el comprobante es
        -- obligatorio. La regla vive aqui para que ningun cliente pueda saltarsela.
        IF @MetodoPago = 'SINPE Movil' AND NULLIF(LTRIM(RTRIM(@ComprobanteArchivo)), '') IS NULL
        BEGIN
            SELECT 0 AS Codigo, 'COMPROBANTE_REQUERIDO' AS Mensaje;
            RETURN;
        END

        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM dbo.Pagos WHERE IdVenta = @IdVenta)
        BEGIN
            UPDATE dbo.Pagos
            SET Referencia = @Referencia,
                ComprobanteArchivo = @ComprobanteArchivo,
                FechaPago = GETDATE(),
                IdUsuarioRegistro = @IdUsuario
            WHERE IdVenta = @IdVenta;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.Pagos
                (IdVenta, Monto, FechaPago, MetodoPago, Referencia, ComprobanteArchivo, IdUsuarioRegistro)
            VALUES
                (@IdVenta, @Monto, GETDATE(), @MetodoPago, @Referencia, @ComprobanteArchivo, @IdUsuario);
        END

        -- El comprobante queda a la espera de que el personal lo verifique.
        UPDATE dbo.Ventas
        SET EstadoPago = 'En verificacion'
        WHERE IdVenta = @IdVenta;

        INSERT INTO dbo.Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora)
        VALUES (@IdUsuario, 'Pagos', 'INSERT',
                CONCAT('Comprobante de pago registrado para el pedido #', @IdPedido, '.'), GETDATE());

        COMMIT TRANSACTION;

        SELECT 1 AS Codigo, 'COMPROBANTE_REGISTRADO' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO

PRINT 'Registro de clientes, direccion y comprobantes de pago instalados.';
GO

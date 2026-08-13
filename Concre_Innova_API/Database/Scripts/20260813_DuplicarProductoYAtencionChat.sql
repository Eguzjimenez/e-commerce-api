-- Duplicacion de productos en estado Borrador y atencion de chats por el personal de ventas.
-- Fecha: 2026-08-13
-- Base de datos: ConcreInnovaDB

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ======================================================
-- PERMISO DE DUPLICACION DE PRODUCTOS
-- Se otorga al Administrador y al Vendedor. El vendedor
-- solo puede duplicar y ajustar los borradores; publicar
-- o eliminar productos sigue requiriendo permisos de
-- administracion del catalogo.
-- ======================================================

INSERT INTO Permisos (Codigo, Nombre, Modulo, Descripcion)
SELECT
    'productos.duplicar',
    'Duplicar productos',
    'Productos',
    'Duplicar un producto existente y ajustar la copia mientras esta en estado Borrador.'
WHERE NOT EXISTS (SELECT 1 FROM Permisos WHERE Codigo = 'productos.duplicar');
GO

INSERT INTO RolPermisos (IdRol, IdPermiso)
SELECT R.IdRol, P.IdPermiso
FROM (VALUES (1), (2)) AS R(IdRol)
CROSS JOIN Permisos P
WHERE P.Codigo = 'productos.duplicar'
    AND NOT EXISTS (
        SELECT 1 FROM RolPermisos RP
        WHERE RP.IdRol = R.IdRol AND RP.IdPermiso = P.IdPermiso
    );
GO

-- ======================================================
-- DUPLICACION DE PRODUCTOS
-- ======================================================

-- Crea una copia del producto indicado, incluyendo inventario y variantes,
-- y la deja en estado Borrador para que no aparezca en el catalogo publico.
CREATE OR ALTER PROCEDURE dbo.SP_DuplicarProducto
(
    @IdProducto INT,
    @IdUsuario INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdProductoCopia INT;
    DECLARE @NombreCopia VARCHAR(150);

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Productos WHERE IdProducto = @IdProducto)
        BEGIN
            SELECT 0 AS Codigo, 'PRODUCTO_NO_EXISTE' AS Mensaje, CAST(NULL AS INT) AS IdProducto;
            RETURN;
        END

        SELECT @NombreCopia = LEFT(CONCAT(Nombre, ' (Copia)'), 150)
        FROM dbo.Productos
        WHERE IdProducto = @IdProducto;

        BEGIN TRANSACTION;

        INSERT INTO dbo.Productos
        (
            Nombre, Descripcion, Precio, Stock, Imagen, Estado,
            FechaRegistro, IdCategoria, Tamano, Material, IdTipo, Caracteristicas
        )
        SELECT
            @NombreCopia,
            Descripcion,
            Precio,
            ISNULL(Stock, 0),
            Imagen,
            'Borrador',
            GETDATE(),
            IdCategoria,
            Tamano,
            Material,
            IdTipo,
            Caracteristicas
        FROM dbo.Productos
        WHERE IdProducto = @IdProducto;

        SET @IdProductoCopia = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.Inventario (IdProducto, CantidadDisponible, CantidadMinima, FechaActualizacion)
        SELECT @IdProductoCopia, I.CantidadDisponible, I.CantidadMinima, GETDATE()
        FROM dbo.Inventario I
        WHERE I.IdProducto = @IdProducto;

        INSERT INTO dbo.ProductoVariantes
        (
            IdProducto, NombreVariante, Tamano, Material, Precio, Stock, Imagen, Estado, FechaRegistro
        )
        SELECT
            @IdProductoCopia,
            V.NombreVariante,
            V.Tamano,
            V.Material,
            V.Precio,
            V.Stock,
            V.Imagen,
            V.Estado,
            GETDATE()
        FROM dbo.ProductoVariantes V
        WHERE V.IdProducto = @IdProducto;

        IF @IdUsuario IS NOT NULL
        BEGIN
            INSERT INTO dbo.Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora)
            VALUES
            (
                @IdUsuario,
                'Productos',
                'DUPLICATE',
                CONCAT('Producto #', @IdProducto, ' duplicado como borrador #', @IdProductoCopia, '.'),
                GETDATE()
            );
        END

        COMMIT TRANSACTION;

        SELECT 1 AS Codigo, 'PRODUCTO_DUPLICADO' AS Mensaje, @IdProductoCopia AS IdProducto;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje, CAST(NULL AS INT) AS IdProducto;
    END CATCH
END;
GO

-- ======================================================
-- ATENCION DE CHATS
-- ======================================================

-- Agrega el conteo de mensajes del cliente pendientes de respuesta.
-- Un mensaje esta pendiente cuando llego despues de la ultima respuesta
-- de soporte y la conversacion sigue abierta.
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerChatsAdmin
(
    @Estado VARCHAR(30) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Estado = NULLIF(LTRIM(RTRIM(@Estado)), '');

    SELECT
        CH.IdChat,
        CH.IdCliente,
        LTRIM(RTRIM(CONCAT(CL.Nombre, ' ', CL.Apellido))) AS Cliente,
        ISNULL(CL.Correo, '') AS CorreoCliente,
        ISNULL(CH.Estado, 'Abierto') AS Estado,
        CH.FechaInicio,
        CH.FechaCierre,
        CH.IdUsuario AS IdUsuarioSoporte,
        ISNULL(U.Ultimo, '') AS UltimoMensaje,
        U.FechaUltimoMensaje,
        ISNULL(U.TotalMensajes, 0) AS TotalMensajes,
        CASE
            WHEN ISNULL(CH.Estado, 'Abierto') = 'Finalizado' THEN 0
            ELSE ISNULL(P.MensajesSinLeer, 0)
        END AS MensajesSinLeer
    FROM dbo.Chats CH
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = CH.IdCliente
    OUTER APPLY
    (
        SELECT
            MAX(M.FechaHora) AS FechaUltimoMensaje,
            COUNT(*) AS TotalMensajes,
            (
                SELECT TOP (1) M2.Mensaje
                FROM dbo.MensajesChat M2
                WHERE M2.IdChat = CH.IdChat
                ORDER BY M2.FechaHora DESC, M2.IdMensaje DESC
            ) AS Ultimo
        FROM dbo.MensajesChat M
        WHERE M.IdChat = CH.IdChat
    ) U
    OUTER APPLY
    (
        SELECT MAX(R.FechaHora) AS UltimaRespuesta
        FROM dbo.MensajesChat R
        WHERE R.IdChat = CH.IdChat AND R.Remitente = 'Soporte'
    ) S
    OUTER APPLY
    (
        SELECT COUNT(1) AS MensajesSinLeer
        FROM dbo.MensajesChat M
        WHERE M.IdChat = CH.IdChat
          AND M.Remitente = 'Cliente'
          AND M.FechaHora > ISNULL(S.UltimaRespuesta, CONVERT(DATETIME, '1900-01-01'))
    ) P
    WHERE (@Estado IS NULL OR ISNULL(CH.Estado, 'Abierto') = @Estado)
    ORDER BY
        CASE WHEN ISNULL(CH.Estado, 'Abierto') = 'Escalado' THEN 0 ELSE 1 END,
        ISNULL(U.FechaUltimoMensaje, CH.FechaInicio) DESC,
        CH.IdChat DESC;
END;
GO

-- Contadores de la bandeja de atencion mostrados en el panel del personal.
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerResumenChatsAdmin
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ConversacionesPendientes AS
    (
        SELECT
            CH.IdChat,
            ISNULL(CH.Estado, 'Abierto') AS Estado,
            (
                SELECT COUNT(1)
                FROM dbo.MensajesChat M
                WHERE M.IdChat = CH.IdChat
                  AND M.Remitente = 'Cliente'
                  AND M.FechaHora > ISNULL
                  (
                      (
                          SELECT MAX(S.FechaHora)
                          FROM dbo.MensajesChat S
                          WHERE S.IdChat = CH.IdChat AND S.Remitente = 'Soporte'
                      ),
                      CONVERT(DATETIME, '1900-01-01')
                  )
            ) AS MensajesSinLeer
        FROM dbo.Chats CH
    )
    SELECT
        ISNULL(SUM(CASE WHEN Estado <> 'Finalizado' THEN 1 ELSE 0 END), 0) AS Activas,
        ISNULL(SUM(CASE WHEN Estado = 'Escalado' THEN 1 ELSE 0 END), 0) AS Escaladas,
        ISNULL(SUM(CASE WHEN Estado = 'Finalizado' THEN 1 ELSE 0 END), 0) AS Finalizadas,
        ISNULL(SUM(CASE WHEN Estado <> 'Finalizado' AND MensajesSinLeer > 0 THEN 1 ELSE 0 END), 0) AS Pendientes
    FROM ConversacionesPendientes;
END;
GO

PRINT 'Duplicacion de productos y atencion de chats instaladas.';
GO

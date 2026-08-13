-- Bandeja de notificaciones del usuario: clasificacion, lectura y consulta paginada.
-- Fecha: 2026-08-13
-- Base de datos: ConcreInnovaDB

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ======================================================
-- COLUMNAS ADICIONALES DE Notificaciones
-- Las columnas se agregan con valor por defecto para que
-- las inserciones existentes sigan funcionando sin cambios.
-- ======================================================

IF COL_LENGTH('dbo.Notificaciones', 'Tipo') IS NULL
BEGIN
    ALTER TABLE dbo.Notificaciones
    ADD Tipo VARCHAR(30) NOT NULL CONSTRAINT DF_Notificaciones_Tipo DEFAULT ('General');
END;
GO

IF COL_LENGTH('dbo.Notificaciones', 'Titulo') IS NULL
BEGIN
    ALTER TABLE dbo.Notificaciones
    ADD Titulo VARCHAR(150) NOT NULL CONSTRAINT DF_Notificaciones_Titulo DEFAULT ('Notificacion');
END;
GO

IF COL_LENGTH('dbo.Notificaciones', 'Enlace') IS NULL
BEGIN
    ALTER TABLE dbo.Notificaciones ADD Enlace VARCHAR(255) NULL;
END;
GO

IF COL_LENGTH('dbo.Notificaciones', 'Referencia') IS NULL
BEGIN
    ALTER TABLE dbo.Notificaciones ADD Referencia INT NULL;
END;
GO

IF COL_LENGTH('dbo.Notificaciones', 'FechaLectura') IS NULL
BEGIN
    ALTER TABLE dbo.Notificaciones ADD FechaLectura DATETIME NULL;
END;
GO

-- Las notificaciones creadas antes de este script correspondian
-- unicamente al escalamiento de chats hacia soporte.
UPDATE dbo.Notificaciones
SET Tipo = 'Chat',
    Titulo = 'Conversacion escalada a soporte'
WHERE Tipo = 'General'
  AND Titulo = 'Notificacion'
  AND Mensaje LIKE 'Nueva conversacion escalada%';
GO

UPDATE dbo.Notificaciones
SET FechaLectura = FechaEnvio
WHERE Leida = 1
  AND FechaLectura IS NULL;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_Notificaciones_Usuario_Fecha'
      AND object_id = OBJECT_ID('dbo.Notificaciones')
)
BEGIN
    CREATE INDEX IX_Notificaciones_Usuario_Fecha
        ON dbo.Notificaciones (IdUsuario, FechaEnvio DESC)
        INCLUDE (Leida);
END;
GO

-- ======================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ======================================================

-- Registra una notificacion para un usuario.
CREATE OR ALTER PROCEDURE dbo.SP_RegistrarNotificacion
(
    @IdUsuario INT,
    @Tipo VARCHAR(30),
    @Titulo VARCHAR(150),
    @Mensaje VARCHAR(500),
    @Enlace VARCHAR(255) = NULL,
    @Referencia INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Usuarios WHERE IdUsuario = @IdUsuario)
        BEGIN
            SELECT 0 AS Codigo, 'USUARIO_NO_EXISTE' AS Mensaje, CAST(NULL AS INT) AS IdNotificacion;
            RETURN;
        END

        INSERT INTO dbo.Notificaciones
            (IdUsuario, Tipo, Titulo, Mensaje, Enlace, Referencia, Leida, FechaEnvio)
        VALUES
            (@IdUsuario, @Tipo, @Titulo, @Mensaje, @Enlace, @Referencia, 0, GETDATE());

        SELECT
            1 AS Codigo,
            'NOTIFICACION_REGISTRADA' AS Mensaje,
            CONVERT(INT, SCOPE_IDENTITY()) AS IdNotificacion;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje, CAST(NULL AS INT) AS IdNotificacion;
    END CATCH
END;
GO

-- Devuelve la pagina solicitada de notificaciones y, en un segundo
-- conjunto de resultados, los totales de la bandeja del usuario.
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerNotificacionesUsuario
(
    @IdUsuario INT,
    @SoloNoLeidas BIT = 0,
    @Pagina INT = 1,
    @TamanoPagina INT = 20
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PaginaValida INT = CASE WHEN ISNULL(@Pagina, 1) < 1 THEN 1 ELSE @Pagina END;
    DECLARE @TamanoValido INT = CASE WHEN ISNULL(@TamanoPagina, 20) < 1 THEN 20 ELSE @TamanoPagina END;
    DECLARE @Offset INT = (@PaginaValida - 1) * @TamanoValido;

    SELECT
        IdNotificacion,
        Tipo,
        Titulo,
        ISNULL(Mensaje, '') AS Mensaje,
        Enlace,
        Referencia,
        Leida,
        FechaEnvio,
        FechaLectura
    FROM dbo.Notificaciones
    WHERE IdUsuario = @IdUsuario
      AND (@SoloNoLeidas = 0 OR Leida = 0)
    ORDER BY FechaEnvio DESC, IdNotificacion DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoValido ROWS ONLY;

    SELECT
        COUNT(1) AS TotalItems,
        ISNULL(SUM(CASE WHEN Leida = 0 THEN 1 ELSE 0 END), 0) AS NoLeidas
    FROM dbo.Notificaciones
    WHERE IdUsuario = @IdUsuario
      AND (@SoloNoLeidas = 0 OR Leida = 0);
END;
GO

-- Resumen liviano usado por el indicador de notificaciones.
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerResumenNotificaciones
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NoLeidas INT =
    (
        SELECT COUNT(1)
        FROM dbo.Notificaciones
        WHERE IdUsuario = @IdUsuario AND Leida = 0
    );

    DECLARE @IdNotificacion INT;
    DECLARE @Tipo VARCHAR(30);
    DECLARE @Titulo VARCHAR(150);
    DECLARE @Mensaje VARCHAR(500);
    DECLARE @Enlace VARCHAR(255);
    DECLARE @Referencia INT;
    DECLARE @FechaEnvio DATETIME;

    SELECT TOP (1)
        @IdNotificacion = IdNotificacion,
        @Tipo = Tipo,
        @Titulo = Titulo,
        @Mensaje = ISNULL(Mensaje, ''),
        @Enlace = Enlace,
        @Referencia = Referencia,
        @FechaEnvio = FechaEnvio
    FROM dbo.Notificaciones
    WHERE IdUsuario = @IdUsuario AND Leida = 0
    ORDER BY FechaEnvio DESC, IdNotificacion DESC;

    SELECT
        @NoLeidas AS NoLeidas,
        @IdNotificacion AS IdNotificacion,
        @Tipo AS Tipo,
        @Titulo AS Titulo,
        @Mensaje AS Mensaje,
        @Enlace AS Enlace,
        @Referencia AS Referencia,
        @FechaEnvio AS FechaEnvio;
END;
GO

-- Marca una notificacion como leida. El filtro por usuario evita
-- que alguien modifique notificaciones de otra cuenta.
CREATE OR ALTER PROCEDURE dbo.SP_MarcarNotificacionLeida
(
    @IdUsuario INT,
    @IdNotificacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE dbo.Notificaciones
        SET Leida = 1,
            FechaLectura = GETDATE()
        WHERE IdNotificacion = @IdNotificacion
          AND IdUsuario = @IdUsuario
          AND Leida = 0;

        DECLARE @Afectadas INT = @@ROWCOUNT;

        IF @Afectadas = 0 AND NOT EXISTS
        (
            SELECT 1 FROM dbo.Notificaciones
            WHERE IdNotificacion = @IdNotificacion AND IdUsuario = @IdUsuario
        )
        BEGIN
            SELECT 0 AS Codigo, 'NOTIFICACION_NO_EXISTE' AS Mensaje, 0 AS NoLeidas;
            RETURN;
        END

        SELECT
            1 AS Codigo,
            'NOTIFICACION_LEIDA' AS Mensaje,
            (
                SELECT COUNT(1)
                FROM dbo.Notificaciones
                WHERE IdUsuario = @IdUsuario AND Leida = 0
            ) AS NoLeidas;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje, 0 AS NoLeidas;
    END CATCH
END;
GO

-- Marca como leidas todas las notificaciones pendientes del usuario.
CREATE OR ALTER PROCEDURE dbo.SP_MarcarNotificacionesLeidas
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        UPDATE dbo.Notificaciones
        SET Leida = 1,
            FechaLectura = GETDATE()
        WHERE IdUsuario = @IdUsuario
          AND Leida = 0;

        SELECT 1 AS Codigo, 'NOTIFICACIONES_LEIDAS' AS Mensaje, 0 AS NoLeidas;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje, 0 AS NoLeidas;
    END CATCH
END;
GO

-- ======================================================
-- ESCALAMIENTO DE CHAT
-- Se conserva el comportamiento anterior y solo se completan
-- los nuevos campos de clasificacion de la notificacion.
-- ======================================================

CREATE OR ALTER PROCEDURE dbo.SP_EscalarChatASoporte
(
    @IdChat INT,
    @MensajeNotificacion NVARCHAR(500)
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdUsuarioSoporte INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM dbo.Chats WHERE IdChat = @IdChat)
        BEGIN
            THROW 51002, 'CHAT_NO_EXISTE', 1;
        END

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Chats
            WHERE IdChat = @IdChat
              AND ISNULL(Estado, 'Abierto') = 'Finalizado'
        )
        BEGIN
            THROW 51003, 'CHAT_FINALIZADO', 1;
        END

        -- Se asigna la persona de soporte con menos conversaciones escaladas.
        -- IdRol = 1 corresponde a Administrador, el rol que atiende el chat.
        SELECT TOP (1)
            @IdUsuarioSoporte = U.IdUsuario
        FROM dbo.Usuarios U
        WHERE U.Estado = 'Activo'
          AND U.IdRol = 1
        ORDER BY
            (
                SELECT COUNT(*)
                FROM dbo.Chats C
                WHERE C.IdUsuario = U.IdUsuario
                  AND ISNULL(C.Estado, 'Abierto') = 'Escalado'
            ) ASC,
            U.IdUsuario ASC;

        UPDATE dbo.Chats
        SET
            Estado = 'Escalado',
            IdUsuario = @IdUsuarioSoporte
        WHERE IdChat = @IdChat;

        IF @IdUsuarioSoporte IS NOT NULL
        BEGIN
            INSERT INTO dbo.Notificaciones
                (IdUsuario, Tipo, Titulo, Mensaje, Enlace, Referencia, Leida, FechaEnvio)
            VALUES
            (
                @IdUsuarioSoporte,
                'Chat',
                'Conversacion escalada a soporte',
                @MensajeNotificacion,
                '/admin/chat',
                @IdChat,
                0,
                GETDATE()
            );
        END

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'CHAT_ESCALADO' AS Mensaje,
            @IdUsuarioSoporte AS IdUsuarioSoporte;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Codigo,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS IdUsuarioSoporte;
    END CATCH
END;
GO

PRINT 'Bandeja de notificaciones de usuario instalada.';
GO

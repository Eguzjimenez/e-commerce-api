-- Correcciones de la auditoria de calidad: matriz de permisos del rol Vendedor
-- y modulo de Consultas (mensajes de contacto) con respuesta trazable.
-- Fecha: 2026-08-13
-- Base de datos: ConcreInnovaDB
-- Debe ejecutarse despues de 20260813_ReportesContenidoYPreferencias.sql.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ======================================================
-- C-01 · El Vendedor no debe tener acceso a Reportes
-- ======================================================

DELETE RP
FROM RolPermisos RP
INNER JOIN Permisos P ON P.IdPermiso = RP.IdPermiso
WHERE RP.IdRol = 2
  AND P.Codigo = 'reportes.ver';
GO

-- ======================================================
-- A-01 y A-02 · El Vendedor gestiona productos y categorias
-- ======================================================

INSERT INTO RolPermisos (IdRol, IdPermiso)
SELECT 2, P.IdPermiso
FROM Permisos P
WHERE P.Codigo IN (
        'productos.crear',
        'productos.actualizar',
        'productos.eliminar',
        'categorias.leer',
        'categorias.crear',
        'categorias.actualizar',
        'categorias.eliminar'
    )
    AND NOT EXISTS (
        SELECT 1 FROM RolPermisos RP
        WHERE RP.IdRol = 2 AND RP.IdPermiso = P.IdPermiso
    );
GO

-- ======================================================
-- A-03 · Modulo de Consultas
-- ======================================================

DECLARE @PermisosConsultas TABLE (
    Codigo VARCHAR(120),
    Nombre VARCHAR(120),
    Modulo VARCHAR(80),
    Descripcion VARCHAR(255)
);

INSERT INTO @PermisosConsultas (Codigo, Nombre, Modulo, Descripcion)
VALUES
('consultas.ver', 'Ver consultas', 'Consultas',
 'Consultar los mensajes de contacto enviados por los clientes.'),
('consultas.responder', 'Responder consultas', 'Consultas',
 'Responder los mensajes de contacto y marcarlos como atendidos.');

INSERT INTO Permisos (Codigo, Nombre, Modulo, Descripcion)
SELECT C.Codigo, C.Nombre, C.Modulo, C.Descripcion
FROM @PermisosConsultas C
WHERE NOT EXISTS (SELECT 1 FROM Permisos P WHERE P.Codigo = C.Codigo);
GO

INSERT INTO RolPermisos (IdRol, IdPermiso)
SELECT R.IdRol, P.IdPermiso
FROM (VALUES (1), (2)) AS R(IdRol)
CROSS JOIN Permisos P
WHERE P.Codigo IN ('consultas.ver', 'consultas.responder')
    AND NOT EXISTS (
        SELECT 1 FROM RolPermisos RP
        WHERE RP.IdRol = R.IdRol AND RP.IdPermiso = P.IdPermiso
    );
GO

-- Columnas de respuesta. Se agregan como nulas para no alterar los registros existentes.
IF COL_LENGTH('dbo.MensajesContacto', 'Respuesta') IS NULL
BEGIN
    ALTER TABLE dbo.MensajesContacto ADD Respuesta VARCHAR(2000) NULL;
END;
GO

IF COL_LENGTH('dbo.MensajesContacto', 'FechaRespuesta') IS NULL
BEGIN
    ALTER TABLE dbo.MensajesContacto ADD FechaRespuesta DATETIME NULL;
END;
GO

IF COL_LENGTH('dbo.MensajesContacto', 'IdUsuarioRespuesta') IS NULL
BEGIN
    ALTER TABLE dbo.MensajesContacto ADD IdUsuarioRespuesta INT NULL;

    ALTER TABLE dbo.MensajesContacto
    ADD CONSTRAINT FK_MensajesContacto_UsuarioRespuesta
        FOREIGN KEY (IdUsuarioRespuesta) REFERENCES dbo.Usuarios (IdUsuario);
END;
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_MensajesContacto_Estado_Fecha'
      AND object_id = OBJECT_ID('dbo.MensajesContacto')
)
BEGIN
    CREATE INDEX IX_MensajesContacto_Estado_Fecha
        ON dbo.MensajesContacto (Estado, FechaEnvio DESC);
END;
GO

-- Se conserva el contrato anterior y solo se agregan las columnas de respuesta.
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerMensajesContacto
(
    @Estado VARCHAR(20) = NULL,
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
        IdMensaje, Nombre, Correo, Telefono, Asunto, Mensaje, Estado, FechaEnvio,
        ISNULL(Respuesta, '') AS Respuesta,
        FechaRespuesta,
        COUNT(1) OVER() AS TotalItems
    FROM dbo.MensajesContacto
    WHERE (@Estado IS NULL OR Estado = @Estado)
    ORDER BY FechaEnvio DESC, IdMensaje DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoValido ROWS ONLY;
END
GO

-- Registra la respuesta del personal y marca la consulta como atendida.
CREATE OR ALTER PROCEDURE dbo.SP_ResponderMensajeContacto
(
    @IdMensaje INT,
    @Respuesta VARCHAR(2000),
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.MensajesContacto WHERE IdMensaje = @IdMensaje)
        BEGIN
            SELECT 0 AS Codigo, 'MENSAJE_NO_EXISTE' AS Mensaje,
                   CAST(NULL AS VARCHAR(150)) AS Correo,
                   CAST(NULL AS VARCHAR(150)) AS Nombre,
                   CAST(NULL AS VARCHAR(150)) AS Asunto;
            RETURN;
        END

        UPDATE dbo.MensajesContacto
        SET Respuesta = @Respuesta,
            FechaRespuesta = GETDATE(),
            IdUsuarioRespuesta = @IdUsuario,
            Estado = 'Respondido'
        WHERE IdMensaje = @IdMensaje;

        INSERT INTO dbo.Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora)
        VALUES
        (
            @IdUsuario,
            'MensajesContacto',
            'UPDATE',
            CONCAT('Consulta #', @IdMensaje, ' respondida.'),
            GETDATE()
        );

        SELECT
            1 AS Codigo,
            'CONSULTA_RESPONDIDA' AS Mensaje,
            M.Correo,
            M.Nombre,
            M.Asunto
        FROM dbo.MensajesContacto M
        WHERE M.IdMensaje = @IdMensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje,
               CAST(NULL AS VARCHAR(150)) AS Correo,
               CAST(NULL AS VARCHAR(150)) AS Nombre,
               CAST(NULL AS VARCHAR(150)) AS Asunto;
    END CATCH
END
GO

-- Nota B-04: el registro de accesos denegados reutiliza SP_InsertarBitacora a
-- traves de IAuditService, por lo que no requiere procedimientos adicionales.

-- ======================================================
-- Observacion menor · SP_ObtenerUsuarios no devolvia el nombre del rol
-- ======================================================

-- Se conserva el orden y el manejo de errores original; solo se agrega NombreRol.
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerUsuarios
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT
            U.IdUsuario,
            U.Nombre,
            U.Apellido,
            U.Correo,
            U.Telefono,
            U.IdRol,
            R.NombreRol
        FROM dbo.Usuarios U
        LEFT JOIN dbo.Roles R ON R.IdRol = U.IdRol
        ORDER BY U.Nombre, U.Apellido;

    END TRY
    BEGIN CATCH

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

PRINT 'Correcciones de la auditoria de calidad aplicadas.';
GO

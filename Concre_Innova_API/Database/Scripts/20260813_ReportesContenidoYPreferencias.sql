-- Reportes de ventas, contenido informativo de la empresa y preferencias de usuario.
-- Fecha: 2026-08-13
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
('reportes.ver', 'Ver reportes de ventas', 'Reportes', 'Consultar reportes de ventas por periodo y productos mas vendidos.'),
('empresa.gestionar', 'Gestionar informacion de la empresa', 'Empresa', 'Actualizar datos de contacto, redes sociales y mensajes recibidos.');

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
WHERE p.Codigo IN ('reportes.ver', 'empresa.gestionar')
    AND NOT EXISTS (
        SELECT 1 FROM RolPermisos rp WHERE rp.IdRol = 1 AND rp.IdPermiso = p.IdPermiso
    );
GO

INSERT INTO RolPermisos (IdRol, IdPermiso)
SELECT 2, p.IdPermiso
FROM Permisos p
WHERE p.Codigo = 'reportes.ver'
    AND NOT EXISTS (
        SELECT 1 FROM RolPermisos rp WHERE rp.IdRol = 2 AND rp.IdPermiso = p.IdPermiso
    );
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'InformacionEmpresa')
BEGIN
    CREATE TABLE InformacionEmpresa (
        IdInformacion INT IDENTITY(1,1) PRIMARY KEY,
        NombreEmpresa VARCHAR(150) NOT NULL,
        Descripcion VARCHAR(1000) NOT NULL CONSTRAINT DF_InformacionEmpresa_Descripcion DEFAULT (''),
        Correo VARCHAR(150) NOT NULL CONSTRAINT DF_InformacionEmpresa_Correo DEFAULT (''),
        Telefono VARCHAR(50) NOT NULL CONSTRAINT DF_InformacionEmpresa_Telefono DEFAULT (''),
        WhatsApp VARCHAR(50) NOT NULL CONSTRAINT DF_InformacionEmpresa_WhatsApp DEFAULT (''),
        Direccion VARCHAR(255) NOT NULL CONSTRAINT DF_InformacionEmpresa_Direccion DEFAULT (''),
        Horario VARCHAR(255) NOT NULL CONSTRAINT DF_InformacionEmpresa_Horario DEFAULT (''),
        Facebook VARCHAR(255) NOT NULL CONSTRAINT DF_InformacionEmpresa_Facebook DEFAULT (''),
        Instagram VARCHAR(255) NOT NULL CONSTRAINT DF_InformacionEmpresa_Instagram DEFAULT (''),
        TikTok VARCHAR(255) NOT NULL CONSTRAINT DF_InformacionEmpresa_TikTok DEFAULT (''),
        FechaActualizacion DATETIME NOT NULL CONSTRAINT DF_InformacionEmpresa_Fecha DEFAULT (GETDATE())
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM InformacionEmpresa)
BEGIN
    INSERT INTO InformacionEmpresa
    (
        NombreEmpresa, Descripcion, Correo, Telefono, WhatsApp,
        Direccion, Horario, Facebook, Instagram, TikTok
    )
    VALUES
    (
        'Concre Innova',
        'Diseno ecologico para espacios modernos. Seleccion botanica, asesoria de cuidado y entrega local.',
        'contacto@concreinnova.com',
        '+506 8888-8888',
        '+506 8888-8888',
        'San Miguel Oeste, Naranjo, Alajuela',
        'Lunes a viernes de 8:00 a.m. a 5:00 p.m.',
        'https://www.facebook.com/concreinnova',
        'https://www.instagram.com/concreinnova',
        'https://www.tiktok.com/@concreinnova'
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'MensajesContacto')
BEGIN
    CREATE TABLE MensajesContacto (
        IdMensaje INT IDENTITY(1,1) PRIMARY KEY,
        Nombre VARCHAR(150) NOT NULL,
        Correo VARCHAR(150) NOT NULL,
        Telefono VARCHAR(50) NOT NULL CONSTRAINT DF_MensajesContacto_Telefono DEFAULT (''),
        Asunto VARCHAR(150) NOT NULL,
        Mensaje VARCHAR(2000) NOT NULL,
        Estado VARCHAR(20) NOT NULL CONSTRAINT DF_MensajesContacto_Estado DEFAULT ('Nuevo'),
        FechaEnvio DATETIME NOT NULL CONSTRAINT DF_MensajesContacto_Fecha DEFAULT (GETDATE()),
        IdUsuario INT NULL,
        CONSTRAINT FK_MensajesContacto_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios (IdUsuario)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PreferenciasUsuario')
BEGIN
    CREATE TABLE PreferenciasUsuario (
        IdUsuario INT NOT NULL PRIMARY KEY,
        NotificacionesActivas BIT NOT NULL CONSTRAINT DF_PreferenciasUsuario_Notificaciones DEFAULT (1),
        NotificacionesCorreo BIT NOT NULL CONSTRAINT DF_PreferenciasUsuario_Correo DEFAULT (1),
        Tema VARCHAR(20) NOT NULL CONSTRAINT DF_PreferenciasUsuario_Tema DEFAULT ('claro'),
        FechaActualizacion DATETIME NOT NULL CONSTRAINT DF_PreferenciasUsuario_Fecha DEFAULT (GETDATE()),
        CONSTRAINT FK_PreferenciasUsuario_Usuarios FOREIGN KEY (IdUsuario) REFERENCES Usuarios (IdUsuario)
    );
END;
GO

CREATE OR ALTER PROCEDURE SP_ReporteVentasPorPeriodo
(
    @FechaDesde DATE,
    @FechaHasta DATE,
    @IdCategoria INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Limite DATETIME = DATEADD(DAY, 1, @FechaHasta);

    SELECT
        CAST(P.FechaPedido AS DATE) AS Fecha,
        PR.Nombre AS Producto,
        ISNULL(CAT.NombreCategoria, 'Sin categoria') AS Categoria,
        SUM(DP.Cantidad) AS Unidades,
        COUNT(DISTINCT P.IdPedido) AS Pedidos,
        SUM(DP.Subtotal) AS Ingresos
    FROM Pedidos P
    INNER JOIN DetallePedido DP ON DP.IdPedido = P.IdPedido
    INNER JOIN Productos PR ON PR.IdProducto = DP.IdProducto
    LEFT JOIN Categorias CAT ON CAT.IdCategoria = PR.IdCategoria
    WHERE P.Estado <> 'Cancelado'
        AND P.FechaPedido >= @FechaDesde
        AND P.FechaPedido < @Limite
        AND (@IdCategoria IS NULL OR PR.IdCategoria = @IdCategoria)
    GROUP BY CAST(P.FechaPedido AS DATE), PR.Nombre, CAT.NombreCategoria
    ORDER BY CAST(P.FechaPedido AS DATE), PR.Nombre;

    SELECT
        ISNULL(SUM(DP.Subtotal), 0) AS IngresosTotales,
        ISNULL(COUNT(DISTINCT P.IdPedido), 0) AS PedidosTotales,
        ISNULL(SUM(DP.Cantidad), 0) AS UnidadesTotales
    FROM Pedidos P
    INNER JOIN DetallePedido DP ON DP.IdPedido = P.IdPedido
    INNER JOIN Productos PR ON PR.IdProducto = DP.IdProducto
    WHERE P.Estado <> 'Cancelado'
        AND P.FechaPedido >= @FechaDesde
        AND P.FechaPedido < @Limite
        AND (@IdCategoria IS NULL OR PR.IdCategoria = @IdCategoria);

    SELECT
        CAST(P.FechaPedido AS DATE) AS Fecha,
        SUM(DP.Subtotal) AS Ingresos,
        COUNT(DISTINCT P.IdPedido) AS Pedidos
    FROM Pedidos P
    INNER JOIN DetallePedido DP ON DP.IdPedido = P.IdPedido
    INNER JOIN Productos PR ON PR.IdProducto = DP.IdProducto
    WHERE P.Estado <> 'Cancelado'
        AND P.FechaPedido >= @FechaDesde
        AND P.FechaPedido < @Limite
        AND (@IdCategoria IS NULL OR PR.IdCategoria = @IdCategoria)
    GROUP BY CAST(P.FechaPedido AS DATE)
    ORDER BY CAST(P.FechaPedido AS DATE);
END
GO

CREATE OR ALTER PROCEDURE SP_ReporteComparativoPeriodos
(
    @PeriodoADesde DATE,
    @PeriodoAHasta DATE,
    @PeriodoBDesde DATE,
    @PeriodoBHasta DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LimiteA DATETIME = DATEADD(DAY, 1, @PeriodoAHasta);
    DECLARE @LimiteB DATETIME = DATEADD(DAY, 1, @PeriodoBHasta);

    ;WITH Totales AS
    (
        SELECT
            'A' AS Periodo,
            ISNULL(SUM(P.Total), 0) AS Ingresos,
            COUNT(1) AS Pedidos
        FROM Pedidos P
        WHERE P.Estado <> 'Cancelado'
            AND P.FechaPedido >= @PeriodoADesde
            AND P.FechaPedido < @LimiteA
        UNION ALL
        SELECT
            'B' AS Periodo,
            ISNULL(SUM(P.Total), 0) AS Ingresos,
            COUNT(1) AS Pedidos
        FROM Pedidos P
        WHERE P.Estado <> 'Cancelado'
            AND P.FechaPedido >= @PeriodoBDesde
            AND P.FechaPedido < @LimiteB
    )
    SELECT
        Periodo,
        Ingresos,
        Pedidos,
        CASE WHEN Pedidos > 0 THEN Ingresos / Pedidos ELSE 0 END AS TicketPromedio
    FROM Totales
    ORDER BY Periodo;
END
GO

CREATE OR ALTER PROCEDURE SP_ReporteProductosMasVendidos
(
    @FechaDesde DATE,
    @FechaHasta DATE,
    @Top INT = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Limite DATETIME = DATEADD(DAY, 1, @FechaHasta);

    SELECT TOP (@Top)
        PR.IdProducto,
        PR.Nombre AS Producto,
        ISNULL(CAT.NombreCategoria, 'Sin categoria') AS Categoria,
        SUM(DP.Cantidad) AS UnidadesVendidas,
        SUM(DP.Subtotal) AS Ingresos
    FROM Pedidos P
    INNER JOIN DetallePedido DP ON DP.IdPedido = P.IdPedido
    INNER JOIN Productos PR ON PR.IdProducto = DP.IdProducto
    LEFT JOIN Categorias CAT ON CAT.IdCategoria = PR.IdCategoria
    WHERE P.Estado <> 'Cancelado'
        AND P.FechaPedido >= @FechaDesde
        AND P.FechaPedido < @Limite
    GROUP BY PR.IdProducto, PR.Nombre, CAT.NombreCategoria
    ORDER BY SUM(DP.Cantidad) DESC;
END
GO

CREATE OR ALTER PROCEDURE SP_EstadisticasDashboard
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InicioMes DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

    SELECT
        ISNULL((
            SELECT SUM(Total) FROM Pedidos
            WHERE Estado <> 'Cancelado'
                AND FechaPedido >= @InicioMes
                AND FechaPedido < DATEADD(MONTH, 1, @InicioMes)
        ), 0) AS VentasMes,
        ISNULL((
            SELECT COUNT(1) FROM Pedidos WHERE Estado = 'Pendiente'
        ), 0) AS PedidosPendientes,
        ISNULL((
            SELECT COUNT(1) FROM Cotizaciones WHERE Estado IN ('Pendiente', 'Respondida', 'Aceptada')
        ), 0) AS CotizacionesPendientes,
        ISNULL((
            SELECT COUNT(1) FROM Productos PR
            LEFT JOIN Inventario I ON I.IdProducto = PR.IdProducto
            WHERE ISNULL(PR.Estado, 'Activo') = 'Activo'
                AND ISNULL(PR.Stock, 0) <= ISNULL(I.CantidadMinima, 5)
        ), 0) AS ProductosBajoStock,
        ISNULL((
            SELECT COUNT(1) FROM Productos
            WHERE ISNULL(Estado, 'Activo') = 'Activo'
        ), 0) AS ProductosActivos;

    SELECT TOP (6)
        FORMAT(Mes, 'yyyy-MM') AS Periodo,
        Ingresos
    FROM
    (
        SELECT
            DATEFROMPARTS(YEAR(FechaPedido), MONTH(FechaPedido), 1) AS Mes,
            SUM(Total) AS Ingresos
        FROM Pedidos
        WHERE Estado <> 'Cancelado'
        GROUP BY DATEFROMPARTS(YEAR(FechaPedido), MONTH(FechaPedido), 1)
    ) VentasMensuales
    ORDER BY Mes DESC;
END
GO

CREATE OR ALTER PROCEDURE SP_ObtenerInformacionEmpresa
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (1)
        IdInformacion, NombreEmpresa, Descripcion, Correo, Telefono, WhatsApp,
        Direccion, Horario, Facebook, Instagram, TikTok, FechaActualizacion
    FROM InformacionEmpresa
    ORDER BY IdInformacion;
END
GO

CREATE OR ALTER PROCEDURE SP_ActualizarInformacionEmpresa
(
    @NombreEmpresa VARCHAR(150),
    @Descripcion VARCHAR(1000),
    @Correo VARCHAR(150),
    @Telefono VARCHAR(50),
    @WhatsApp VARCHAR(50),
    @Direccion VARCHAR(255),
    @Horario VARCHAR(255),
    @Facebook VARCHAR(255),
    @Instagram VARCHAR(255),
    @TikTok VARCHAR(255),
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        DECLARE @IdInformacion INT = (SELECT TOP (1) IdInformacion FROM InformacionEmpresa ORDER BY IdInformacion);

        IF @IdInformacion IS NULL
        BEGIN
            INSERT INTO InformacionEmpresa
            (NombreEmpresa, Descripcion, Correo, Telefono, WhatsApp, Direccion, Horario, Facebook, Instagram, TikTok)
            VALUES
            (@NombreEmpresa, @Descripcion, @Correo, @Telefono, @WhatsApp, @Direccion, @Horario, @Facebook, @Instagram, @TikTok);
        END
        ELSE
        BEGIN
            UPDATE InformacionEmpresa
            SET NombreEmpresa = @NombreEmpresa,
                Descripcion = @Descripcion,
                Correo = @Correo,
                Telefono = @Telefono,
                WhatsApp = @WhatsApp,
                Direccion = @Direccion,
                Horario = @Horario,
                Facebook = @Facebook,
                Instagram = @Instagram,
                TikTok = @TikTok,
                FechaActualizacion = GETDATE()
            WHERE IdInformacion = @IdInformacion;
        END

        INSERT INTO Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora)
        VALUES (@IdUsuario, 'InformacionEmpresa', 'UPDATE', 'Actualizacion de la informacion de la empresa.', GETDATE());

        SELECT 1 AS Codigo, 'INFORMACION_ACTUALIZADA' AS Mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE SP_RegistrarMensajeContacto
(
    @Nombre VARCHAR(150),
    @Correo VARCHAR(150),
    @Telefono VARCHAR(50),
    @Asunto VARCHAR(150),
    @Mensaje VARCHAR(2000),
    @IdUsuario INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO MensajesContacto (Nombre, Correo, Telefono, Asunto, Mensaje, IdUsuario)
        VALUES (@Nombre, @Correo, @Telefono, @Asunto, @Mensaje, @IdUsuario);

        SELECT 1 AS Codigo, 'MENSAJE_REGISTRADO' AS Mensaje, CONVERT(INT, SCOPE_IDENTITY()) AS IdMensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje, CAST(NULL AS INT) AS IdMensaje;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE SP_ObtenerMensajesContacto
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
        COUNT(1) OVER() AS TotalItems
    FROM MensajesContacto
    WHERE (@Estado IS NULL OR Estado = @Estado)
    ORDER BY FechaEnvio DESC, IdMensaje DESC
    OFFSET @Offset ROWS FETCH NEXT @TamanoValido ROWS ONLY;
END
GO

CREATE OR ALTER PROCEDURE SP_ObtenerPreferenciasUsuario
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PreferenciasUsuario WHERE IdUsuario = @IdUsuario)
    BEGIN
        INSERT INTO PreferenciasUsuario (IdUsuario) VALUES (@IdUsuario);
    END

    SELECT IdUsuario, NotificacionesActivas, NotificacionesCorreo, Tema, FechaActualizacion
    FROM PreferenciasUsuario
    WHERE IdUsuario = @IdUsuario;
END
GO

CREATE OR ALTER PROCEDURE SP_ActualizarPreferenciasUsuario
(
    @IdUsuario INT,
    @NotificacionesActivas BIT,
    @NotificacionesCorreo BIT,
    @Tema VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @Tema NOT IN ('claro', 'oscuro')
        BEGIN
            SELECT 0 AS Codigo, 'TEMA_INVALIDO' AS Mensaje;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM PreferenciasUsuario WHERE IdUsuario = @IdUsuario)
        BEGIN
            UPDATE PreferenciasUsuario
            SET NotificacionesActivas = @NotificacionesActivas,
                NotificacionesCorreo = @NotificacionesCorreo,
                Tema = @Tema,
                FechaActualizacion = GETDATE()
            WHERE IdUsuario = @IdUsuario;
        END
        ELSE
        BEGIN
            INSERT INTO PreferenciasUsuario (IdUsuario, NotificacionesActivas, NotificacionesCorreo, Tema)
            VALUES (@IdUsuario, @NotificacionesActivas, @NotificacionesCorreo, @Tema);
        END

        SELECT 1 AS Codigo, 'PREFERENCIAS_ACTUALIZADAS' AS Mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

PRINT 'Reportes de ventas, contenido informativo y preferencias de usuario instalados.';
GO

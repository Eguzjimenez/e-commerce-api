-- Sprint 3: reliable email notifications for quotation status changes.
-- Database: ConcreInnovaDB

SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
GO

IF OBJECT_ID('dbo.CotizacionNotificaciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CotizacionNotificaciones
    (
        IdCotizacionNotificacion INT IDENTITY(1,1) NOT NULL,
        IdCotizacion INT NOT NULL,
        EstadoAnterior VARCHAR(30) NOT NULL,
        EstadoNuevo VARCHAR(30) NOT NULL,
        FechaCambio DATETIME2(0) NOT NULL,
        FechaEnvio DATETIME2(0) NULL,
        Intentos SMALLINT NOT NULL
            CONSTRAINT DF_CotizacionNotificaciones_Intentos DEFAULT (0),
        UltimoIntento DATETIME2(0) NULL,
        CONSTRAINT PK_CotizacionNotificaciones
            PRIMARY KEY CLUSTERED (IdCotizacionNotificacion),
        CONSTRAINT FK_CotizacionNotificaciones_Cotizaciones
            FOREIGN KEY (IdCotizacion)
            REFERENCES dbo.Cotizaciones (IdCotizacion)
            ON DELETE CASCADE,
        CONSTRAINT CK_CotizacionNotificaciones_Intentos
            CHECK (Intentos >= 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.CotizacionNotificaciones')
      AND name = 'IX_CotizacionNotificaciones_Pendientes'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_CotizacionNotificaciones_Pendientes
        ON dbo.CotizacionNotificaciones
        (
            IdCotizacion,
            Intentos,
            IdCotizacionNotificacion
        )
        INCLUDE
        (
            EstadoAnterior,
            EstadoNuevo,
            FechaCambio
        )
        WHERE FechaEnvio IS NULL;
END;
GO

CREATE OR ALTER TRIGGER dbo.TR_Cotizaciones_RegistrarCambioEstado
ON dbo.Cotizaciones
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FechaCambio DATETIME2(0) = SYSDATETIME();

    INSERT dbo.CotizacionEstadoHistorial
    (
        IdCotizacion,
        EstadoAnterior,
        EstadoNuevo,
        FechaCambio
    )
    SELECT
        I.IdCotizacion,
        D.Estado,
        ISNULL(I.Estado, 'Pendiente'),
        @FechaCambio
    FROM inserted I
    LEFT JOIN deleted D
        ON D.IdCotizacion = I.IdCotizacion
    WHERE D.IdCotizacion IS NULL
       OR ISNULL(D.Estado, '') <> ISNULL(I.Estado, '');

    INSERT dbo.CotizacionNotificaciones
    (
        IdCotizacion,
        EstadoAnterior,
        EstadoNuevo,
        FechaCambio
    )
    SELECT
        I.IdCotizacion,
        ISNULL(D.Estado, 'Pendiente'),
        ISNULL(I.Estado, 'Pendiente'),
        @FechaCambio
    FROM inserted I
    INNER JOIN deleted D
        ON D.IdCotizacion = I.IdCotizacion
    WHERE ISNULL(D.Estado, '') <> ISNULL(I.Estado, '');
END;
GO

PRINT 'Quotation status notification outbox installed.';
GO

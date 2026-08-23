/*
    Concre Innova - base de datos completa
    Origen: ConcreInnovaDB (copia anonimizada)
    Generado: 2026-08-23 11:32:13

    Contenido:
      - tablas, columnas, claves, restricciones e indices;
      - tipos de tabla definidos por el usuario;
      - datos existentes, conservando valores identity;
      - procedimientos almacenados y triggers.

    Datos: Datos de desarrollo anonimizados; contrasena comun: ConcreDev2026!

    Ejecute este archivo sobre una instancia de SQL Server con permisos para
    crear bases de datos. Por seguridad, el archivo no elimina ni reemplaza
    una base existente. Se recomienda ejecutarlo sobre una instancia limpia.
*/

-- ============================================================================
-- Creacion y seleccion de la base de datos
-- ============================================================================

USE [master];
GO

IF DB_ID(N'ConcreInnovaDB') IS NULL
BEGIN
    CREATE DATABASE [ConcreInnovaDB] COLLATE SQL_Latin1_General_CP1_CI_AS;
END;
GO

USE [ConcreInnovaDB];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
GO

-- ============================================================================
-- Tipos definidos por el usuario
-- ============================================================================

CREATE TYPE [dbo].[TVP_AsesorOpcion] AS TABLE(
	[IdOpcion] [int] NOT NULL,
	PRIMARY KEY CLUSTERED
(
	[IdOpcion] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO

CREATE TYPE [dbo].[TVP_Carrito] AS TABLE(
	[IdProducto] [int] NULL,
	[Cantidad] [int] NULL
)
GO

CREATE TYPE [dbo].[TVP_CotizacionImagen] AS TABLE(
	[RutaArchivo] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NombreOriginal] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TipoContenido] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TamanoBytes] [bigint] NOT NULL
)
GO

CREATE TYPE [dbo].[TVP_CotizacionProducto] AS TABLE(
	[IdProducto] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnitario] [decimal](10, 2) NOT NULL
)
GO

CREATE TYPE [dbo].[TVP_PedidoItem] AS TABLE(
	[IdProducto] [int] NOT NULL,
	[IdVariante] [int] NULL,
	[Cantidad] [int] NOT NULL,
	[NombreVariante] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Tamano] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Material] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Color] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO

CREATE TYPE [dbo].[TVP_SolicitudCotizacionProducto] AS TABLE(
	[IdProducto] [int] NOT NULL,
	[Cantidad] [int] NOT NULL
)
GO

CREATE TYPE [dbo].[TVP_VisualizacionProducto] AS TABLE(
	[IdProducto] [int] NOT NULL,
	[IdVariante] [int] NULL,
	[Cantidad] [int] NOT NULL,
	[Color] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Macetero] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PosicionX] [decimal](9, 2) NOT NULL,
	[PosicionY] [decimal](9, 2) NOT NULL,
	[Ancho] [decimal](9, 2) NOT NULL,
	[Alto] [decimal](9, 2) NOT NULL,
	[Rotacion] [decimal](9, 2) NOT NULL,
	[Orden] [int] NOT NULL
)
GO

-- ============================================================================
-- Secuencias
-- ============================================================================

-- ============================================================================
-- Tablas, restricciones locales e indices
-- ============================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AsesorCriterios](
	[IdCriterio] [int] IDENTITY(1,1) NOT NULL,
	[IdOpcion] [int] NOT NULL,
	[IdCategoria] [int] NULL,
	[IdTipo] [int] NULL,
	[PalabraClave] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Peso] [int] NOT NULL,
 CONSTRAINT [PK_AsesorCriterios] PRIMARY KEY CLUSTERED
(
	[IdCriterio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AsesorOpciones](
	[IdOpcion] [int] IDENTITY(1,1) NOT NULL,
	[IdPregunta] [int] NOT NULL,
	[Codigo] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Etiqueta] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Orden] [int] NOT NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_AsesorOpciones] PRIMARY KEY CLUSTERED
(
	[IdOpcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_AsesorOpciones_PreguntaCodigo] UNIQUE NONCLUSTERED
(
	[IdPregunta] ASC,
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AsesorPreguntas](
	[IdPregunta] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Texto] [varchar](200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Ayuda] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Orden] [int] NOT NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_AsesorPreguntas] PRIMARY KEY CLUSTERED
(
	[IdPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_AsesorPreguntas_Codigo] UNIQUE NONCLUSTERED
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AsesorRespuestas](
	[IdRespuesta] [int] IDENTITY(1,1) NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdPregunta] [int] NOT NULL,
	[IdOpcion] [int] NOT NULL,
	[FechaRegistro] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_AsesorRespuestas] PRIMARY KEY CLUSTERED
(
	[IdRespuesta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_AsesorRespuestas_UsuarioPregunta] UNIQUE NONCLUSTERED
(
	[IdUsuario] ASC,
	[IdPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Bitacora](
	[IdBitacora] [int] IDENTITY(1,1) NOT NULL,
	[IdUsuario] [int] NULL,
	[TablaAfectada] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Operacion] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Descripcion] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaHora] [datetime] NULL,
	[IpUsuario] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[IdBitacora] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BotIntenciones](
	[IdIntencion] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Respuesta] [nvarchar](600) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[SugiereProductos] [bit] NOT NULL,
	[SugiereEscalamiento] [bit] NOT NULL,
	[Orden] [int] NOT NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_BotIntenciones] PRIMARY KEY CLUSTERED
(
	[IdIntencion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_BotIntenciones_Codigo] UNIQUE NONCLUSTERED
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BotIntencionPalabras](
	[IdPalabra] [int] IDENTITY(1,1) NOT NULL,
	[IdIntencion] [int] NOT NULL,
	[PalabraClave] [nvarchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_BotIntencionPalabras] PRIMARY KEY CLUSTERED
(
	[IdPalabra] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_BotIntencionPalabras_IntencionPalabra] UNIQUE NONCLUSTERED
(
	[IdIntencion] ASC,
	[PalabraClave] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CategoriaClasificacion](
	[IdCategoria] [int] NOT NULL,
	[Clasificacion] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_CategoriaClasificacion] PRIMARY KEY CLUSTERED
(
	[IdCategoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Categorias](
	[IdCategoria] [int] IDENTITY(1,1) NOT NULL,
	[NombreCategoria] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[IdCategoria] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CategoriaTipo](
	[IdCategoria] [int] NOT NULL,
	[IdTipo] [int] NOT NULL,
 CONSTRAINT [PK_CategoriaTipo] PRIMARY KEY CLUSTERED
(
	[IdCategoria] ASC,
	[IdTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Chats](
	[IdChat] [int] IDENTITY(1,1) NOT NULL,
	[IdCliente] [int] NOT NULL,
	[IdUsuario] [int] NULL,
	[FechaInicio] [datetime] NULL,
	[Estado] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaCierre] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[IdChat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Clientes](
	[IdCliente] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Apellido] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Correo] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Telefono] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Direccion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaRegistro] [datetime] NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IdUsuario] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[IdCliente] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[Correo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Cotizaciones](
	[IdCotizacion] [int] IDENTITY(1,1) NOT NULL,
	[IdCliente] [int] NOT NULL,
	[FechaCotizacion] [datetime] NULL,
	[Estado] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Total] [decimal](18, 2) NOT NULL,
	[Descripcion] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Respuesta] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaRespuesta] [datetime] NULL,
	[Preferencias] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NumeroSeguimiento] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[IdCotizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CotizacionEstadoHistorial](
	[IdCotizacionEstadoHistorial] [int] IDENTITY(1,1) NOT NULL,
	[IdCotizacion] [int] NOT NULL,
	[EstadoAnterior] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EstadoNuevo] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FechaCambio] [datetime2](0) NOT NULL,
 CONSTRAINT [PK_CotizacionEstadoHistorial] PRIMARY KEY CLUSTERED
(
	[IdCotizacionEstadoHistorial] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CotizacionImagenes](
	[IdCotizacionImagen] [int] IDENTITY(1,1) NOT NULL,
	[IdCotizacion] [int] NOT NULL,
	[RutaArchivo] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NombreOriginal] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TipoContenido] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TamanoBytes] [bigint] NOT NULL,
	[FechaCarga] [datetime] NOT NULL,
 CONSTRAINT [PK_CotizacionImagenes] PRIMARY KEY CLUSTERED
(
	[IdCotizacionImagen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CotizacionNotificaciones](
	[IdCotizacionNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IdCotizacion] [int] NOT NULL,
	[EstadoAnterior] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[EstadoNuevo] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FechaCambio] [datetime2](0) NOT NULL,
	[FechaEnvio] [datetime2](0) NULL,
	[Intentos] [smallint] NOT NULL,
	[UltimoIntento] [datetime2](0) NULL,
 CONSTRAINT [PK_CotizacionNotificaciones] PRIMARY KEY CLUSTERED
(
	[IdCotizacionNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DetalleCotizacion](
	[IdDetalleCotizacion] [int] IDENTITY(1,1) NOT NULL,
	[IdCotizacion] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnitario] [decimal](10, 2) NOT NULL,
	[Subtotal] [decimal](18, 2) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdDetalleCotizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DetallePedido](
	[IdDetallePedido] [int] IDENTITY(1,1) NOT NULL,
	[IdPedido] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
	[PrecioUnitario] [decimal](10, 2) NOT NULL,
	[Subtotal] [decimal](10, 2) NOT NULL,
	[IdVariante] [int] NULL,
	[NombreVariante] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Tamano] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Material] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Color] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[IdDetallePedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Favoritos](
	[IdFavorito] [int] IDENTITY(1,1) NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdFavorito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InformacionEmpresa](
	[IdInformacion] [int] IDENTITY(1,1) NOT NULL,
	[NombreEmpresa] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Descripcion] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Correo] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Telefono] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[WhatsApp] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Direccion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Horario] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Facebook] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Instagram] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[TikTok] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FechaActualizacion] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdInformacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[IntentosLogin](
	[IdUsuario] [int] NOT NULL,
	[CantidadIntentos] [int] NOT NULL,
	[FechaUltimoIntento] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Inventario](
	[IdInventario] [int] IDENTITY(1,1) NOT NULL,
	[IdProducto] [int] NOT NULL,
	[CantidadDisponible] [int] NOT NULL,
	[CantidadMinima] [int] NULL,
	[FechaActualizacion] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[IdInventario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MensajesChat](
	[IdMensaje] [int] IDENTITY(1,1) NOT NULL,
	[IdChat] [int] NOT NULL,
	[Remitente] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Mensaje] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaHora] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[IdMensaje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MensajesContacto](
	[IdMensaje] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Correo] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Telefono] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Asunto] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Mensaje] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FechaEnvio] [datetime] NOT NULL,
	[IdUsuario] [int] NULL,
	[Respuesta] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaRespuesta] [datetime] NULL,
	[IdUsuarioRespuesta] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[IdMensaje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Notificaciones](
	[IdNotificacion] [int] IDENTITY(1,1) NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[Mensaje] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Leida] [bit] NULL,
	[FechaEnvio] [datetime] NULL,
	[Tipo] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Titulo] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Enlace] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Referencia] [int] NULL,
	[FechaLectura] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[IdNotificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Pagos](
	[IdPago] [int] IDENTITY(1,1) NOT NULL,
	[IdVenta] [int] NOT NULL,
	[Monto] [decimal](10, 2) NOT NULL,
	[FechaPago] [datetime] NULL,
	[MetodoPago] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Referencia] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ComprobanteArchivo] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IdUsuarioRegistro] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[IdPago] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Pedidos](
	[IdPedido] [int] IDENTITY(1,1) NOT NULL,
	[IdCliente] [int] NOT NULL,
	[FechaPedido] [datetime] NULL,
	[Estado] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DireccionEntrega] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Total] [decimal](10, 2) NOT NULL,
	[IdCotizacion] [int] NULL,
PRIMARY KEY CLUSTERED
(
	[IdPedido] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Permisos](
	[IdPermiso] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Nombre] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Modulo] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PreferenciasUsuario](
	[IdUsuario] [int] NOT NULL,
	[NotificacionesActivas] [bit] NOT NULL,
	[NotificacionesCorreo] [bit] NOT NULL,
	[Tema] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FechaActualizacion] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Productos](
	[IdProducto] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Descripcion] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Precio] [decimal](10, 2) NOT NULL,
	[Stock] [int] NULL,
	[Imagen] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaRegistro] [datetime] NULL,
	[IdCategoria] [int] NOT NULL,
	[Tamano] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Material] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[IdTipo] [int] NULL,
	[Caracteristicas] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ProductoVariantes](
	[IdVariante] [int] IDENTITY(1,1) NOT NULL,
	[IdProducto] [int] NOT NULL,
	[NombreVariante] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Tamano] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Material] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Precio] [decimal](18, 2) NOT NULL,
	[Stock] [int] NOT NULL,
	[Imagen] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdVariante] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Roles](
	[IdRol] [int] IDENTITY(1,1) NOT NULL,
	[NombreRol] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdRol] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RolPermisos](
	[IdRol] [int] NOT NULL,
	[IdPermiso] [int] NOT NULL,
 CONSTRAINT [PK_RolPermisos] PRIMARY KEY CLUSTERED
(
	[IdRol] ASC,
	[IdPermiso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SolicitudCotizacionProductos](
	[IdSolicitudCotizacionProducto] [int] IDENTITY(1,1) NOT NULL,
	[IdCotizacion] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[Cantidad] [int] NOT NULL,
 CONSTRAINT [PK_SolicitudCotizacionProductos] PRIMARY KEY CLUSTERED
(
	[IdSolicitudCotizacionProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_SolicitudCotizacionProductos_CotizacionProducto] UNIQUE NONCLUSTERED
(
	[IdCotizacion] ASC,
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TiposProducto](
	[IdTipo] [int] IDENTITY(1,1) NOT NULL,
	[NombreTipo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Descripcion] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Usuarios](
	[IdUsuario] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Apellido] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Correo] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[ContrasenaHash] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Telefono] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FechaRegistro] [datetime] NULL,
	[IdRol] [int] NOT NULL,
PRIMARY KEY CLUSTERED
(
	[IdUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED
(
	[Correo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Ventas](
	[IdVenta] [int] IDENTITY(1,1) NOT NULL,
	[IdPedido] [int] NOT NULL,
	[FechaVenta] [datetime] NULL,
	[MetodoPago] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EstadoPago] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Total] [decimal](10, 2) NOT NULL,
	[FechaVencimiento] [datetime] NULL,
	[Observaciones] [varchar](400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PRIMARY KEY CLUSTERED
(
	[IdVenta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Visualizaciones](
	[IdVisualizacion] [int] IDENTITY(1,1) NOT NULL,
	[IdUsuario] [int] NOT NULL,
	[Nombre] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[RutaImagenEspacio] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[AnchoLienzo] [int] NOT NULL,
	[AltoLienzo] [int] NOT NULL,
	[FechaCreacion] [datetime2](0) NOT NULL,
	[FechaActualizacion] [datetime2](0) NOT NULL,
	[Estado] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
 CONSTRAINT [PK_Visualizaciones] PRIMARY KEY CLUSTERED
(
	[IdVisualizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[VisualizacionProductos](
	[IdVisualizacionProducto] [int] IDENTITY(1,1) NOT NULL,
	[IdVisualizacion] [int] NOT NULL,
	[IdProducto] [int] NOT NULL,
	[IdVariante] [int] NULL,
	[Cantidad] [int] NOT NULL,
	[Color] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Macetero] [varchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PosicionX] [decimal](9, 2) NOT NULL,
	[PosicionY] [decimal](9, 2) NOT NULL,
	[Ancho] [decimal](9, 2) NOT NULL,
	[Alto] [decimal](9, 2) NOT NULL,
	[Rotacion] [decimal](9, 2) NOT NULL,
	[Orden] [int] NOT NULL,
 CONSTRAINT [PK_VisualizacionProductos] PRIMARY KEY CLUSTERED
(
	[IdVisualizacionProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_AsesorCriterios_Opcion] ON [dbo].[AsesorCriterios]
(
	[IdOpcion] ASC
)
INCLUDE([IdCategoria],[IdTipo],[PalabraClave],[Peso]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_Chats_EstadoFechaInicio] ON [dbo].[Chats]
(
	[Estado] ASC,
	[FechaInicio] DESC,
	[IdChat] DESC
)
INCLUDE([IdCliente],[IdUsuario]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_Clientes_IdUsuario] ON [dbo].[Clientes]
(
	[IdUsuario] ASC
)
WHERE ([IdUsuario] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_Clientes_IdUsuario] ON [dbo].[Clientes]
(
	[IdUsuario] ASC
)
WHERE ([IdUsuario] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_Cotizaciones_ClienteEstadoFecha] ON [dbo].[Cotizaciones]
(
	[IdCliente] ASC,
	[Estado] ASC,
	[FechaCotizacion] DESC,
	[IdCotizacion] DESC
)
INCLUDE([NumeroSeguimiento]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_Cotizaciones_EstadoFecha] ON [dbo].[Cotizaciones]
(
	[Estado] ASC,
	[FechaCotizacion] DESC,
	[IdCotizacion] DESC
)
INCLUDE([IdCliente],[NumeroSeguimiento],[Total],[FechaRespuesta]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_Cotizaciones_IdCliente_FechaCotizacion] ON [dbo].[Cotizaciones]
(
	[IdCliente] ASC,
	[FechaCotizacion] DESC
)
INCLUDE([Estado],[Total]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_Cotizaciones_NumeroSeguimiento] ON [dbo].[Cotizaciones]
(
	[NumeroSeguimiento] ASC
)
WHERE ([NumeroSeguimiento] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_CotizacionEstadoHistorial_CotizacionFecha] ON [dbo].[CotizacionEstadoHistorial]
(
	[IdCotizacion] ASC,
	[FechaCambio] ASC,
	[IdCotizacionEstadoHistorial] ASC
)
INCLUDE([EstadoAnterior],[EstadoNuevo]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_CotizacionImagenes_IdCotizacion] ON [dbo].[CotizacionImagenes]
(
	[IdCotizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_CotizacionNotificaciones_Pendientes] ON [dbo].[CotizacionNotificaciones]
(
	[IdCotizacion] ASC,
	[Intentos] ASC,
	[IdCotizacionNotificacion] ASC
)
INCLUDE([EstadoAnterior],[EstadoNuevo],[FechaCambio])
WHERE ([FechaEnvio] IS NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_DetalleCotizacion_IdCotizacion] ON [dbo].[DetalleCotizacion]
(
	[IdCotizacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_DetallePedido_IdVariante] ON [dbo].[DetallePedido]
(
	[IdVariante] ASC
)
WHERE ([IdVariante] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Favoritos_UsuarioProducto] ON [dbo].[Favoritos]
(
	[IdUsuario] ASC,
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_MensajesChat_ChatFecha] ON [dbo].[MensajesChat]
(
	[IdChat] ASC,
	[FechaHora] ASC,
	[IdMensaje] ASC
)
INCLUDE([Remitente],[Mensaje]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IX_MensajesContacto_Estado_Fecha] ON [dbo].[MensajesContacto]
(
	[Estado] ASC,
	[FechaEnvio] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_Notificaciones_Usuario_Fecha] ON [dbo].[Notificaciones]
(
	[IdUsuario] ASC,
	[FechaEnvio] DESC
)
INCLUDE([Leida]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_Pedidos_IdCliente_FechaPedido] ON [dbo].[Pedidos]
(
	[IdCliente] ASC,
	[FechaPedido] DESC
)
INCLUDE([Estado],[DireccionEntrega],[Total]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_Pedidos_IdCotizacion] ON [dbo].[Pedidos]
(
	[IdCotizacion] ASC
)
WHERE ([IdCotizacion] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Permisos_Codigo] ON [dbo].[Permisos]
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_ProductoVariantes_IdProducto] ON [dbo].[ProductoVariantes]
(
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_SolicitudCotizacionProductos_IdCotizacion] ON [dbo].[SolicitudCotizacionProductos]
(
	[IdCotizacion] ASC
)
INCLUDE([IdProducto],[Cantidad]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

SET ANSI_PADDING ON
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_TiposProducto_NombreTipo] ON [dbo].[TiposProducto]
(
	[NombreTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_Visualizaciones_UsuarioFecha] ON [dbo].[Visualizaciones]
(
	[IdUsuario] ASC,
	[FechaActualizacion] DESC,
	[IdVisualizacion] DESC
)
INCLUDE([Nombre],[RutaImagenEspacio],[Estado]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_VisualizacionProductos_Visualizacion] ON [dbo].[VisualizacionProductos]
(
	[IdVisualizacion] ASC,
	[Orden] ASC,
	[IdVisualizacionProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AsesorCriterios] ADD  CONSTRAINT [DF_AsesorCriterios_Peso]  DEFAULT ((1)) FOR [Peso]
GO

ALTER TABLE [dbo].[AsesorOpciones] ADD  CONSTRAINT [DF_AsesorOpciones_Descripcion]  DEFAULT ('') FOR [Descripcion]
GO

ALTER TABLE [dbo].[AsesorOpciones] ADD  CONSTRAINT [DF_AsesorOpciones_Orden]  DEFAULT ((1)) FOR [Orden]
GO

ALTER TABLE [dbo].[AsesorOpciones] ADD  CONSTRAINT [DF_AsesorOpciones_Estado]  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[AsesorPreguntas] ADD  CONSTRAINT [DF_AsesorPreguntas_Ayuda]  DEFAULT ('') FOR [Ayuda]
GO

ALTER TABLE [dbo].[AsesorPreguntas] ADD  CONSTRAINT [DF_AsesorPreguntas_Orden]  DEFAULT ((1)) FOR [Orden]
GO

ALTER TABLE [dbo].[AsesorPreguntas] ADD  CONSTRAINT [DF_AsesorPreguntas_Estado]  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[AsesorRespuestas] ADD  CONSTRAINT [DF_AsesorRespuestas_FechaRegistro]  DEFAULT (sysdatetime()) FOR [FechaRegistro]
GO

ALTER TABLE [dbo].[Bitacora] ADD  DEFAULT (getdate()) FOR [FechaHora]
GO

ALTER TABLE [dbo].[BotIntenciones] ADD  CONSTRAINT [DF_BotIntenciones_SugiereProductos]  DEFAULT ((0)) FOR [SugiereProductos]
GO

ALTER TABLE [dbo].[BotIntenciones] ADD  CONSTRAINT [DF_BotIntenciones_SugiereEscalamiento]  DEFAULT ((0)) FOR [SugiereEscalamiento]
GO

ALTER TABLE [dbo].[BotIntenciones] ADD  CONSTRAINT [DF_BotIntenciones_Orden]  DEFAULT ((1)) FOR [Orden]
GO

ALTER TABLE [dbo].[BotIntenciones] ADD  CONSTRAINT [DF_BotIntenciones_Estado]  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[Categorias] ADD  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[Chats] ADD  DEFAULT (getdate()) FOR [FechaInicio]
GO

ALTER TABLE [dbo].[Clientes] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO

ALTER TABLE [dbo].[Clientes] ADD  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[Cotizaciones] ADD  DEFAULT (getdate()) FOR [FechaCotizacion]
GO

ALTER TABLE [dbo].[Cotizaciones] ADD  DEFAULT ('Pendiente') FOR [Estado]
GO

ALTER TABLE [dbo].[CotizacionEstadoHistorial] ADD  CONSTRAINT [DF_CotizacionEstadoHistorial_FechaCambio]  DEFAULT (sysdatetime()) FOR [FechaCambio]
GO

ALTER TABLE [dbo].[CotizacionImagenes] ADD  CONSTRAINT [DF_CotizacionImagenes_FechaCarga]  DEFAULT (getdate()) FOR [FechaCarga]
GO

ALTER TABLE [dbo].[CotizacionNotificaciones] ADD  CONSTRAINT [DF_CotizacionNotificaciones_Intentos]  DEFAULT ((0)) FOR [Intentos]
GO

ALTER TABLE [dbo].[Favoritos] ADD  CONSTRAINT [DF_Favoritos_FechaRegistro]  DEFAULT (getdate()) FOR [FechaRegistro]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Descripcion]  DEFAULT ('') FOR [Descripcion]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Correo]  DEFAULT ('') FOR [Correo]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Telefono]  DEFAULT ('') FOR [Telefono]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_WhatsApp]  DEFAULT ('') FOR [WhatsApp]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Direccion]  DEFAULT ('') FOR [Direccion]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Horario]  DEFAULT ('') FOR [Horario]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Facebook]  DEFAULT ('') FOR [Facebook]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Instagram]  DEFAULT ('') FOR [Instagram]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_TikTok]  DEFAULT ('') FOR [TikTok]
GO

ALTER TABLE [dbo].[InformacionEmpresa] ADD  CONSTRAINT [DF_InformacionEmpresa_Fecha]  DEFAULT (getdate()) FOR [FechaActualizacion]
GO

ALTER TABLE [dbo].[IntentosLogin] ADD  DEFAULT ((0)) FOR [CantidadIntentos]
GO

ALTER TABLE [dbo].[IntentosLogin] ADD  DEFAULT (getdate()) FOR [FechaUltimoIntento]
GO

ALTER TABLE [dbo].[Inventario] ADD  DEFAULT ((0)) FOR [CantidadMinima]
GO

ALTER TABLE [dbo].[Inventario] ADD  DEFAULT (getdate()) FOR [FechaActualizacion]
GO

ALTER TABLE [dbo].[MensajesChat] ADD  DEFAULT (getdate()) FOR [FechaHora]
GO

ALTER TABLE [dbo].[MensajesContacto] ADD  CONSTRAINT [DF_MensajesContacto_Telefono]  DEFAULT ('') FOR [Telefono]
GO

ALTER TABLE [dbo].[MensajesContacto] ADD  CONSTRAINT [DF_MensajesContacto_Estado]  DEFAULT ('Nuevo') FOR [Estado]
GO

ALTER TABLE [dbo].[MensajesContacto] ADD  CONSTRAINT [DF_MensajesContacto_Fecha]  DEFAULT (getdate()) FOR [FechaEnvio]
GO

ALTER TABLE [dbo].[Notificaciones] ADD  DEFAULT ((0)) FOR [Leida]
GO

ALTER TABLE [dbo].[Notificaciones] ADD  DEFAULT (getdate()) FOR [FechaEnvio]
GO

ALTER TABLE [dbo].[Notificaciones] ADD  CONSTRAINT [DF_Notificaciones_Tipo]  DEFAULT ('General') FOR [Tipo]
GO

ALTER TABLE [dbo].[Notificaciones] ADD  CONSTRAINT [DF_Notificaciones_Titulo]  DEFAULT ('Notificacion') FOR [Titulo]
GO

ALTER TABLE [dbo].[Pagos] ADD  DEFAULT (getdate()) FOR [FechaPago]
GO

ALTER TABLE [dbo].[Pedidos] ADD  DEFAULT (getdate()) FOR [FechaPedido]
GO

ALTER TABLE [dbo].[Pedidos] ADD  DEFAULT ('Pendiente') FOR [Estado]
GO

ALTER TABLE [dbo].[Permisos] ADD  CONSTRAINT [DF_Permisos_Descripcion]  DEFAULT ('') FOR [Descripcion]
GO

ALTER TABLE [dbo].[Permisos] ADD  CONSTRAINT [DF_Permisos_Estado]  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[PreferenciasUsuario] ADD  CONSTRAINT [DF_PreferenciasUsuario_Notificaciones]  DEFAULT ((1)) FOR [NotificacionesActivas]
GO

ALTER TABLE [dbo].[PreferenciasUsuario] ADD  CONSTRAINT [DF_PreferenciasUsuario_Correo]  DEFAULT ((1)) FOR [NotificacionesCorreo]
GO

ALTER TABLE [dbo].[PreferenciasUsuario] ADD  CONSTRAINT [DF_PreferenciasUsuario_Tema]  DEFAULT ('claro') FOR [Tema]
GO

ALTER TABLE [dbo].[PreferenciasUsuario] ADD  CONSTRAINT [DF_PreferenciasUsuario_Fecha]  DEFAULT (getdate()) FOR [FechaActualizacion]
GO

ALTER TABLE [dbo].[Productos] ADD  DEFAULT ((0)) FOR [Stock]
GO

ALTER TABLE [dbo].[Productos] ADD  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[Productos] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO

ALTER TABLE [dbo].[Productos] ADD  CONSTRAINT [DF_Productos_Tamano]  DEFAULT ('No especificado') FOR [Tamano]
GO

ALTER TABLE [dbo].[Productos] ADD  CONSTRAINT [DF_Productos_Material]  DEFAULT ('No especificado') FOR [Material]
GO

ALTER TABLE [dbo].[Productos] ADD  CONSTRAINT [DF_Productos_Caracteristicas]  DEFAULT ('') FOR [Caracteristicas]
GO

ALTER TABLE [dbo].[ProductoVariantes] ADD  CONSTRAINT [DF_ProductoVariantes_Tamano]  DEFAULT ('No especificado') FOR [Tamano]
GO

ALTER TABLE [dbo].[ProductoVariantes] ADD  CONSTRAINT [DF_ProductoVariantes_Material]  DEFAULT ('No especificado') FOR [Material]
GO

ALTER TABLE [dbo].[ProductoVariantes] ADD  CONSTRAINT [DF_ProductoVariantes_Stock]  DEFAULT ((0)) FOR [Stock]
GO

ALTER TABLE [dbo].[ProductoVariantes] ADD  CONSTRAINT [DF_ProductoVariantes_Estado]  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[ProductoVariantes] ADD  CONSTRAINT [DF_ProductoVariantes_FechaRegistro]  DEFAULT (getdate()) FOR [FechaRegistro]
GO

ALTER TABLE [dbo].[TiposProducto] ADD  CONSTRAINT [DF_TiposProducto_Descripcion]  DEFAULT ('') FOR [Descripcion]
GO

ALTER TABLE [dbo].[TiposProducto] ADD  CONSTRAINT [DF_TiposProducto_Estado]  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[Usuarios] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO

ALTER TABLE [dbo].[Ventas] ADD  DEFAULT (getdate()) FOR [FechaVenta]
GO

ALTER TABLE [dbo].[Visualizaciones] ADD  CONSTRAINT [DF_Visualizaciones_FechaCreacion]  DEFAULT (sysdatetime()) FOR [FechaCreacion]
GO

ALTER TABLE [dbo].[Visualizaciones] ADD  CONSTRAINT [DF_Visualizaciones_FechaActualizacion]  DEFAULT (sysdatetime()) FOR [FechaActualizacion]
GO

ALTER TABLE [dbo].[Visualizaciones] ADD  CONSTRAINT [DF_Visualizaciones_Estado]  DEFAULT ('Activo') FOR [Estado]
GO

ALTER TABLE [dbo].[VisualizacionProductos] ADD  CONSTRAINT [DF_VisualizacionProductos_Cantidad]  DEFAULT ((1)) FOR [Cantidad]
GO

ALTER TABLE [dbo].[VisualizacionProductos] ADD  CONSTRAINT [DF_VisualizacionProductos_Color]  DEFAULT ('') FOR [Color]
GO

ALTER TABLE [dbo].[VisualizacionProductos] ADD  CONSTRAINT [DF_VisualizacionProductos_Macetero]  DEFAULT ('') FOR [Macetero]
GO

ALTER TABLE [dbo].[VisualizacionProductos] ADD  CONSTRAINT [DF_VisualizacionProductos_Rotacion]  DEFAULT ((0)) FOR [Rotacion]
GO

ALTER TABLE [dbo].[VisualizacionProductos] ADD  CONSTRAINT [DF_VisualizacionProductos_Orden]  DEFAULT ((1)) FOR [Orden]
GO

ALTER TABLE [dbo].[AsesorCriterios]  WITH CHECK ADD  CONSTRAINT [CK_AsesorCriterios_Peso] CHECK  (([Peso]>(0)))
GO

ALTER TABLE [dbo].[AsesorCriterios] CHECK CONSTRAINT [CK_AsesorCriterios_Peso]
GO

ALTER TABLE [dbo].[AsesorCriterios]  WITH CHECK ADD  CONSTRAINT [CK_AsesorCriterios_TieneCondicion] CHECK  (([IdCategoria] IS NOT NULL OR [IdTipo] IS NOT NULL OR [PalabraClave] IS NOT NULL))
GO

ALTER TABLE [dbo].[AsesorCriterios] CHECK CONSTRAINT [CK_AsesorCriterios_TieneCondicion]
GO

ALTER TABLE [dbo].[CategoriaClasificacion]  WITH CHECK ADD  CONSTRAINT [CK_CategoriaClasificacion_Clasificacion] CHECK  (([Clasificacion]='Otro' OR [Clasificacion]='Macetero' OR [Clasificacion]='Planta'))
GO

ALTER TABLE [dbo].[CategoriaClasificacion] CHECK CONSTRAINT [CK_CategoriaClasificacion_Clasificacion]
GO

ALTER TABLE [dbo].[CotizacionNotificaciones]  WITH CHECK ADD  CONSTRAINT [CK_CotizacionNotificaciones_Intentos] CHECK  (([Intentos]>=(0)))
GO

ALTER TABLE [dbo].[CotizacionNotificaciones] CHECK CONSTRAINT [CK_CotizacionNotificaciones_Intentos]
GO

ALTER TABLE [dbo].[SolicitudCotizacionProductos]  WITH CHECK ADD  CONSTRAINT [CK_SolicitudCotizacionProductos_Cantidad] CHECK  (([Cantidad]>(0)))
GO

ALTER TABLE [dbo].[SolicitudCotizacionProductos] CHECK CONSTRAINT [CK_SolicitudCotizacionProductos_Cantidad]
GO

ALTER TABLE [dbo].[Visualizaciones]  WITH CHECK ADD  CONSTRAINT [CK_Visualizaciones_Lienzo] CHECK  (([AnchoLienzo]>(0) AND [AltoLienzo]>(0)))
GO

ALTER TABLE [dbo].[Visualizaciones] CHECK CONSTRAINT [CK_Visualizaciones_Lienzo]
GO

ALTER TABLE [dbo].[VisualizacionProductos]  WITH CHECK ADD  CONSTRAINT [CK_VisualizacionProductos_Cantidad] CHECK  (([Cantidad]>(0)))
GO

ALTER TABLE [dbo].[VisualizacionProductos] CHECK CONSTRAINT [CK_VisualizacionProductos_Cantidad]
GO

ALTER TABLE [dbo].[VisualizacionProductos]  WITH CHECK ADD  CONSTRAINT [CK_VisualizacionProductos_Dimensiones] CHECK  (([Ancho]>(0) AND [Alto]>(0)))
GO

ALTER TABLE [dbo].[VisualizacionProductos] CHECK CONSTRAINT [CK_VisualizacionProductos_Dimensiones]
GO

-- ============================================================================
-- Datos
-- ============================================================================

SET IDENTITY_INSERT [dbo].[AsesorCriterios] ON
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (13, 1, NULL, NULL, N'lavanda', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (14, 1, NULL, NULL, N'rosal', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (15, 1, NULL, NULL, N'hibiscus', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (16, 1, NULL, NULL, N'bugambilia', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (7, 2, NULL, NULL, N'sansevieria', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (8, 2, NULL, NULL, N'pothos', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (9, 2, NULL, NULL, N'sombra', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (24, 3, NULL, NULL, N'rosal', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (25, 3, NULL, NULL, N'hibiscus', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (26, 3, NULL, NULL, N'ficus', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (27, 3, NULL, NULL, N'bugambilia', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (35, 4, NULL, NULL, N'decorativa', 4)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (36, 4, NULL, NULL, N'marmol', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (37, 4, NULL, NULL, N'premium', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (1, 5, 2, NULL, NULL, 5)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (2, 5, 4, NULL, NULL, 5)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (5, 5, NULL, 2, NULL, 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (3, 6, 1, NULL, NULL, 5)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (4, 6, 3, NULL, NULL, 5)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (6, 6, NULL, 1, NULL, 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (10, 7, NULL, NULL, N'monstera', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (11, 7, NULL, NULL, N'ficus', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (12, 7, NULL, NULL, N'palma', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (28, 8, NULL, NULL, N'minimalista', 4)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (29, 8, NULL, NULL, N'ceramica', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (30, 8, NULL, NULL, N'blanca', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (31, 8, NULL, NULL, N'negra', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (21, 9, NULL, NULL, N'monstera', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (22, 9, NULL, NULL, N'palma', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (23, 9, NULL, NULL, N'lavanda', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (32, 10, NULL, NULL, N'terracota', 4)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (33, 10, NULL, NULL, N'natural', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (34, 10, NULL, NULL, N'concreto', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (17, 11, NULL, NULL, N'sansevieria', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (18, 11, NULL, NULL, N'pothos', 3)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (19, 11, NULL, NULL, N'facil', 2)
GO

INSERT [dbo].[AsesorCriterios] ([IdCriterio], [IdOpcion], [IdCategoria], [IdTipo], [PalabraClave], [Peso]) VALUES (20, 11, NULL, NULL, N'cipres', 2)
GO

SET IDENTITY_INSERT [dbo].[AsesorCriterios] OFF
GO

SET IDENTITY_INSERT [dbo].[AsesorOpciones] ON
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (1, 3, N'alta', N'Luz alta', N'Sol directo durante varias horas.', 3, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (2, 3, N'baja', N'Luz baja', N'Espacios con poca luz natural directa.', 1, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (3, 4, N'bastante', N'Bastante tiempo', N'Disfruto el cuidado frecuente de mis plantas.', 3, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (4, 2, N'decorativo', N'Decorativo', N'Piezas llamativas con acabado premium.', 3, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (5, 1, N'exterior', N'Exterior', N'Jardines, terrazas y balcones abiertos.', 2, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (6, 1, N'interior', N'Interior', N'Salas, oficinas y habitaciones techadas.', 1, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (7, 3, N'media', N'Luz media', N'Luz indirecta durante buena parte del dia.', 2, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (8, 2, N'minimalista', N'Minimalista', N'Lineas simples y acabados sobrios.', 1, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (9, 4, N'moderado', N'Tiempo moderado', N'Puedo dedicar un rato cada semana.', 2, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (10, 2, N'natural', N'Natural', N'Materiales calidos como terracota y concreto.', 2, N'Activo')
GO

INSERT [dbo].[AsesorOpciones] ([IdOpcion], [IdPregunta], [Codigo], [Etiqueta], [Descripcion], [Orden], [Estado]) VALUES (11, 4, N'poco', N'Poco tiempo', N'Prefiero especies que casi se cuidan solas.', 1, N'Activo')
GO

SET IDENTITY_INSERT [dbo].[AsesorOpciones] OFF
GO

SET IDENTITY_INSERT [dbo].[AsesorPreguntas] ON
GO

INSERT [dbo].[AsesorPreguntas] ([IdPregunta], [Codigo], [Texto], [Ayuda], [Orden], [Estado]) VALUES (1, N'espacio', N'Donde vas a colocar tus plantas o maceteros?', N'El tipo de espacio define las condiciones ambientales de la recomendacion.', 1, N'Activo')
GO

INSERT [dbo].[AsesorPreguntas] ([IdPregunta], [Codigo], [Texto], [Ayuda], [Orden], [Estado]) VALUES (2, N'estilo', N'Que estilo prefieres para tus maceteros?', N'El estilo orienta el acabado y el material de los maceteros.', 4, N'Activo')
GO

INSERT [dbo].[AsesorPreguntas] ([IdPregunta], [Codigo], [Texto], [Ayuda], [Orden], [Estado]) VALUES (3, N'luz', N'Cuanta luz natural recibe ese espacio?', N'La luz disponible determina que especies se adaptan mejor.', 2, N'Activo')
GO

INSERT [dbo].[AsesorPreguntas] ([IdPregunta], [Codigo], [Texto], [Ayuda], [Orden], [Estado]) VALUES (4, N'tiempo', N'Cuanto tiempo puedes dedicar al cuidado?', N'El tiempo disponible define el nivel de mantenimiento sugerido.', 3, N'Activo')
GO

SET IDENTITY_INSERT [dbo].[AsesorPreguntas] OFF
GO

SET IDENTITY_INSERT [dbo].[Bitacora] ON
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 3', CAST(N'2026-06-11T17:44:22.360' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 4', CAST(N'2026-06-11T17:55:18.360' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (5, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 5', CAST(N'2026-06-11T17:55:28.810' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (6, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 6', CAST(N'2026-06-11T17:55:28.810' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (7, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 7', CAST(N'2026-06-11T17:56:10.243' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 8', CAST(N'2026-06-11T18:00:25.953' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (9, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 9', CAST(N'2026-06-11T18:03:45.793' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (10, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 10', CAST(N'2026-06-11T18:03:45.797' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (11, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 11', CAST(N'2026-06-11T18:04:05.153' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (12, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 12', CAST(N'2026-06-11T18:04:07.870' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (13, 2, N'Usuarios', N'LOGIN', N'Evento de desarrollo 13', CAST(N'2026-06-11T18:05:07.477' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (14, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 14', CAST(N'2026-06-11T18:05:51.870' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (15, 3, N'Usuarios', N'LOGIN', N'Evento de desarrollo 15', CAST(N'2026-06-11T18:07:16.210' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (16, 11, N'Usuarios', N'LOGIN', N'Evento de desarrollo 16', CAST(N'2026-06-11T18:09:57.810' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (17, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 17', CAST(N'2026-06-11T18:10:48.390' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (18, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 18', CAST(N'2026-06-11T18:10:52.470' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (19, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 19', CAST(N'2026-06-11T18:10:52.473' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (20, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 20', CAST(N'2026-06-11T18:11:07.590' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (21, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 21', CAST(N'2026-06-11T18:11:07.597' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (22, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 22', CAST(N'2026-06-11T18:11:09.003' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (23, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 23', CAST(N'2026-06-11T18:11:09.003' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (24, 1, N'Usuarios', N'DELETE', N'Evento de desarrollo 24', CAST(N'2026-06-11T18:11:33.247' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (25, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 25', CAST(N'2026-06-11T18:11:34.767' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (26, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 26', CAST(N'2026-06-11T18:11:34.767' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (27, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 27', CAST(N'2026-06-11T18:11:43.770' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (28, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 28', CAST(N'2026-06-11T18:11:43.777' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (29, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 29', CAST(N'2026-06-11T18:11:45.207' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (30, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 30', CAST(N'2026-06-11T18:11:45.207' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (31, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 31', CAST(N'2026-06-11T18:18:35.057' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (32, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 32', CAST(N'2026-06-11T18:18:35.057' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (33, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 33', CAST(N'2026-06-11T18:24:36.580' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (34, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 34', CAST(N'2026-06-11T18:24:36.580' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1033, 2, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1033', CAST(N'2026-06-11T18:33:27.093' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1034, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1034', CAST(N'2026-06-11T18:33:59.863' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1035, 2, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1035', CAST(N'2026-06-11T18:38:55.050' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1036, 3, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1036', CAST(N'2026-06-11T19:03:36.303' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1037, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1037', CAST(N'2026-06-11T19:04:07.750' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1038, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1038', CAST(N'2026-06-11T19:04:15.830' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1039, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1039', CAST(N'2026-06-11T19:04:15.830' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1040, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1040', CAST(N'2026-06-11T19:04:20.143' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1041, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1041', CAST(N'2026-06-11T19:04:20.143' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1042, 2, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1042', CAST(N'2026-06-11T19:04:44.183' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1043, 3, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1043', CAST(N'2026-06-11T19:09:35.630' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1044, 2, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1044', CAST(N'2026-06-11T19:10:33.117' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1045, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1045', CAST(N'2026-06-11T19:11:46.457' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1046, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1046', CAST(N'2026-06-11T19:12:57.827' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1047, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1047', CAST(N'2026-06-11T19:12:57.830' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1048, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1048', CAST(N'2026-06-11T19:13:05.500' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1049, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1049', CAST(N'2026-06-11T19:13:34.240' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1050, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1050', CAST(N'2026-06-11T19:13:34.240' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1051, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1051', CAST(N'2026-06-11T19:13:59.327' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1052, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1052', CAST(N'2026-06-11T19:13:59.337' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1053, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1053', CAST(N'2026-06-11T19:14:00.760' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1054, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1054', CAST(N'2026-06-11T19:14:00.760' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1055, 1, N'Usuarios', N'DELETE', N'Evento de desarrollo 1055', CAST(N'2026-06-11T19:14:12.800' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1056, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1056', CAST(N'2026-06-11T19:14:13.940' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1057, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1057', CAST(N'2026-06-11T19:14:13.940' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1058, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1058', CAST(N'2026-06-11T19:14:51.350' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1059, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1059', CAST(N'2026-06-11T19:14:51.350' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1060, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1060', CAST(N'2026-06-11T19:14:59.100' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1061, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1061', CAST(N'2026-06-11T19:14:59.107' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1062, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1062', CAST(N'2026-06-11T19:15:00.420' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1063, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1063', CAST(N'2026-06-11T19:15:00.420' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1064, 12, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1064', CAST(N'2026-06-11T19:15:18.007' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1065, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1065', CAST(N'2026-06-11T19:15:27.057' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1066, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1066', CAST(N'2026-06-11T19:15:27.057' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1067, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1067', CAST(N'2026-06-11T19:15:54.907' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1068, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1068', CAST(N'2026-06-11T19:15:54.907' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1069, 12, N'Usuarios', N'CREATE', N'Evento de desarrollo 1069', CAST(N'2026-06-11T19:16:33.343' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1070, 12, N'Usuarios', N'INSERT', N'Evento de desarrollo 1070', CAST(N'2026-06-11T19:16:33.350' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1071, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1071', CAST(N'2026-06-11T19:16:34.873' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1072, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1072', CAST(N'2026-06-11T19:16:34.873' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1073, 13, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1073', CAST(N'2026-06-11T19:16:51.830' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1074, 12, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1074', CAST(N'2026-06-11T19:17:21.480' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1075, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1075', CAST(N'2026-06-11T19:17:25.600' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1076, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1076', CAST(N'2026-06-11T19:17:25.600' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1077, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1077', CAST(N'2026-06-11T19:17:42.933' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1078, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1078', CAST(N'2026-06-11T19:17:42.933' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1079, 3, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1079', CAST(N'2026-06-11T19:18:39.183' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1080, 12, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1080', CAST(N'2026-06-11T19:20:06.740' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1081, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1081', CAST(N'2026-06-11T19:20:10.527' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1082, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1082', CAST(N'2026-06-11T19:20:10.527' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1083, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1083', CAST(N'2026-06-11T19:20:16.467' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1084, 12, N'Usuarios', N'DELETE', N'Evento de desarrollo 1084', CAST(N'2026-06-11T19:20:41.393' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1085, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1085', CAST(N'2026-06-11T19:20:42.883' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1086, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1086', CAST(N'2026-06-11T19:20:42.883' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1087, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1087', CAST(N'2026-06-11T19:20:48.107' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1088, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1088', CAST(N'2026-06-11T19:20:48.107' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1089, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1089', CAST(N'2026-06-11T19:21:26.243' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1090, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1090', CAST(N'2026-06-11T19:21:29.757' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1091, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1091', CAST(N'2026-06-11T19:21:29.757' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1092, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1092', CAST(N'2026-06-11T19:21:36.363' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1093, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1093', CAST(N'2026-06-11T19:21:36.370' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1094, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1094', CAST(N'2026-06-11T19:21:37.583' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1095, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1095', CAST(N'2026-06-11T19:21:37.583' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1096, 1, N'Usuarios', N'DELETE', N'Evento de desarrollo 1096', CAST(N'2026-06-11T19:21:44.670' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1097, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1097', CAST(N'2026-06-11T19:21:45.667' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1098, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1098', CAST(N'2026-06-11T19:21:45.667' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1099, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1099', CAST(N'2026-06-11T19:21:47.400' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1100, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1100', CAST(N'2026-06-11T19:21:47.400' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1101, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1101', CAST(N'2026-06-11T19:21:54.187' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1102, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1102', CAST(N'2026-06-11T19:21:54.187' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1103, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1103', CAST(N'2026-06-11T19:22:09.540' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1104, 1, N'Usuarios', N'UPDATE', N'Evento de desarrollo 1104', CAST(N'2026-06-11T19:22:09.547' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1105, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1105', CAST(N'2026-06-11T19:22:10.957' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1106, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1106', CAST(N'2026-06-11T19:22:10.957' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1107, 12, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1107', CAST(N'2026-06-11T19:22:24.847' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1108, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1108', CAST(N'2026-06-11T19:22:28.457' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1109, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1109', CAST(N'2026-06-11T19:22:28.460' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1110, 2, N'Usuarios', N'DENIED', N'Evento de desarrollo 1110', CAST(N'2026-06-15T18:56:27.250' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1111, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1111', CAST(N'2026-06-15T18:57:08.840' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1112, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1112', CAST(N'2026-06-15T18:57:08.860' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1113, 2, N'Usuarios', N'DENIED', N'Evento de desarrollo 1113', CAST(N'2026-06-15T18:57:08.890' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1114, 2, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1114', CAST(N'2026-06-15T18:58:09.080' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1115, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1115', CAST(N'2026-06-15T18:58:14.743' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1116, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1116', CAST(N'2026-06-15T19:14:29.027' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1117, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1117', CAST(N'2026-06-15T19:14:29.113' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1118, 2, N'Usuarios', N'DENIED', N'Evento de desarrollo 1118', CAST(N'2026-06-15T19:14:29.157' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1119, 2, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1119', CAST(N'2026-06-15T19:15:54.010' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1120, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1120', CAST(N'2026-06-15T19:16:28.600' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1121, 1, N'Usuarios', N'LOGIN', N'Evento de desarrollo 1121', CAST(N'2026-06-23T23:51:08.320' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1122, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1122', CAST(N'2026-06-23T23:51:20.053' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1123, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1123', CAST(N'2026-06-23T23:51:20.053' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1124, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1124', CAST(N'2026-06-23T23:51:23.737' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1125, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 1125', CAST(N'2026-06-23T23:51:23.737' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1126, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1126', CAST(N'2026-07-03T01:05:07.247' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1127, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1127', CAST(N'2026-07-03T01:06:10.377' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1128, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1128', CAST(N'2026-07-03T01:06:59.313' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1129, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1129', CAST(N'2026-07-21T12:43:59.573' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1130, 13, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1130', CAST(N'2026-07-21T12:43:59.640' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1131, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1131', CAST(N'2026-07-21T12:43:59.667' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1132, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1132', CAST(N'2026-07-21T12:44:11.810' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1133, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1133', CAST(N'2026-07-21T12:44:27.670' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1134, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1134', CAST(N'2026-07-21T12:44:43.920' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1135, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1135', CAST(N'2026-07-21T12:45:01.650' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1136, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1136', CAST(N'2026-07-21T12:46:48.840' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1137, 13, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1137', CAST(N'2026-07-21T12:46:48.900' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1138, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1138', CAST(N'2026-07-21T12:46:48.920' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1139, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1139', CAST(N'2026-07-21T12:47:16.687' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1140, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1140', CAST(N'2026-07-21T12:48:11.627' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1141, 1, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1141', CAST(N'2026-07-21T12:49:42.380' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1142, 13, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1142', CAST(N'2026-07-21T12:49:42.450' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1143, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1143', CAST(N'2026-07-21T12:49:42.470' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1144, 13, N'Categorias', N'DENIED', N'Evento de desarrollo 1144', CAST(N'2026-07-21T12:49:42.633' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1145, 11, N'Categorias', N'DENIED', N'Evento de desarrollo 1145', CAST(N'2026-07-21T12:49:42.677' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1146, 13, N'Categorias', N'DENIED', N'Evento de desarrollo 1146', CAST(N'2026-07-21T12:49:42.707' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1147, 11, N'Categorias', N'DENIED', N'Evento de desarrollo 1147', CAST(N'2026-07-21T12:49:42.713' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1149, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1149', CAST(N'2026-07-23T03:33:33.967' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1150, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1150', CAST(N'2026-07-23T03:34:04.707' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1151, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1151', CAST(N'2026-07-23T03:34:33.377' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1152, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1152', CAST(N'2026-07-23T03:35:14.907' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1153, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1153', CAST(N'2026-07-23T03:36:06.383' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1154, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1154', CAST(N'2026-07-23T03:36:06.407' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1158, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 1158', CAST(N'2026-07-23T08:07:45.737' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1190, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 1190', CAST(N'2026-07-23T08:19:22.203' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1203, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1203', CAST(N'2026-07-23T08:40:13.067' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1204, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1204', CAST(N'2026-07-23T08:40:30.283' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1205, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1205', CAST(N'2026-07-23T08:40:30.370' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1210, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1210', CAST(N'2026-07-23T08:45:20.760' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1211, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1211', CAST(N'2026-07-23T08:45:21.940' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1212, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1212', CAST(N'2026-07-23T09:56:44.923' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1213, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1213', CAST(N'2026-07-23T09:57:02.000' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1214, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1214', CAST(N'2026-07-23T09:58:06.590' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1215, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1215', CAST(N'2026-07-23T09:58:24.707' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1216, 11, N'Pedidos', N'INSERT', N'Evento de desarrollo 1216', CAST(N'2026-07-23T09:59:40.573' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1217, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1217', CAST(N'2026-07-23T10:00:07.980' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1218, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1218', CAST(N'2026-07-23T10:00:32.050' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1219, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1219', CAST(N'2026-07-23T10:00:34.593' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1220, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1220', CAST(N'2026-07-23T10:01:09.847' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1221, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1221', CAST(N'2026-07-23T10:02:07.013' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1222, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1222', CAST(N'2026-07-23T10:02:07.013' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1223, 12, N'Permisos', N'ACCESS', N'Evento de desarrollo 1223', CAST(N'2026-07-23T10:02:24.630' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1224, 13, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1224', CAST(N'2026-07-23T10:03:13.707' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1225, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1225', CAST(N'2026-07-23T10:20:03.940' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1226, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1226', CAST(N'2026-07-23T10:20:21.737' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1227, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1227', CAST(N'2026-07-23T10:21:13.770' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1228, 11, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1228', CAST(N'2026-07-23T10:21:13.837' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1229, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1229', CAST(N'2026-07-23T10:22:40.943' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1230, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1230', CAST(N'2026-07-23T10:26:02.267' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1231, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1231', CAST(N'2026-07-23T10:26:13.213' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1232, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1232', CAST(N'2026-07-23T10:45:47.417' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1233, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 1233', CAST(N'2026-07-23T10:45:47.473' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1234, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1234', CAST(N'2026-07-23T10:46:10.003' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1235, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1235', CAST(N'2026-07-23T10:46:10.013' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1236, 11, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1236', CAST(N'2026-07-23T10:46:10.143' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1237, 12, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1237', CAST(N'2026-07-23T10:46:10.197' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1238, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1238', CAST(N'2026-07-23T10:46:10.300' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1239, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1239', CAST(N'2026-07-23T10:46:39.253' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1240, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1240', CAST(N'2026-07-23T10:46:39.263' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1241, 11, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1241', CAST(N'2026-07-23T10:46:39.273' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1242, 12, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1242', CAST(N'2026-07-23T10:46:39.283' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1243, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1243', CAST(N'2026-07-23T10:46:39.290' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1244, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1244', CAST(N'2026-07-23T11:03:23.870' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1245, 11, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1245', CAST(N'2026-07-23T11:03:24.087' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1246, 1, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1246', CAST(N'2026-07-23T11:58:21.343' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1247, 1, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1247', CAST(N'2026-07-23T11:58:45.750' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1248, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1248', CAST(N'2026-07-23T12:16:47.617' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1249, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1249', CAST(N'2026-07-23T12:16:48.687' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1250, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1250', CAST(N'2026-07-23T12:16:50.920' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1251, 2, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1251', CAST(N'2026-07-23T12:16:50.950' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1252, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1252', CAST(N'2026-07-23T12:19:48.927' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1253, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1253', CAST(N'2026-07-23T12:19:52.300' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1254, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1254', CAST(N'2026-07-23T12:19:59.040' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1255, 2, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1255', CAST(N'2026-07-23T12:19:59.067' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1256, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1256', CAST(N'2026-07-23T12:21:47.207' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1257, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1257', CAST(N'2026-07-23T12:21:54.580' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1258, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1258', CAST(N'2026-07-23T12:22:06.180' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1259, 2, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1259', CAST(N'2026-07-23T12:22:06.213' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1260, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1260', CAST(N'2026-07-23T12:24:14.383' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1261, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1261', CAST(N'2026-07-23T12:24:24.710' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1262, 2, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1262', CAST(N'2026-07-23T12:24:35.150' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1263, 2, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1263', CAST(N'2026-07-23T12:24:35.187' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1267, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 1267', CAST(N'2026-07-23T13:18:34.820' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1312, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 1312', CAST(N'2026-07-23T13:35:44.867' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1326, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 1326', CAST(N'2026-07-23T15:08:15.057' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1327, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1327', CAST(N'2026-07-23T15:08:32.697' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1328, 11, N'Pedidos', N'INSERT', N'Evento de desarrollo 1328', CAST(N'2026-07-23T15:11:07.377' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1329, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1329', CAST(N'2026-07-23T15:11:55.440' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1330, 11, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1330', CAST(N'2026-07-23T15:14:03.367' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1331, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1331', CAST(N'2026-07-23T15:15:15.360' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1332, 12, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1332', CAST(N'2026-07-23T15:15:58.167' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1333, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1333', CAST(N'2026-07-23T15:16:36.853' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1334, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1334', CAST(N'2026-07-23T15:16:51.317' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1335, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1335', CAST(N'2026-07-23T15:18:06.833' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1336, 12, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1336', CAST(N'2026-07-23T15:18:30.417' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1337, 12, N'Productos', N'UPDATE', N'Evento de desarrollo 1337', CAST(N'2026-07-23T15:19:13.267' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1338, 12, N'Productos', N'SUCCESS', N'Evento de desarrollo 1338', CAST(N'2026-07-23T15:19:13.297' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1339, 12, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1339', CAST(N'2026-07-23T15:19:25.080' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1340, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1340', CAST(N'2026-07-23T15:19:28.780' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1341, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1341', CAST(N'2026-07-23T15:19:40.937' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1342, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1342', CAST(N'2026-07-23T15:20:23.890' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1343, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1343', CAST(N'2026-07-23T15:20:23.890' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1344, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1344', CAST(N'2026-07-23T15:20:37.993' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1345, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1345', CAST(N'2026-07-23T15:21:07.773' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1346, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1346', CAST(N'2026-07-23T15:21:28.290' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1347, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1347', CAST(N'2026-07-23T15:23:08.300' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1348, 11, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1348', CAST(N'2026-07-23T15:23:45.720' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1349, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1349', CAST(N'2026-07-23T15:24:51.187' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1350, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1350', CAST(N'2026-07-23T15:25:16.487' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1351, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1351', CAST(N'2026-07-23T15:25:35.843' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1355, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1355', CAST(N'2026-07-23T18:01:27.343' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1356, 11, N'Cotizaciones', N'CREATE', N'Evento de desarrollo 1356', CAST(N'2026-07-23T18:02:18.560' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1357, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1357', CAST(N'2026-07-23T18:02:43.490' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1358, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1358', CAST(N'2026-07-23T18:02:49.843' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1359, 12, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1359', CAST(N'2026-07-23T18:03:27.943' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1360, 11, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1360', CAST(N'2026-07-23T18:04:00.340' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1361, 11, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1361', CAST(N'2026-07-23T18:04:18.927' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1362, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1362', CAST(N'2026-07-23T18:04:43.213' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1363, 12, N'Cotizaciones', N'UPDATE', N'Evento de desarrollo 1363', CAST(N'2026-07-23T18:05:31.103' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1379, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 1379', CAST(N'2026-08-12T23:05:23.413' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1380, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1380', CAST(N'2026-08-12T23:05:29.947' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1381, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1381', CAST(N'2026-08-12T23:05:36.510' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1382, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 1382', CAST(N'2026-08-12T23:05:48.050' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1383, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 1383', CAST(N'2026-08-12T23:05:48.053' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1384, 12, N'Permisos', N'ACCESS', N'Evento de desarrollo 1384', CAST(N'2026-08-12T23:05:58.270' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1385, 12, N'Permisos', N'ACCESS', N'Evento de desarrollo 1385', CAST(N'2026-08-12T23:06:03.380' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1386, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1386', CAST(N'2026-08-12T23:06:34.057' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1387, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 1387', CAST(N'2026-08-12T23:06:39.527' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1388, 12, N'Chats', N'UPDATE', N'Evento de desarrollo 1388', CAST(N'2026-08-12T23:07:26.790' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1389, 12, N'MensajesChat', N'CREATE', N'Evento de desarrollo 1389', CAST(N'2026-08-12T23:08:08.580' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1391, 1, N'Productos', N'DUPLICATE', N'Evento de desarrollo 1391', CAST(N'2026-08-13T10:55:21.317' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (1392, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 1392', CAST(N'2026-08-13T10:55:21.327' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2391, 1, N'Productos', N'DUPLICATE', N'Evento de desarrollo 2391', CAST(N'2026-08-13T10:56:08.390' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2392, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 2392', CAST(N'2026-08-13T10:56:08.397' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2393, 1, N'Productos', N'UPDATE', N'Evento de desarrollo 2393', CAST(N'2026-08-13T10:56:40.880' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2394, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 2394', CAST(N'2026-08-13T10:56:40.900' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2395, 3, N'Productos', N'DENIED', N'Evento de desarrollo 2395', CAST(N'2026-08-13T10:57:07.237' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2396, 1, N'Productos', N'DENIED', N'Evento de desarrollo 2396', CAST(N'2026-08-13T10:57:07.263' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2397, 1, N'Chats', N'UPDATE', N'Evento de desarrollo 2397', CAST(N'2026-08-13T10:57:07.293' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2398, 1, N'Productos', N'DENIED', N'Evento de desarrollo 2398', CAST(N'2026-08-13T10:57:36.680' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2399, 1, N'Productos', N'UPDATE', N'Evento de desarrollo 2399', CAST(N'2026-08-13T10:57:54.610' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2400, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 2400', CAST(N'2026-08-13T10:57:54.613' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2401, 1, N'Productos', N'DENIED', N'Evento de desarrollo 2401', CAST(N'2026-08-13T10:57:54.620' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2402, 1, N'Productos', N'DENIED', N'Evento de desarrollo 2402', CAST(N'2026-08-13T10:57:54.630' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2403, 1, N'Productos', N'UPDATE', N'Evento de desarrollo 2403', CAST(N'2026-08-13T10:57:54.633' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (2404, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 2404', CAST(N'2026-08-13T10:57:54.637' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3391, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 3391', CAST(N'2026-08-13T11:19:06.187' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3392, 1, N'Usuarios', N'DENIED', N'Evento de desarrollo 3392', CAST(N'2026-08-13T11:19:06.210' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3393, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 3393', CAST(N'2026-08-13T11:19:06.217' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3394, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 3394', CAST(N'2026-08-13T11:19:06.290' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3395, 1, N'Usuarios', N'DENIED', N'Evento de desarrollo 3395', CAST(N'2026-08-13T11:19:06.293' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3396, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 3396', CAST(N'2026-08-13T11:19:06.303' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3397, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 3397', CAST(N'2026-08-13T11:19:06.350' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3398, 1, N'Usuarios', N'DENIED', N'Evento de desarrollo 3398', CAST(N'2026-08-13T11:19:06.350' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3399, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 3399', CAST(N'2026-08-13T11:19:06.363' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3400, 1, N'Usuarios', N'DENIED', N'Evento de desarrollo 3400', CAST(N'2026-08-13T11:19:06.370' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3401, 3, N'Roles', N'DENIED', N'Evento de desarrollo 3401', CAST(N'2026-08-13T11:19:06.390' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3402, 1, N'Roles', N'DENIED', N'Evento de desarrollo 3402', CAST(N'2026-08-13T11:19:06.397' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3403, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 3403', CAST(N'2026-08-13T11:19:06.400' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3404, 3, N'Permisos', N'DENIED', N'Evento de desarrollo 3404', CAST(N'2026-08-13T11:19:06.420' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3405, 1, N'Permisos', N'DENIED', N'Evento de desarrollo 3405', CAST(N'2026-08-13T11:19:06.423' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3406, 1, N'Permisos', N'ACCESS', N'Evento de desarrollo 3406', CAST(N'2026-08-13T11:19:06.427' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3407, 3, N'Bitacora', N'DENIED', N'Evento de desarrollo 3407', CAST(N'2026-08-13T11:19:06.480' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3408, 1, N'Bitacora', N'DENIED', N'Evento de desarrollo 3408', CAST(N'2026-08-13T11:19:06.483' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3409, 3, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3409', CAST(N'2026-08-13T11:19:06.520' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3410, 1, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3410', CAST(N'2026-08-13T11:19:06.523' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3411, 3, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3411', CAST(N'2026-08-13T11:19:06.570' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3412, 1, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3412', CAST(N'2026-08-13T11:19:06.570' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3413, 3, N'Reportes', N'DENIED', N'Evento de desarrollo 3413', CAST(N'2026-08-13T11:19:06.810' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3414, 1, N'Reportes', N'ACCESS', N'Evento de desarrollo 3414', CAST(N'2026-08-13T11:19:06.837' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3415, 1, N'Reportes', N'ACCESS', N'Evento de desarrollo 3415', CAST(N'2026-08-13T11:19:06.850' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3416, 3, N'Reportes', N'DENIED', N'Evento de desarrollo 3416', CAST(N'2026-08-13T11:19:06.867' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3417, 3, N'Pedidos', N'DENIED', N'Evento de desarrollo 3417', CAST(N'2026-08-13T11:19:06.903' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3418, 1, N'Pedidos', N'DENIED', N'Evento de desarrollo 3418', CAST(N'2026-08-13T11:19:06.910' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3419, 1, N'Pedidos', N'ACCESS', N'Evento de desarrollo 3419', CAST(N'2026-08-13T11:19:06.923' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3420, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 3420', CAST(N'2026-08-13T11:19:06.943' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3421, 1, N'Categorias', N'DENIED', N'Evento de desarrollo 3421', CAST(N'2026-08-13T11:19:06.950' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3422, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 3422', CAST(N'2026-08-13T11:19:06.973' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3423, 1, N'Categorias', N'DENIED', N'Evento de desarrollo 3423', CAST(N'2026-08-13T11:19:06.977' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3424, 1, N'Categorias', N'CREATE', N'Evento de desarrollo 3424', CAST(N'2026-08-13T11:19:06.980' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3425, 1, N'Categorias', N'SUCCESS', N'Evento de desarrollo 3425', CAST(N'2026-08-13T11:19:06.987' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3426, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 3426', CAST(N'2026-08-13T11:19:07.003' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3427, 1, N'Categorias', N'DENIED', N'Evento de desarrollo 3427', CAST(N'2026-08-13T11:19:07.010' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3428, 1, N'Categorias', N'DELETE', N'Evento de desarrollo 3428', CAST(N'2026-08-13T11:19:07.010' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3429, 1, N'Categorias', N'FAILED', N'Evento de desarrollo 3429', CAST(N'2026-08-13T11:19:07.017' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3430, 3, N'TiposProducto', N'DENIED', N'Evento de desarrollo 3430', CAST(N'2026-08-13T11:19:07.030' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3431, 1, N'TiposProducto', N'DENIED', N'Evento de desarrollo 3431', CAST(N'2026-08-13T11:19:07.033' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3432, 3, N'Productos', N'DENIED', N'Evento de desarrollo 3432', CAST(N'2026-08-13T11:19:07.063' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3433, 1, N'Productos', N'DENIED', N'Evento de desarrollo 3433', CAST(N'2026-08-13T11:19:07.070' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3434, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3434', CAST(N'2026-08-13T11:19:07.073' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3435, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 3435', CAST(N'2026-08-13T11:19:07.090' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3436, 3, N'Productos', N'DENIED', N'Evento de desarrollo 3436', CAST(N'2026-08-13T11:19:07.107' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3437, 1, N'Productos', N'DENIED', N'Evento de desarrollo 3437', CAST(N'2026-08-13T11:19:07.110' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3438, 1, N'Productos', N'DELETE', N'Evento de desarrollo 3438', CAST(N'2026-08-13T11:19:07.113' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3439, 1, N'Productos', N'FAILED', N'Evento de desarrollo 3439', CAST(N'2026-08-13T11:19:07.120' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3440, 3, N'Productos', N'DENIED', N'Evento de desarrollo 3440', CAST(N'2026-08-13T11:19:07.133' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3441, 1, N'Productos', N'FAILED', N'Evento de desarrollo 3441', CAST(N'2026-08-13T11:19:07.147' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3442, 1, N'Productos', N'FAILED', N'Evento de desarrollo 3442', CAST(N'2026-08-13T11:19:07.150' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3443, 3, N'Empresa', N'DENIED', N'Evento de desarrollo 3443', CAST(N'2026-08-13T11:19:07.310' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3444, 1, N'Empresa', N'DENIED', N'Evento de desarrollo 3444', CAST(N'2026-08-13T11:19:07.317' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3445, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 3445', CAST(N'2026-08-13T11:20:17.237' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3446, 3, N'Usuarios', N'ACCESS', N'Evento de desarrollo 3446', CAST(N'2026-08-13T11:20:17.290' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3447, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 3447', CAST(N'2026-08-13T11:20:17.293' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3448, 3, N'Usuarios', N'ACCESS', N'Evento de desarrollo 3448', CAST(N'2026-08-13T11:20:17.333' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3449, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 3449', CAST(N'2026-08-13T11:20:17.350' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3450, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3450', CAST(N'2026-08-13T11:20:17.530' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3451, 1, N'Productos', N'ERROR', N'Evento de desarrollo 3451', CAST(N'2026-08-13T11:20:17.537' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3452, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3452', CAST(N'2026-08-13T11:20:17.540' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3453, 1, N'Productos', N'ERROR', N'Evento de desarrollo 3453', CAST(N'2026-08-13T11:20:17.547' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3454, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3454', CAST(N'2026-08-13T11:20:17.550' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3455, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 3455', CAST(N'2026-08-13T11:20:17.550' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3456, 12, N'Reportes', N'ACCESS', N'Evento de desarrollo 3456', CAST(N'2026-08-13T11:22:36.973' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3457, 12, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3457', CAST(N'2026-08-13T11:22:36.980' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3458, 12, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3458', CAST(N'2026-08-13T11:23:03.717' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3459, 12, N'Reportes', N'ACCESS', N'Evento de desarrollo 3459', CAST(N'2026-08-13T11:23:03.717' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3460, 12, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3460', CAST(N'2026-08-13T11:23:27.833' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3461, 12, N'Reportes', N'ACCESS', N'Evento de desarrollo 3461', CAST(N'2026-08-13T11:23:27.833' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3462, 12, N'Productos', N'DUPLICATE', N'Evento de desarrollo 3462', CAST(N'2026-08-13T11:25:14.633' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3463, 12, N'Productos', N'DUPLICATE', N'Evento de desarrollo 3463', CAST(N'2026-08-13T11:25:14.633' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3464, 12, N'Productos', N'SUCCESS', N'Evento de desarrollo 3464', CAST(N'2026-08-13T11:25:14.637' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3465, 12, N'Productos', N'SUCCESS', N'Evento de desarrollo 3465', CAST(N'2026-08-13T11:25:14.637' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3466, 12, N'Usuarios', N'DENIED', N'Evento de desarrollo 3466', CAST(N'2026-08-13T11:26:24.557' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3467, 12, N'Roles', N'DENIED', N'Evento de desarrollo 3467', CAST(N'2026-08-13T11:26:24.557' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3468, 12, N'Usuarios', N'DENIED', N'Evento de desarrollo 3468', CAST(N'2026-08-13T11:26:26.560' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3469, 12, N'Bitacora', N'DENIED', N'Evento de desarrollo 3469', CAST(N'2026-08-13T11:26:26.563' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3470, 3, N'Reportes', N'DENIED', N'Evento de desarrollo 3470', CAST(N'2026-08-13T16:18:01.507' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3471, 1, N'Reportes', N'DENIED', N'Evento de desarrollo 3471', CAST(N'2026-08-13T16:18:01.530' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3472, 1, N'Reportes', N'ACCESS', N'Evento de desarrollo 3472', CAST(N'2026-08-13T16:18:01.577' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3473, 3, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3473', CAST(N'2026-08-13T16:18:01.650' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3474, 1, N'Estadisticas', N'DENIED', N'Evento de desarrollo 3474', CAST(N'2026-08-13T16:18:01.653' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3475, 3, N'Bitacora', N'DENIED', N'Evento de desarrollo 3475', CAST(N'2026-08-13T16:18:01.687' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3476, 1, N'Bitacora', N'DENIED', N'Evento de desarrollo 3476', CAST(N'2026-08-13T16:18:01.690' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3477, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 3477', CAST(N'2026-08-13T16:18:01.740' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3478, 1, N'Usuarios', N'DENIED', N'Evento de desarrollo 3478', CAST(N'2026-08-13T16:18:01.743' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3479, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 3479', CAST(N'2026-08-13T16:18:01.750' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3480, 3, N'Roles', N'DENIED', N'Evento de desarrollo 3480', CAST(N'2026-08-13T16:18:01.773' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3481, 1, N'Roles', N'DENIED', N'Evento de desarrollo 3481', CAST(N'2026-08-13T16:18:01.780' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3482, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 3482', CAST(N'2026-08-13T16:18:01.783' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3483, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 3483', CAST(N'2026-08-13T16:18:01.807' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3484, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 3484', CAST(N'2026-08-13T16:18:01.870' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3485, 1, N'Categorias', N'CREATE', N'Evento de desarrollo 3485', CAST(N'2026-08-13T16:18:01.873' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3486, 1, N'Categorias', N'SUCCESS', N'Evento de desarrollo 3486', CAST(N'2026-08-13T16:18:01.880' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3487, 1, N'Categorias', N'CREATE', N'Evento de desarrollo 3487', CAST(N'2026-08-13T16:18:01.893' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3488, 1, N'Categorias', N'FAILED', N'Evento de desarrollo 3488', CAST(N'2026-08-13T16:18:01.897' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3489, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 3489', CAST(N'2026-08-13T16:18:01.907' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3490, 1, N'Categorias', N'DELETE', N'Evento de desarrollo 3490', CAST(N'2026-08-13T16:18:01.910' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3491, 1, N'Categorias', N'FAILED', N'Evento de desarrollo 3491', CAST(N'2026-08-13T16:18:01.917' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3492, 1, N'Categorias', N'DELETE', N'Evento de desarrollo 3492', CAST(N'2026-08-13T16:18:01.920' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3493, 1, N'Categorias', N'FAILED', N'Evento de desarrollo 3493', CAST(N'2026-08-13T16:18:01.923' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3494, 3, N'Productos', N'DENIED', N'Evento de desarrollo 3494', CAST(N'2026-08-13T16:18:01.943' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3495, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3495', CAST(N'2026-08-13T16:18:01.950' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3496, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 3496', CAST(N'2026-08-13T16:18:01.970' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3497, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3497', CAST(N'2026-08-13T16:18:01.983' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3498, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 3498', CAST(N'2026-08-13T16:18:01.983' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3499, 3, N'Productos', N'DENIED', N'Evento de desarrollo 3499', CAST(N'2026-08-13T16:18:02.003' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3500, 1, N'Productos', N'DELETE', N'Evento de desarrollo 3500', CAST(N'2026-08-13T16:18:02.010' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3501, 1, N'Productos', N'FAILED', N'Evento de desarrollo 3501', CAST(N'2026-08-13T16:18:02.017' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3502, 1, N'Productos', N'DELETE', N'Evento de desarrollo 3502', CAST(N'2026-08-13T16:18:02.020' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3503, 1, N'Productos', N'FAILED', N'Evento de desarrollo 3503', CAST(N'2026-08-13T16:18:02.020' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3504, 3, N'MensajesContacto', N'DENIED', N'Evento de desarrollo 3504', CAST(N'2026-08-13T16:18:02.033' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3505, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3505', CAST(N'2026-08-13T16:18:02.263' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3506, 1, N'Productos', N'FAILED', N'Evento de desarrollo 3506', CAST(N'2026-08-13T16:18:02.267' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3507, 1, N'Productos', N'CREATE', N'Evento de desarrollo 3507', CAST(N'2026-08-13T16:18:02.283' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3508, 1, N'Productos', N'ERROR', N'Evento de desarrollo 3508', CAST(N'2026-08-13T16:18:02.290' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3509, 1, N'MensajesContacto', N'UPDATE', N'Evento de desarrollo 3509', CAST(N'2026-08-13T16:18:02.360' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3510, 1, N'MensajesContacto', N'REPLY', N'Evento de desarrollo 3510', CAST(N'2026-08-13T16:18:03.600' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3511, 3, N'MensajesContacto', N'DENIED', N'Evento de desarrollo 3511', CAST(N'2026-08-13T16:18:03.630' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3512, 1, N'Seguridad', N'DENIED', N'Evento de desarrollo 3512', CAST(N'2026-08-13T16:18:03.643' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (3513, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 3513', CAST(N'2026-08-13T16:18:03.657' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4470, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4470', CAST(N'2026-08-13T16:20:55.963' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4471, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4471', CAST(N'2026-08-13T16:20:56.370' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4472, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4472', CAST(N'2026-08-13T16:20:56.807' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4473, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4473', CAST(N'2026-08-13T16:20:57.227' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4474, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4474', CAST(N'2026-08-13T16:20:57.660' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4475, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4475', CAST(N'2026-08-13T16:20:58.097' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4476, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4476', CAST(N'2026-08-13T16:20:58.517' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4477, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4477', CAST(N'2026-08-13T16:20:58.940' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4478, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4478', CAST(N'2026-08-13T16:21:01.093' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4479, 12, N'Productos', N'DUPLICATE', N'Evento de desarrollo 4479', CAST(N'2026-08-13T16:21:23.930' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4480, 12, N'Productos', N'DUPLICATE', N'Evento de desarrollo 4480', CAST(N'2026-08-13T16:21:23.930' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4481, 12, N'Productos', N'DUPLICATE', N'Evento de desarrollo 4481', CAST(N'2026-08-13T16:21:23.930' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4482, 12, N'Productos', N'SUCCESS', N'Evento de desarrollo 4482', CAST(N'2026-08-13T16:21:23.933' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4483, 12, N'Productos', N'SUCCESS', N'Evento de desarrollo 4483', CAST(N'2026-08-13T16:21:23.933' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4484, 12, N'Productos', N'SUCCESS', N'Evento de desarrollo 4484', CAST(N'2026-08-13T16:21:23.933' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4485, 12, N'Productos', N'DUPLICATE', N'Evento de desarrollo 4485', CAST(N'2026-08-13T16:22:57.730' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4486, 12, N'Productos', N'SUCCESS', N'Evento de desarrollo 4486', CAST(N'2026-08-13T16:22:57.730' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4487, 12, N'Seguridad', N'DENIED', N'Evento de desarrollo 4487', CAST(N'2026-08-13T16:25:06.690' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4488, 3, N'Reportes', N'DENIED', N'Evento de desarrollo 4488', CAST(N'2026-08-13T16:31:03.110' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4489, 1, N'Reportes', N'DENIED', N'Evento de desarrollo 4489', CAST(N'2026-08-13T16:31:03.130' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4490, 1, N'Reportes', N'ACCESS', N'Evento de desarrollo 4490', CAST(N'2026-08-13T16:31:03.180' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4491, 3, N'Estadisticas', N'DENIED', N'Evento de desarrollo 4491', CAST(N'2026-08-13T16:31:03.260' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4492, 1, N'Estadisticas', N'DENIED', N'Evento de desarrollo 4492', CAST(N'2026-08-13T16:31:03.267' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4493, 3, N'Bitacora', N'DENIED', N'Evento de desarrollo 4493', CAST(N'2026-08-13T16:31:03.303' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4494, 1, N'Bitacora', N'DENIED', N'Evento de desarrollo 4494', CAST(N'2026-08-13T16:31:03.307' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4495, 3, N'Usuarios', N'DENIED', N'Evento de desarrollo 4495', CAST(N'2026-08-13T16:31:03.347' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4496, 1, N'Usuarios', N'DENIED', N'Evento de desarrollo 4496', CAST(N'2026-08-13T16:31:03.350' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4497, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 4497', CAST(N'2026-08-13T16:31:03.353' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4498, 3, N'Roles', N'DENIED', N'Evento de desarrollo 4498', CAST(N'2026-08-13T16:31:03.380' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4499, 1, N'Roles', N'DENIED', N'Evento de desarrollo 4499', CAST(N'2026-08-13T16:31:03.383' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4500, 1, N'Roles', N'ACCESS', N'Evento de desarrollo 4500', CAST(N'2026-08-13T16:31:03.390' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4501, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 4501', CAST(N'2026-08-13T16:31:03.410' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4502, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 4502', CAST(N'2026-08-13T16:31:03.463' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4503, 1, N'Categorias', N'CREATE', N'Evento de desarrollo 4503', CAST(N'2026-08-13T16:31:03.470' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4504, 1, N'Categorias', N'SUCCESS', N'Evento de desarrollo 4504', CAST(N'2026-08-13T16:31:03.477' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4505, 1, N'Categorias', N'CREATE', N'Evento de desarrollo 4505', CAST(N'2026-08-13T16:31:03.487' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4506, 1, N'Categorias', N'FAILED', N'Evento de desarrollo 4506', CAST(N'2026-08-13T16:31:03.490' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4507, 3, N'Categorias', N'DENIED', N'Evento de desarrollo 4507', CAST(N'2026-08-13T16:31:03.500' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4508, 1, N'Categorias', N'DELETE', N'Evento de desarrollo 4508', CAST(N'2026-08-13T16:31:03.503' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4509, 1, N'Categorias', N'FAILED', N'Evento de desarrollo 4509', CAST(N'2026-08-13T16:31:03.510' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4510, 1, N'Categorias', N'DELETE', N'Evento de desarrollo 4510', CAST(N'2026-08-13T16:31:03.513' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4511, 1, N'Categorias', N'FAILED', N'Evento de desarrollo 4511', CAST(N'2026-08-13T16:31:03.517' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4512, 3, N'Productos', N'DENIED', N'Evento de desarrollo 4512', CAST(N'2026-08-13T16:31:03.530' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4513, 1, N'Productos', N'CREATE', N'Evento de desarrollo 4513', CAST(N'2026-08-13T16:31:03.537' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4514, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 4514', CAST(N'2026-08-13T16:31:03.563' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4515, 1, N'Productos', N'CREATE', N'Evento de desarrollo 4515', CAST(N'2026-08-13T16:31:03.573' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4516, 1, N'Productos', N'SUCCESS', N'Evento de desarrollo 4516', CAST(N'2026-08-13T16:31:03.580' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4517, 3, N'Productos', N'DENIED', N'Evento de desarrollo 4517', CAST(N'2026-08-13T16:31:03.597' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4518, 1, N'Productos', N'DELETE', N'Evento de desarrollo 4518', CAST(N'2026-08-13T16:31:03.600' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4519, 1, N'Productos', N'FAILED', N'Evento de desarrollo 4519', CAST(N'2026-08-13T16:31:03.620' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4520, 1, N'Productos', N'DELETE', N'Evento de desarrollo 4520', CAST(N'2026-08-13T16:31:03.623' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4521, 1, N'Productos', N'FAILED', N'Evento de desarrollo 4521', CAST(N'2026-08-13T16:31:03.623' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4522, 3, N'MensajesContacto', N'DENIED', N'Evento de desarrollo 4522', CAST(N'2026-08-13T16:31:03.637' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4523, 1, N'Productos', N'CREATE', N'Evento de desarrollo 4523', CAST(N'2026-08-13T16:31:03.883' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4524, 1, N'Productos', N'FAILED', N'Evento de desarrollo 4524', CAST(N'2026-08-13T16:31:03.887' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4525, 1, N'MensajesContacto', N'UPDATE', N'Evento de desarrollo 4525', CAST(N'2026-08-13T16:31:03.963' AS DateTime), NULL)
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4526, 1, N'MensajesContacto', N'REPLY', N'Evento de desarrollo 4526', CAST(N'2026-08-13T16:31:05.233' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4527, 3, N'MensajesContacto', N'DENIED', N'Evento de desarrollo 4527', CAST(N'2026-08-13T16:31:05.253' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4528, 1, N'Seguridad', N'DENIED', N'Evento de desarrollo 4528', CAST(N'2026-08-13T16:31:05.263' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (4529, 1, N'Usuarios', N'ACCESS', N'Evento de desarrollo 4529', CAST(N'2026-08-13T16:31:05.277' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (6542, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 6542', CAST(N'2026-08-20T15:21:31.253' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8579, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 8579', CAST(N'2026-08-22T03:44:12.710' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8580, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 8580', CAST(N'2026-08-22T03:44:26.907' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8581, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 8581', CAST(N'2026-08-22T03:44:58.437' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8582, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 8582', CAST(N'2026-08-22T03:45:42.183' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8583, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 8583', CAST(N'2026-08-22T03:46:03.847' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8584, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 8584', CAST(N'2026-08-22T03:46:09.337' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8585, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8585', CAST(N'2026-08-22T03:46:09.337' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8586, NULL, N'Login', N'LOGIN_FAILED', N'Evento de desarrollo 8586', CAST(N'2026-08-22T03:50:40.107' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8587, 3034, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 8587', CAST(N'2026-08-22T03:51:59.793' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8588, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8588', CAST(N'2026-08-22T03:52:07.020' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8589, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8589', CAST(N'2026-08-22T03:52:09.153' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8590, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8590', CAST(N'2026-08-22T03:52:27.940' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8591, 3034, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 8591', CAST(N'2026-08-22T17:59:06.470' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8592, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8592', CAST(N'2026-08-22T17:59:11.567' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8593, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8593', CAST(N'2026-08-22T17:59:11.580' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8594, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8594', CAST(N'2026-08-22T17:59:30.260' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8595, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8595', CAST(N'2026-08-22T17:59:40.037' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8596, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8596', CAST(N'2026-08-22T17:59:44.363' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8597, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8597', CAST(N'2026-08-22T17:59:44.370' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8598, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8598', CAST(N'2026-08-22T17:59:58.633' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8599, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8599', CAST(N'2026-08-22T17:59:58.633' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8600, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8600', CAST(N'2026-08-22T18:00:04.837' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8601, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8601', CAST(N'2026-08-22T18:00:04.837' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8602, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8602', CAST(N'2026-08-22T18:00:08.080' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8603, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8603', CAST(N'2026-08-22T18:00:08.080' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8604, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 8604', CAST(N'2026-08-22T18:02:19.057' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8605, 12, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8605', CAST(N'2026-08-22T18:02:57.820' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8606, 12, N'Roles', N'ACCESS', N'Evento de desarrollo 8606', CAST(N'2026-08-22T18:03:13.060' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8607, 12, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8607', CAST(N'2026-08-22T18:03:13.060' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8608, 12, N'Permisos', N'ACCESS', N'Evento de desarrollo 8608', CAST(N'2026-08-22T18:03:16.233' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8609, 12, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 8609', CAST(N'2026-08-22T18:18:27.477' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8610, 12, N'Permisos', N'ACCESS', N'Evento de desarrollo 8610', CAST(N'2026-08-22T18:18:31.017' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8611, 3034, N'Login', N'LOGIN_SUCCESS', N'Evento de desarrollo 8611', CAST(N'2026-08-23T03:14:25.083' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8612, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8612', CAST(N'2026-08-23T03:14:38.283' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8613, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8613', CAST(N'2026-08-23T03:14:38.297' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8614, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8614', CAST(N'2026-08-23T03:14:41.263' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8615, 3034, N'Usuarios', N'ACCESS', N'Evento de desarrollo 8615', CAST(N'2026-08-23T03:14:41.263' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8616, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8616', CAST(N'2026-08-23T03:14:53.583' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8617, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8617', CAST(N'2026-08-23T03:14:55.997' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8618, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8618', CAST(N'2026-08-23T03:16:10.003' AS DateTime), N'127.0.0.1')
GO

INSERT [dbo].[Bitacora] ([IdBitacora], [IdUsuario], [TablaAfectada], [Operacion], [Descripcion], [FechaHora], [IpUsuario]) VALUES (8619, 3034, N'Pedidos', N'ACCESS', N'Evento de desarrollo 8619', CAST(N'2026-08-23T03:16:16.120' AS DateTime), N'127.0.0.1')
GO

SET IDENTITY_INSERT [dbo].[Bitacora] OFF
GO

SET IDENTITY_INSERT [dbo].[BotIntenciones] ON
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (1, N'agradecimiento', N'¡Con mucho gusto! 😊 Estamos para ayudarte. ¿Necesitas información sobre algún producto, pedido o servicio?', 0, 0, 19, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (2, N'cancelaciones', N'❌ Para solicitar la cancelación de un pedido, te recomendamos contactar con nuestro equipo de soporte indicando el número de pedido y el motivo de la solicitud.', 0, 1, 16, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (3, N'carrito', N'🛒 Puedes agregar productos al carrito desde su página de detalle. Después puedes revisar las cantidades y continuar al proceso de compra.', 1, 0, 9, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (4, N'compra', N'🛒 Para realizar una compra, selecciona el producto que deseas, agrega la cantidad al carrito y luego continúa al proceso de checkout para completar tu pedido.', 1, 0, 8, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (5, N'contacto', N'📞 Puedes contactar a ConcreInnova mediante nuestro teléfono 8888-1111 o por correo electrónico a contacto@concreinnova.com.', 0, 0, 3, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (6, N'cotizaciones', N'📋 ConcreInnova permite solicitar cotizaciones para productos o necesidades específicas. Puedes utilizar el módulo de cotizaciones para enviar tu solicitud y recibir una respuesta.', 1, 0, 13, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (7, N'despedida', N'¡Hasta luego! 👋 Gracias por visitar ConcreInnova. Esperamos ayudarte nuevamente.', 0, 0, 20, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (8, N'devoluciones', N'↩️ Para consultas sobre devoluciones o reembolsos, contacta con nuestro equipo de soporte indicando los detalles de tu pedido para revisar tu caso.', 0, 1, 17, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (9, N'envios', N'🚚 Los tiempos de entrega pueden variar dependiendo del producto, cantidad y ubicación. Para obtener información específica sobre tu pedido, consulta sus detalles o contacta con soporte.', 0, 0, 12, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (10, N'horarios', N'🕐 Nuestro horario de atención es de lunes a viernes de 8:00 a.m. a 5:00 p.m.', 0, 0, 4, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (11, N'pagos', N'💳 En ConcreInnova puedes realizar tus pagos mediante tarjeta de crédito o débito y SINPE Móvil. El método disponible se mostrará durante el proceso de compra.', 0, 0, 2, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (12, N'pedidos', N'📦 Puedes consultar tus pedidos desde la sección ''Mis pedidos''. Allí podrás revisar la información y los detalles de las compras realizadas.', 0, 0, 10, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (13, N'personalizacion', N'🎨 Algunos productos pueden contar con opciones de personalización. Puedes revisar las características disponibles en el detalle del producto o solicitar una cotización para necesidades específicas.', 1, 0, 14, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (14, N'precios', N'💰 Los precios dependen del producto, sus características y opciones de personalización. Puedes consultar el precio directamente desde el detalle de cada producto.', 1, 0, 7, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (15, N'productos', N'🏗️ En ConcreInnova puedes encontrar productos decorativos y soluciones elaboradas en concreto. Puedes consultar nuestro catálogo para conocer los productos disponibles, sus características y precios.', 1, 0, 6, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (16, N'saludo', N'¡Hola! 👋 Soy el asistente virtual de ConcreInnova. Puedo ayudarte con información sobre productos, pedidos, pagos, cotizaciones, envíos y contacto.', 0, 0, 1, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (17, N'seguimiento', N'📦 Para consultar el estado de tu pedido, ingresa a la sección ''Mis pedidos'' de tu cuenta. Si necesitas ayuda adicional, puedes contactar a nuestro equipo de soporte.', 0, 1, 11, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (18, N'soporte', N'🛠️ Claro, puedo ayudarte. Puedes preguntarme sobre productos, pedidos, pagos, cotizaciones, envíos o información de contacto. Si tu problema requiere atención personalizada, puedes comunicarte con nuestro equipo de soporte.', 0, 1, 18, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (19, N'stock', N'📦 La disponibilidad de cada producto se muestra en su página de detalle. Si un producto no está disponible, puedes contactar con nosotros para consultar cuándo volverá a estar disponible.', 1, 0, 15, N'Activo')
GO

INSERT [dbo].[BotIntenciones] ([IdIntencion], [Codigo], [Respuesta], [SugiereProductos], [SugiereEscalamiento], [Orden], [Estado]) VALUES (20, N'ubicacion', N'📍 ConcreInnova ofrece sus servicios en Costa Rica. Para obtener información específica sobre nuestra ubicación, puedes comunicarte con nuestro equipo de atención.', 0, 0, 5, N'Activo')
GO

SET IDENTITY_INSERT [dbo].[BotIntenciones] OFF
GO

SET IDENTITY_INSERT [dbo].[BotIntencionPalabras] ON
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (93, 1, N'gracias')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (94, 1, N'muchas gracias')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (95, 1, N'thank you')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (79, 2, N'cancelacion')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (78, 2, N'cancelar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (80, 2, N'cancelar pedido')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (46, 3, N'agregar al carrito')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (44, 3, N'carrito')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (45, 3, N'carrito de compras')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (42, 4, N'como comprar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (41, 4, N'compra')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (40, 4, N'comprar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (43, 4, N'hacer compra')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (16, 5, N'contactar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (15, 5, N'contacto')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (18, 5, N'correo')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (20, 5, N'correo electronico')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (19, 5, N'email')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (17, 5, N'telefono')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (63, 6, N'cotizacion')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (64, 6, N'cotizaciones')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (65, 6, N'presupuesto')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (66, 6, N'presupuestos')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (96, 7, N'adios')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (97, 7, N'chao')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (98, 7, N'hasta luego')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (81, 8, N'devolucion')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (82, 8, N'devolver')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (84, 8, N'reembolsar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (83, 8, N'reembolso')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (60, 9, N'entrega')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (61, 9, N'entregas')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (58, 9, N'envio')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (59, 9, N'envios')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (62, 9, N'tiempo de entrega')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (23, 10, N'abierto')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (24, 10, N'atencion')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (25, 10, N'cuando atienden')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (21, 10, N'horario')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (22, 10, N'horarios')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (12, 11, N'como pagar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (11, 11, N'formas de pago')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (9, 11, N'metodo de pago')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (10, 11, N'metodos de pago')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (7, 11, N'pago')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (8, 11, N'pagos')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (14, 11, N'sinpe')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (13, 11, N'tarjeta')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (51, 12, N'mi pedido')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (52, 12, N'mis pedidos')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (49, 12, N'orden')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (50, 12, N'ordenes')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (47, 12, N'pedido')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (48, 12, N'pedidos')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (71, 13, N'medidas')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (68, 13, N'personalizacion')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (69, 13, N'personalizado')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (70, 13, N'personalizados')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (67, 13, N'personalizar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (72, 13, N'tamano')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (38, 14, N'costo')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (39, 14, N'costos')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (36, 14, N'cuanto cuesta')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (34, 14, N'precio')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (35, 14, N'precios')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (37, 14, N'valor')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (32, 15, N'catalogo')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (99, 15, N'maceta')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (100, 15, N'macetas')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (101, 15, N'macetero')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (102, 15, N'maceteros')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (110, 15, N'muestrame')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (109, 15, N'opciones')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (103, 15, N'planta')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (104, 15, N'plantas')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (30, 15, N'producto')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (31, 15, N'productos')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (33, 15, N'que venden')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (106, 15, N'recomendacion')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (105, 15, N'recomienda')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (107, 15, N'sugerencia')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (108, 15, N'sugerencias')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (2, 16, N'buenas')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (5, 16, N'buenas noches')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (4, 16, N'buenas tardes')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (3, 16, N'buenos dias')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (6, 16, N'hey')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (1, 16, N'hola')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (57, 17, N'donde esta mi pedido')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (53, 17, N'estado del pedido')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (54, 17, N'estado pedido')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (55, 17, N'seguimiento')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (56, 17, N'seguimiento pedido')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (90, 18, N'agente')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (91, 18, N'asesor humano')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (86, 18, N'ayuda')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (87, 18, N'ayudame')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (92, 18, N'hablar con alguien')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (88, 18, N'problema')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (89, 18, N'problemas')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (85, 18, N'soporte')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (74, 19, N'disponibilidad')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (75, 19, N'disponible')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (76, 19, N'existencias')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (77, 19, N'hay disponible')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (73, 19, N'stock')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (27, 20, N'direccion')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (28, 20, N'donde estan')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (29, 20, N'lugar')
GO

INSERT [dbo].[BotIntencionPalabras] ([IdPalabra], [IdIntencion], [PalabraClave]) VALUES (26, 20, N'ubicacion')
GO

SET IDENTITY_INSERT [dbo].[BotIntencionPalabras] OFF
GO

INSERT [dbo].[CategoriaClasificacion] ([IdCategoria], [Clasificacion]) VALUES (1, N'Macetero')
GO

INSERT [dbo].[CategoriaClasificacion] ([IdCategoria], [Clasificacion]) VALUES (2, N'Macetero')
GO

INSERT [dbo].[CategoriaClasificacion] ([IdCategoria], [Clasificacion]) VALUES (3, N'Planta')
GO

INSERT [dbo].[CategoriaClasificacion] ([IdCategoria], [Clasificacion]) VALUES (4, N'Planta')
GO

SET IDENTITY_INSERT [dbo].[Categorias] ON
GO

INSERT [dbo].[Categorias] ([IdCategoria], [NombreCategoria], [Descripcion], [Estado]) VALUES (1, N'Macetas Interior', N'Macetas decorativas para uso en interiores', N'Activo')
GO

INSERT [dbo].[Categorias] ([IdCategoria], [NombreCategoria], [Descripcion], [Estado]) VALUES (2, N'Macetas Exterior', N'Macetas resistentes para jardines y terrazas', N'Activo')
GO

INSERT [dbo].[Categorias] ([IdCategoria], [NombreCategoria], [Descripcion], [Estado]) VALUES (3, N'Plantas Interior', N'Plantas ornamentales para espacios interiores', N'Activo')
GO

INSERT [dbo].[Categorias] ([IdCategoria], [NombreCategoria], [Descripcion], [Estado]) VALUES (4, N'Plantas Exterior', N'Plantas para jardines, patios y exteriores', N'Activo')
GO

SET IDENTITY_INSERT [dbo].[Categorias] OFF
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (1, 1)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (1, 2)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (1, 3)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (2, 1)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (2, 2)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (2, 3)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (3, 1)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (3, 2)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (4, 1)
GO

INSERT [dbo].[CategoriaTipo] ([IdCategoria], [IdTipo]) VALUES (4, 2)
GO

SET IDENTITY_INSERT [dbo].[Chats] ON
GO

INSERT [dbo].[Chats] ([IdChat], [IdCliente], [IdUsuario], [FechaInicio], [Estado], [FechaCierre]) VALUES (2, 6, 1, CAST(N'2026-08-12T23:06:52.553' AS DateTime), N'Escalado', NULL)
GO

SET IDENTITY_INSERT [dbo].[Chats] OFF
GO

SET IDENTITY_INSERT [dbo].[Clientes] ON
GO

INSERT [dbo].[Clientes] ([IdCliente], [Nombre], [Apellido], [Correo], [Telefono], [Direccion], [FechaRegistro], [Estado], [IdUsuario]) VALUES (3, N'Cliente 3', N'Desarrollo', N'cliente3@example.test', N'0000000003', N'Direccion de prueba', CAST(N'2026-07-23T09:59:40.537' AS DateTime), N'Activo', 11)
GO

INSERT [dbo].[Clientes] ([IdCliente], [Nombre], [Apellido], [Correo], [Telefono], [Direccion], [FechaRegistro], [Estado], [IdUsuario]) VALUES (6, N'Cliente 6', N'Desarrollo', N'cliente6@example.test', N'0000000006', N'Direccion de prueba', CAST(N'2026-08-12T23:06:52.553' AS DateTime), N'Activo', 12)
GO

INSERT [dbo].[Clientes] ([IdCliente], [Nombre], [Apellido], [Correo], [Telefono], [Direccion], [FechaRegistro], [Estado], [IdUsuario]) VALUES (7, N'Cliente 7', N'Desarrollo', N'cliente7@example.test', N'0000000007', N'Direccion de prueba', CAST(N'2026-08-20T10:00:16.533' AS DateTime), N'Activo', 3)
GO

INSERT [dbo].[Clientes] ([IdCliente], [Nombre], [Apellido], [Correo], [Telefono], [Direccion], [FechaRegistro], [Estado], [IdUsuario]) VALUES (8, N'Cliente 8', N'Desarrollo', N'cliente8@example.test', N'0000000008', N'Direccion de prueba', CAST(N'2026-08-20T10:00:16.533' AS DateTime), N'Activo', 6)
GO

INSERT [dbo].[Clientes] ([IdCliente], [Nombre], [Apellido], [Correo], [Telefono], [Direccion], [FechaRegistro], [Estado], [IdUsuario]) VALUES (3009, N'Cliente 3009', N'Desarrollo', N'cliente3009@example.test', N'0000003009', N'Direccion de prueba', CAST(N'2026-08-22T03:51:39.840' AS DateTime), N'Activo', 3034)
GO

SET IDENTITY_INSERT [dbo].[Clientes] OFF
GO

SET IDENTITY_INSERT [dbo].[Cotizaciones] ON
GO

INSERT [dbo].[Cotizaciones] ([IdCotizacion], [IdCliente], [FechaCotizacion], [Estado], [Total], [Descripcion], [Respuesta], [FechaRespuesta], [Preferencias], [NumeroSeguimiento]) VALUES (16, 3, CAST(N'2026-07-23T15:14:03.340' AS DateTime), N'Aprobada', CAST(750000.00 AS Decimal(18, 2)), N'Descripcion de prueba 16', N'Respuesta de prueba 16', CAST(N'2026-07-23T15:15:56.370' AS DateTime), N'Preferencias de prueba', N'COT-0000000016')
GO

INSERT [dbo].[Cotizaciones] ([IdCotizacion], [IdCliente], [FechaCotizacion], [Estado], [Total], [Descripcion], [Respuesta], [FechaRespuesta], [Preferencias], [NumeroSeguimiento]) VALUES (20, 3, CAST(N'2026-07-23T18:02:18.513' AS DateTime), N'Aprobada', CAST(111.00 AS Decimal(18, 2)), N'Descripcion de prueba 20', N'Respuesta de prueba 20', CAST(N'2026-07-23T18:03:26.160' AS DateTime), N'Preferencias de prueba', N'COT-0000000020')
GO

SET IDENTITY_INSERT [dbo].[Cotizaciones] OFF
GO

SET IDENTITY_INSERT [dbo].[CotizacionEstadoHistorial] ON
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (37, 16, NULL, N'Pendiente', CAST(N'2026-07-23T15:14:03.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (38, 16, N'Pendiente', N'Respondida', CAST(N'2026-07-23T15:15:56.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (39, 16, N'Respondida', N'Aceptada', CAST(N'2026-07-23T15:16:50.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (40, 16, N'Aceptada', N'Aprobada', CAST(N'2026-07-23T15:18:28.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (44, 20, NULL, N'Pendiente', CAST(N'2026-07-23T18:02:19.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (45, 20, N'Pendiente', N'Respondida', CAST(N'2026-07-23T18:03:26.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (46, 20, N'Respondida', N'Aceptada', CAST(N'2026-07-23T18:04:18.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionEstadoHistorial] ([IdCotizacionEstadoHistorial], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio]) VALUES (47, 20, N'Aceptada', N'Aprobada', CAST(N'2026-07-23T18:05:30.0000000' AS DateTime2))
GO

SET IDENTITY_INSERT [dbo].[CotizacionEstadoHistorial] OFF
GO

SET IDENTITY_INSERT [dbo].[CotizacionImagenes] ON
GO

INSERT [dbo].[CotizacionImagenes] ([IdCotizacionImagen], [IdCotizacion], [RutaArchivo], [NombreOriginal], [TipoContenido], [TamanoBytes], [FechaCarga]) VALUES (10, 16, N'uploads/cotizaciones/imagen-prueba-10.jpg', N'imagen-prueba-10.jpg', N'image/png', 203254, CAST(N'2026-07-23T15:14:03.360' AS DateTime))
GO

INSERT [dbo].[CotizacionImagenes] ([IdCotizacionImagen], [IdCotizacion], [RutaArchivo], [NombreOriginal], [TipoContenido], [TamanoBytes], [FechaCarga]) VALUES (11, 20, N'uploads/cotizaciones/imagen-prueba-11.jpg', N'imagen-prueba-11.jpg', N'image/png', 203254, CAST(N'2026-07-23T18:02:18.553' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[CotizacionImagenes] OFF
GO

SET IDENTITY_INSERT [dbo].[CotizacionNotificaciones] ON
GO

INSERT [dbo].[CotizacionNotificaciones] ([IdCotizacionNotificacion], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio], [FechaEnvio], [Intentos], [UltimoIntento]) VALUES (25, 16, N'Pendiente', N'Respondida', CAST(N'2026-07-23T15:15:56.0000000' AS DateTime2), CAST(N'2026-07-23T15:15:58.0000000' AS DateTime2), 1, CAST(N'2026-07-23T15:15:58.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionNotificaciones] ([IdCotizacionNotificacion], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio], [FechaEnvio], [Intentos], [UltimoIntento]) VALUES (26, 16, N'Respondida', N'Aceptada', CAST(N'2026-07-23T15:16:50.0000000' AS DateTime2), CAST(N'2026-07-23T15:16:51.0000000' AS DateTime2), 1, CAST(N'2026-07-23T15:16:51.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionNotificaciones] ([IdCotizacionNotificacion], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio], [FechaEnvio], [Intentos], [UltimoIntento]) VALUES (27, 16, N'Aceptada', N'Aprobada', CAST(N'2026-07-23T15:18:28.0000000' AS DateTime2), CAST(N'2026-07-23T15:18:30.0000000' AS DateTime2), 1, CAST(N'2026-07-23T15:18:30.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionNotificaciones] ([IdCotizacionNotificacion], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio], [FechaEnvio], [Intentos], [UltimoIntento]) VALUES (28, 20, N'Pendiente', N'Respondida', CAST(N'2026-07-23T18:03:26.0000000' AS DateTime2), CAST(N'2026-07-23T18:03:28.0000000' AS DateTime2), 1, CAST(N'2026-07-23T18:03:28.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionNotificaciones] ([IdCotizacionNotificacion], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio], [FechaEnvio], [Intentos], [UltimoIntento]) VALUES (29, 20, N'Respondida', N'Aceptada', CAST(N'2026-07-23T18:04:18.0000000' AS DateTime2), CAST(N'2026-07-23T18:04:19.0000000' AS DateTime2), 1, CAST(N'2026-07-23T18:04:19.0000000' AS DateTime2))
GO

INSERT [dbo].[CotizacionNotificaciones] ([IdCotizacionNotificacion], [IdCotizacion], [EstadoAnterior], [EstadoNuevo], [FechaCambio], [FechaEnvio], [Intentos], [UltimoIntento]) VALUES (30, 20, N'Aceptada', N'Aprobada', CAST(N'2026-07-23T18:05:30.0000000' AS DateTime2), CAST(N'2026-07-23T18:05:31.0000000' AS DateTime2), 1, CAST(N'2026-07-23T18:05:31.0000000' AS DateTime2))
GO

SET IDENTITY_INSERT [dbo].[CotizacionNotificaciones] OFF
GO

SET IDENTITY_INSERT [dbo].[DetalleCotizacion] ON
GO

INSERT [dbo].[DetalleCotizacion] ([IdDetalleCotizacion], [IdCotizacion], [IdProducto], [Cantidad], [PrecioUnitario], [Subtotal]) VALUES (13, 16, 5, 30, CAST(25000.00 AS Decimal(10, 2)), CAST(750000.00 AS Decimal(18, 2)))
GO

INSERT [dbo].[DetalleCotizacion] ([IdDetalleCotizacion], [IdCotizacion], [IdProducto], [Cantidad], [PrecioUnitario], [Subtotal]) VALUES (19, 20, 32, 1, CAST(111.00 AS Decimal(10, 2)), CAST(111.00 AS Decimal(18, 2)))
GO

SET IDENTITY_INSERT [dbo].[DetalleCotizacion] OFF
GO

SET IDENTITY_INSERT [dbo].[DetallePedido] ON
GO

INSERT [dbo].[DetallePedido] ([IdDetallePedido], [IdPedido], [IdProducto], [Cantidad], [PrecioUnitario], [Subtotal], [IdVariante], [NombreVariante], [Tamano], [Material], [Color]) VALUES (6, 6, 32, 1, CAST(111.00 AS Decimal(10, 2)), CAST(111.00 AS Decimal(10, 2)), 26, N'Estandar', N'Mediano', N'No especificado', NULL)
GO

INSERT [dbo].[DetallePedido] ([IdDetallePedido], [IdPedido], [IdProducto], [Cantidad], [PrecioUnitario], [Subtotal], [IdVariante], [NombreVariante], [Tamano], [Material], [Color]) VALUES (14, 14, 21, 1, CAST(2000.00 AS Decimal(10, 2)), CAST(2000.00 AS Decimal(10, 2)), 21, N'Estandar', N'Mediano', N'No especificado', NULL)
GO

INSERT [dbo].[DetallePedido] ([IdDetallePedido], [IdPedido], [IdProducto], [Cantidad], [PrecioUnitario], [Subtotal], [IdVariante], [NombreVariante], [Tamano], [Material], [Color]) VALUES (15, 14, 28, 1, CAST(123.00 AS Decimal(10, 2)), CAST(123.00 AS Decimal(10, 2)), 22, N'Estandar', N'Mediano', N'No especificado', NULL)
GO

INSERT [dbo].[DetallePedido] ([IdDetallePedido], [IdPedido], [IdProducto], [Cantidad], [PrecioUnitario], [Subtotal], [IdVariante], [NombreVariante], [Tamano], [Material], [Color]) VALUES (16, 14, 32, 1, CAST(111.00 AS Decimal(10, 2)), CAST(111.00 AS Decimal(10, 2)), 26, N'Estandar', N'Mediano', N'No especificado', NULL)
GO

INSERT [dbo].[DetallePedido] ([IdDetallePedido], [IdPedido], [IdProducto], [Cantidad], [PrecioUnitario], [Subtotal], [IdVariante], [NombreVariante], [Tamano], [Material], [Color]) VALUES (17, 15, 5, 30, CAST(25000.00 AS Decimal(10, 2)), CAST(750000.00 AS Decimal(10, 2)), NULL, NULL, NULL, NULL, NULL)
GO

SET IDENTITY_INSERT [dbo].[DetallePedido] OFF
GO

SET IDENTITY_INSERT [dbo].[InformacionEmpresa] ON
GO

INSERT [dbo].[InformacionEmpresa] ([IdInformacion], [NombreEmpresa], [Descripcion], [Correo], [Telefono], [WhatsApp], [Direccion], [Horario], [Facebook], [Instagram], [TikTok], [FechaActualizacion]) VALUES (1, N'Concre Innova', N'Diseno ecologico para espacios modernos. Seleccion botanica, asesoria de cuidado y entrega local.', N'contacto@concreinnova.com', N'+506 8888-8888', N'+506 8888-8888', N'San Miguel Oeste, Naranjo, Alajuela', N'Lunes a viernes de 8:00 a.m. a 5:00 p.m.', N'https://www.facebook.com/concreinnova', N'https://www.instagram.com/concreinnova', N'https://www.tiktok.com/@concreinnova', CAST(N'2026-08-13T10:08:08.850' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[InformacionEmpresa] OFF
GO

INSERT [dbo].[IntentosLogin] ([IdUsuario], [CantidadIntentos], [FechaUltimoIntento]) VALUES (1, 1, CAST(N'2026-07-23T10:45:47.470' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Inventario] ON
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (1, 5, 0, 0, CAST(N'2026-07-23T15:38:48.810' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2010, 3047, 10, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2011, 3048, 6, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2012, 3049, 10, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2013, 3050, 10, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2015, 3052, 25, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2016, 3053, 14, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2017, 3054, 18, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2018, 3055, 8, 2, CAST(N'2026-08-13T17:38:00.197' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2019, 3056, 8, 2, CAST(N'2026-08-20T14:48:36.243' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2020, 1, 15, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2021, 2, 10, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2022, 3, 12, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2023, 4, 8, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2024, 6, 10, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2025, 7, 20, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2026, 8, 7, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2027, 9, 9, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2028, 10, 4, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2029, 11, 12, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2030, 12, 18, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2031, 13, 25, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2032, 14, 6, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2033, 15, 7, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2034, 16, 10, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2035, 17, 15, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2036, 18, 12, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2037, 19, 8, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2038, 20, 5, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2039, 21, 3, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2040, 22, 10, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2041, 23, 10, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2042, 24, 10, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2043, 25, 12, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2044, 26, 12, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2045, 27, 2, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2046, 28, 1, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2047, 29, 11, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2048, 30, 2, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2049, 31, 11, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

INSERT [dbo].[Inventario] ([IdInventario], [IdProducto], [CantidadDisponible], [CantidadMinima], [FechaActualizacion]) VALUES (2050, 32, 0, 0, CAST(N'2026-08-20T10:58:25.327' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Inventario] OFF
GO

SET IDENTITY_INSERT [dbo].[MensajesChat] ON
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (9, 2, N'Cliente', N'Mensaje de prueba 9', CAST(N'2026-08-12T23:06:52.560' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (10, 2, N'Bot', N'Mensaje de prueba 10', CAST(N'2026-08-12T23:06:52.560' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (11, 2, N'Cliente', N'Mensaje de prueba 11', CAST(N'2026-08-12T23:07:03.223' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (12, 2, N'Bot', N'Mensaje de prueba 12', CAST(N'2026-08-12T23:07:03.223' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (13, 2, N'Cliente', N'Mensaje de prueba 13', CAST(N'2026-08-12T23:07:19.870' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (14, 2, N'Bot', N'Mensaje de prueba 14', CAST(N'2026-08-12T23:07:19.870' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (15, 2, N'Bot', N'Mensaje de prueba 15', CAST(N'2026-08-12T23:07:26.787' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (16, 2, N'Usuario', N'Mensaje de prueba 16', CAST(N'2026-08-12T23:08:08.580' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (17, 2, N'Cliente', N'Mensaje de prueba 17', CAST(N'2026-08-12T23:08:34.390' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (18, 2, N'Bot', N'Mensaje de prueba 18', CAST(N'2026-08-12T23:08:34.393' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (19, 2, N'Cliente', N'Mensaje de prueba 19', CAST(N'2026-08-12T23:09:03.810' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (20, 2, N'Bot', N'Mensaje de prueba 20', CAST(N'2026-08-12T23:09:03.810' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (21, 2, N'Cliente', N'Mensaje de prueba 21', CAST(N'2026-08-12T23:09:18.437' AS DateTime))
GO

INSERT [dbo].[MensajesChat] ([IdMensaje], [IdChat], [Remitente], [Mensaje], [FechaHora]) VALUES (22, 2, N'Bot', N'Mensaje de prueba 22', CAST(N'2026-08-12T23:09:18.440' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[MensajesChat] OFF
GO

SET IDENTITY_INSERT [dbo].[Notificaciones] ON
GO

INSERT [dbo].[Notificaciones] ([IdNotificacion], [IdUsuario], [Mensaje], [Leida], [FechaEnvio], [Tipo], [Titulo], [Enlace], [Referencia], [FechaLectura]) VALUES (2, 1, N'Notificacion de prueba 2', 0, CAST(N'2026-08-12T23:07:26.783' AS DateTime), N'Chat', N'Notificacion de desarrollo', NULL, NULL, NULL)
GO

SET IDENTITY_INSERT [dbo].[Notificaciones] OFF
GO

SET IDENTITY_INSERT [dbo].[Pedidos] ON
GO

INSERT [dbo].[Pedidos] ([IdPedido], [IdCliente], [FechaPedido], [Estado], [DireccionEntrega], [Total], [IdCotizacion]) VALUES (6, 3, CAST(N'2026-07-23T09:59:40.550' AS DateTime), N'Pendiente', N'Direccion de entrega de prueba', CAST(111.00 AS Decimal(10, 2)), NULL)
GO

INSERT [dbo].[Pedidos] ([IdPedido], [IdCliente], [FechaPedido], [Estado], [DireccionEntrega], [Total], [IdCotizacion]) VALUES (14, 3, CAST(N'2026-07-23T15:11:07.363' AS DateTime), N'Pendiente', N'Direccion de entrega de prueba', CAST(2234.00 AS Decimal(10, 2)), NULL)
GO

INSERT [dbo].[Pedidos] ([IdPedido], [IdCliente], [FechaPedido], [Estado], [DireccionEntrega], [Total], [IdCotizacion]) VALUES (15, 3, CAST(N'2026-07-23T15:19:25.073' AS DateTime), N'Pendiente', N'Direccion de entrega de prueba', CAST(750000.00 AS Decimal(10, 2)), 16)
GO

SET IDENTITY_INSERT [dbo].[Pedidos] OFF
GO

SET IDENTITY_INSERT [dbo].[Permisos] ON
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (1, N'usuarios.ver', N'Ver usuarios', N'Usuarios', N'Consultar lista y detalle de usuarios.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (2, N'usuarios.crear', N'Crear usuarios', N'Usuarios', N'Crear usuarios desde administracion.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (3, N'usuarios.actualizar', N'Actualizar usuarios', N'Usuarios', N'Modificar informacion y estado de usuarios.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (4, N'usuarios.eliminar', N'Eliminar usuarios', N'Usuarios', N'Inactivar usuarios.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (5, N'roles.ver', N'Ver roles', N'Roles', N'Consultar catalogo de roles.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (6, N'permisos.gestionar', N'Gestionar permisos', N'Permisos', N'Asignar y retirar permisos por rol.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (7, N'bitacora.ver', N'Ver bitacora', N'Bitacora', N'Consultar auditoria del sistema.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (8, N'productos.crear', N'Crear productos', N'Productos', N'Crear productos y cargar imagenes.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (9, N'productos.actualizar', N'Actualizar productos', N'Productos', N'Modificar productos existentes.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (10, N'productos.eliminar', N'Eliminar productos', N'Productos', N'Inactivar productos.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (11, N'categorias.leer', N'Ver categorias', N'Categorias', N'Consultar categorias de administracion.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (12, N'categorias.crear', N'Crear categorias', N'Categorias', N'Crear categorias.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (13, N'categorias.actualizar', N'Actualizar categorias', N'Categorias', N'Modificar categorias.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (14, N'categorias.eliminar', N'Eliminar categorias', N'Categorias', N'Inactivar categorias.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (15, N'tipos-producto.leer', N'Ver tipos de producto', N'Tipos de producto', N'Consultar tipos de producto de administracion.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (16, N'tipos-producto.crear', N'Crear tipos de producto', N'Tipos de producto', N'Crear tipos de producto.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (17, N'tipos-producto.actualizar', N'Actualizar tipos de producto', N'Tipos de producto', N'Modificar tipos de producto.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (18, N'tipos-producto.eliminar', N'Eliminar tipos de producto', N'Tipos de producto', N'Inactivar tipos de producto.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (19, N'pedidos.ver', N'Ver pedidos', N'Pedidos', N'Consultar listado y detalle de pedidos.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (20, N'pedidos.actualizar', N'Actualizar estado de pedidos', N'Pedidos', N'Cambiar el estado de un pedido.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (21, N'pedidos.cancelar', N'Cancelar pedidos', N'Pedidos', N'Cancelar pedidos y restaurar el stock.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (22, N'estadisticas.ver', N'Ver estadisticas', N'Estadisticas', N'Consultar estadisticas del negocio.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (23, N'reportes.ver', N'Ver reportes de ventas', N'Reportes', N'Consultar reportes de ventas por periodo y productos mas vendidos.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (24, N'empresa.gestionar', N'Gestionar informacion de la empresa', N'Empresa', N'Actualizar datos de contacto, redes sociales y mensajes recibidos.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (25, N'productos.duplicar', N'Duplicar productos', N'Productos', N'Duplicar un producto existente y ajustar la copia mientras esta en estado Borrador.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (26, N'consultas.ver', N'Ver consultas', N'Consultas', N'Consultar los mensajes de contacto enviados por los clientes.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (27, N'consultas.responder', N'Responder consultas', N'Consultas', N'Responder los mensajes de contacto y marcarlos como atendidos.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (28, N'inventario.ver', N'Ver inventario', N'Inventario', N'Consultar existencias y minimos de los productos.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (29, N'inventario.actualizar', N'Actualizar inventario', N'Inventario', N'Ajustar existencias disponibles y cantidad minima.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (30, N'facturas.ver', N'Ver facturas', N'Facturas', N'Consultar las facturas y su estado de cobro.', N'Activo')
GO

INSERT [dbo].[Permisos] ([IdPermiso], [Codigo], [Nombre], [Modulo], [Descripcion], [Estado]) VALUES (31, N'facturas.gestionar', N'Gestionar facturas', N'Facturas', N'Marcar facturas como pagadas, pendientes o en revision.', N'Activo')
GO

SET IDENTITY_INSERT [dbo].[Permisos] OFF
GO

INSERT [dbo].[PreferenciasUsuario] ([IdUsuario], [NotificacionesActivas], [NotificacionesCorreo], [Tema], [FechaActualizacion]) VALUES (1, 1, 1, N'claro', CAST(N'2026-08-13T11:19:07.400' AS DateTime))
GO

INSERT [dbo].[PreferenciasUsuario] ([IdUsuario], [NotificacionesActivas], [NotificacionesCorreo], [Tema], [FechaActualizacion]) VALUES (3, 1, 1, N'claro', CAST(N'2026-08-13T11:19:07.387' AS DateTime))
GO

INSERT [dbo].[PreferenciasUsuario] ([IdUsuario], [NotificacionesActivas], [NotificacionesCorreo], [Tema], [FechaActualizacion]) VALUES (12, 1, 1, N'claro', CAST(N'2026-08-13T11:23:29.637' AS DateTime))
GO

INSERT [dbo].[PreferenciasUsuario] ([IdUsuario], [NotificacionesActivas], [NotificacionesCorreo], [Tema], [FechaActualizacion]) VALUES (3034, 1, 1, N'claro', CAST(N'2026-08-22T18:00:03.200' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[Productos] ON
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (1, N'Maceta Cerámica Blanca 20cm', N'Maceta elegante para interiores', CAST(12500.00 AS Decimal(10, 2)), 15, N'maceta_blanca_20.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 1, N'20cm', N'Ceramica', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (2, N'Maceta Minimalista Negra', N'Diseño moderno color negro', CAST(14500.00 AS Decimal(10, 2)), 10, N'maceta_negra.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3, N'Maceta Decorativa Gris', N'Ideal para salas y oficinas', CAST(13500.00 AS Decimal(10, 2)), 12, N'maceta_gris.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (4, N'Maceta Ovalada Blanca', N'Maceta de cerámica ovalada', CAST(18000.00 AS Decimal(10, 2)), 8, N'maceta_ovalada.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 1, N'Mediano', N'Ceramica', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (5, N'Maceta Premium Mármol', N'Acabado tipo mármol', CAST(25000.00 AS Decimal(10, 2)), 0, N'maceta_marmol.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 1, N'Mediano', N'Marmol', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (6, N'Maceta Jardín Grande', N'Maceta resistente para exterior', CAST(22000.00 AS Decimal(10, 2)), 10, N'maceta_jardin.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 2, N'Grande', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (7, N'Maceta Terracota 30cm', N'Estilo tradicional', CAST(16000.00 AS Decimal(10, 2)), 20, N'terracota_30.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 2, N'30cm', N'Terracota', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (8, N'Maceta Concreto Moderna', N'Fabricada en concreto', CAST(28000.00 AS Decimal(10, 2)), 7, N'concreto.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 2, N'Mediano', N'Concreto', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (9, N'Maceta Rectangular Terraza', N'Ideal para balcones', CAST(24000.00 AS Decimal(10, 2)), 9, N'terraza.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 2, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (10, N'Maceta XL Exterior', N'Gran capacidad para arbustos', CAST(35000.00 AS Decimal(10, 2)), 4, N'xl_exterior.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 2, N'XL', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (11, N'Monstera Deliciosa', N'Planta tropical de interior', CAST(18500.00 AS Decimal(10, 2)), 12, N'monstera.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 3, N'Mediano', N'Natural', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (12, N'Sansevieria', N'Lengua de suegra fácil de cuidar', CAST(12000.00 AS Decimal(10, 2)), 18, N'sansevieria.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 3, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (13, N'Pothos Dorado', N'Planta colgante decorativa', CAST(9500.00 AS Decimal(10, 2)), 25, N'pothos.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 3, N'Mediano', N'Natural', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (14, N'Ficus Lyrata', N'Ficus hoja de violín', CAST(32000.00 AS Decimal(10, 2)), 6, N'ficus.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 3, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (15, N'Palma Areca', N'Palma ornamental para interiores', CAST(28500.00 AS Decimal(10, 2)), 7, N'areca.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 3, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (16, N'Bugambilia', N'Planta ornamental de floración abundante', CAST(17500.00 AS Decimal(10, 2)), 10, N'bugambilia.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 4, N'Mediano', N'Natural', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (17, N'Lavanda', N'Planta aromática para jardín', CAST(11500.00 AS Decimal(10, 2)), 15, N'lavanda.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 4, N'Mediano', N'Natural', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (18, N'Rosal Rojo', N'Rosas rojas para exterior', CAST(14500.00 AS Decimal(10, 2)), 12, N'rosal.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 4, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (19, N'Hibiscus Tropical', N'Flor tropical colorida', CAST(16500.00 AS Decimal(10, 2)), 8, N'hibiscus.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 4, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (20, N'Ciprés Enano', N'Árbol ornamental compacto', CAST(30000.00 AS Decimal(10, 2)), 5, N'cipres.jpg', N'Inactivo', CAST(N'2026-06-21T19:39:38.300' AS DateTime), 4, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (21, N'test update products 2', N'test test update products', CAST(2000.00 AS Decimal(10, 2)), 3, N'text.png', N'Inactivo', CAST(N'2026-06-23T15:38:07.640' AS DateTime), 2, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (22, N'Test Imagen', N'Test Imagen', CAST(10000.00 AS Decimal(10, 2)), 10, N'Nera_test.jpg', N'Inactivo', CAST(N'2026-06-23T16:02:02.330' AS DateTime), 2, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (23, N'Plaza & Janés', N'ss', CAST(100.00 AS Decimal(10, 2)), 10, N'Nera_test.jpg', N'Inactivo', CAST(N'2026-06-23T16:05:33.510' AS DateTime), 2, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (24, N'Plaza & Janés', N'TEST', CAST(10.00 AS Decimal(10, 2)), 10, N'Nera_test.jpg', N'Inactivo', CAST(N'2026-06-23T16:10:07.627' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (25, N'Modernismo', N'DW', CAST(123.00 AS Decimal(10, 2)), 12, N'gelato-234x300.jpeg', N'Inactivo', CAST(N'2026-06-23T16:12:15.487' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (26, N'Modernismo', N'dsds', CAST(100.00 AS Decimal(10, 2)), 12, N'text.png', N'Inactivo', CAST(N'2026-06-23T16:15:00.607' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (27, N'Poesía', N'ewew', CAST(122.00 AS Decimal(10, 2)), 2, N'text.png', N'Inactivo', CAST(N'2026-06-23T16:18:03.083' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (28, N'test insert', N'ssss', CAST(123.00 AS Decimal(10, 2)), 1, N'text.png', N'Inactivo', CAST(N'2026-06-23T16:21:28.523' AS DateTime), 4, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (29, N'ssss', N'ssss', CAST(11111.00 AS Decimal(10, 2)), 11, N'text.png', N'Inactivo', CAST(N'2026-06-23T16:24:18.927' AS DateTime), 2, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (30, N'qqqq', N'qqqq', CAST(11.00 AS Decimal(10, 2)), 2, N'text.png', N'Inactivo', CAST(N'2026-06-23T16:25:53.060' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (31, N'Emecée', N'ee', CAST(11.00 AS Decimal(10, 2)), 11, N'text.png', N'Inactivo', CAST(N'2026-06-23T17:14:52.440' AS DateTime), 1, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (32, N'sasasa', N'sasasa', CAST(111.00 AS Decimal(10, 2)), 0, N'text.png', N'Inactivo', CAST(N'2026-06-23T17:15:59.460' AS DateTime), 4, N'Mediano', N'No especificado', NULL, N'')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3047, N'Macetero Elder', N'Macetero alto de lineas rectas y paredes ligeramente conicas. Su silueta cuadrada estiliza pasillos y entradas, y sostiene bien plantas de porte vertical como sansevierias o palmas jovenes.', CAST(32000.00 AS Decimal(10, 2)), 10, N'images/productos/macetero-elder.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 1, N'Pequeño', N'Concreto', 3, N'Alto 39 cm · Ancho 32 cm · Concreto · Acabado liso · Interior y exterior')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3048, N'Psila Jumbo', N'Jardinera ovalada de gran formato, baja y muy amplia. Pensada para composiciones de varias especies en terrazas, recibidores y espacios comerciales donde se busca una sola pieza protagonista.', CAST(65000.00 AS Decimal(10, 2)), 6, N'images/productos/psila-jumbo.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 2, N'Jumbo', N'Concreto', 2, N'Alto 26 cm · Ancho 88 cm · Concreto · Acabado liso · Ideal para composiciones')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3049, N'Rombo', N'Macetero hexagonal de caras facetadas y textura de piedra. La geometria marcada aporta caracter sin competir con la planta, y funciona igual de bien solo o en grupos de distinta altura.', CAST(38000.00 AS Decimal(10, 2)), 10, N'images/productos/rombo.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 1, N'Mediano', N'Concreto', 3, N'Alto 40 cm · Ancho 48 cm · Concreto · Acabado texturizado · Interior y exterior')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3050, N'Vertical', N'Macetero alto y estrecho de perfil conico. Gana altura sin ocupar superficie, por lo que resuelve esquinas, entradas y espacios estrechos donde se busca volumen en vertical.', CAST(45000.00 AS Decimal(10, 2)), 10, N'images/productos/vertical.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 2, N'Mediano', N'Concreto', 2, N'Alto 54 cm · Ancho 32 cm · Concreto · Acabado liso · Interior y exterior')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3052, N'Macetero redondo', N'Macetero redondo de paredes curvas y base recogida, disponible en cinco tamanos. El formato clasico de la linea: acompana desde arbustos pequenos hasta arboles de patio segun la medida elegida.', CAST(39000.00 AS Decimal(10, 2)), 25, N'images/productos/macetero-redondo.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 2, N'Grande', N'Concreto', 2, N'Cinco tamanos, de 45 x 50 cm a 72 x 88 cm · Concreto · Acabado liso · Interior y exterior')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3053, N'Paila', N'Jardinera baja y amplia en acabado negro mate. Su poca altura deja la planta a la vista y funciona muy bien sobre mesas, bancas y muros bajos. Disponible en dos tamanos.', CAST(30000.00 AS Decimal(10, 2)), 14, N'images/productos/paila-pequena.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 1, N'Mediano', N'Concreto', 3, N'Dos tamanos: 20 x 50 cm y 24 x 56 cm · Concreto · Acabado negro mate · Interior y exterior')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3054, N'Novas', N'Macetero conico de paredes altas y textura granulada, disponible en tres tamanos. Pensado para plantas de follaje amplio que necesitan profundidad de raiz sin ocupar mucho suelo.', CAST(35000.00 AS Decimal(10, 2)), 18, N'images/productos/novas.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 2, N'Grande', N'Concreto', 2, N'Tres tamanos: 40 x 34 cm, 52 x 36 cm y 64 x 40 cm · Concreto · Acabado texturizado · Interior y exterior')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3055, N'Gota', N'Cuenco amplio y de poca altura, con boca generosa y perfil redondeado. Su diametro permite composiciones bajas de varias especies y luce especialmente bien centrado en una mesa o en el piso.', CAST(43000.00 AS Decimal(10, 2)), 8, N'images/productos/gota.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.520' AS DateTime), 1, N'Grande', N'Concreto', 3, N'Alto 28 cm · Ancho 55 cm · Diametro 75 cm · Concreto · Acabado liso · Interior y exterior')
GO

INSERT [dbo].[Productos] ([IdProducto], [Nombre], [Descripcion], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro], [IdCategoria], [Tamano], [Material], [IdTipo], [Caracteristicas]) VALUES (3056, N'Cónico', N'Pieza conica de boca inclinada y acabado texturizado en tono terracota. El corte diagonal del borde le da movimiento y la vuelve una pieza escultorica por si misma.', CAST(50000.00 AS Decimal(10, 2)), 8, N'images/productos/conico.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.257' AS DateTime), 2, N'Mediano', N'Concreto', 2, N'Alto 50 cm · Ancho 51 cm · Concreto · Acabado texturizado · Interior y exterior')
GO

SET IDENTITY_INSERT [dbo].[Productos] OFF
GO

SET IDENTITY_INSERT [dbo].[ProductoVariantes] ON
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (1, 1, N'Estandar', N'20cm', N'Ceramica', CAST(12500.00 AS Decimal(18, 2)), 15, N'maceta_blanca_20.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2, 2, N'Estandar', N'Mediano', N'No especificado', CAST(14500.00 AS Decimal(18, 2)), 10, N'maceta_negra.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (3, 3, N'Estandar', N'Mediano', N'No especificado', CAST(13500.00 AS Decimal(18, 2)), 12, N'maceta_gris.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (4, 4, N'Estandar', N'Mediano', N'Ceramica', CAST(18000.00 AS Decimal(18, 2)), 8, N'maceta_ovalada.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (5, 5, N'Estandar', N'Mediano', N'Marmol', CAST(25000.00 AS Decimal(18, 2)), 5, N'maceta_marmol.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (6, 6, N'Estandar', N'Grande', N'No especificado', CAST(22000.00 AS Decimal(18, 2)), 10, N'maceta_jardin.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (7, 7, N'Estandar', N'30cm', N'Terracota', CAST(16000.00 AS Decimal(18, 2)), 20, N'terracota_30.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (8, 8, N'Estandar', N'Mediano', N'Concreto', CAST(28000.00 AS Decimal(18, 2)), 7, N'concreto.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (9, 9, N'Estandar', N'Mediano', N'No especificado', CAST(24000.00 AS Decimal(18, 2)), 9, N'terraza.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (10, 10, N'Estandar', N'XL', N'No especificado', CAST(35000.00 AS Decimal(18, 2)), 4, N'xl_exterior.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (11, 11, N'Estandar', N'Mediano', N'Natural', CAST(18500.00 AS Decimal(18, 2)), 12, N'monstera.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (12, 12, N'Estandar', N'Mediano', N'No especificado', CAST(12000.00 AS Decimal(18, 2)), 18, N'sansevieria.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (13, 13, N'Estandar', N'Mediano', N'Natural', CAST(9500.00 AS Decimal(18, 2)), 25, N'pothos.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (14, 14, N'Estandar', N'Mediano', N'No especificado', CAST(32000.00 AS Decimal(18, 2)), 6, N'ficus.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (15, 15, N'Estandar', N'Mediano', N'No especificado', CAST(28500.00 AS Decimal(18, 2)), 7, N'areca.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (16, 16, N'Estandar', N'Mediano', N'Natural', CAST(17500.00 AS Decimal(18, 2)), 10, N'bugambilia.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (17, 17, N'Estandar', N'Mediano', N'Natural', CAST(11500.00 AS Decimal(18, 2)), 15, N'lavanda.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (18, 18, N'Estandar', N'Mediano', N'No especificado', CAST(14500.00 AS Decimal(18, 2)), 12, N'rosal.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (19, 19, N'Estandar', N'Mediano', N'No especificado', CAST(16500.00 AS Decimal(18, 2)), 8, N'hibiscus.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (20, 20, N'Estandar', N'Mediano', N'No especificado', CAST(30000.00 AS Decimal(18, 2)), 5, N'cipres.jpg', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (21, 21, N'Estandar', N'Mediano', N'No especificado', CAST(2000.00 AS Decimal(18, 2)), 3, N'text.png', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (22, 28, N'Estandar', N'Mediano', N'No especificado', CAST(123.00 AS Decimal(18, 2)), 1, N'text.png', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (23, 29, N'Estandar', N'Mediano', N'No especificado', CAST(11111.00 AS Decimal(18, 2)), 11, N'text.png', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (24, 30, N'Estandar', N'Mediano', N'No especificado', CAST(11.00 AS Decimal(18, 2)), 2, N'text.png', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (25, 31, N'Estandar', N'Mediano', N'No especificado', CAST(11.00 AS Decimal(18, 2)), 11, N'text.png', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (26, 32, N'Estandar', N'Mediano', N'No especificado', CAST(111.00 AS Decimal(18, 2)), 0, N'text.png', N'Inactivo', CAST(N'2026-07-21T12:42:31.107' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2037, 3053, N'Mediana', N'24 x 56 cm', N'Concreto', CAST(35000.00 AS Decimal(18, 2)), 7, N'images/productos/paila-mediana.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.537' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2038, 3054, N'Grande', N'64 x 40 cm', N'Concreto', CAST(50000.00 AS Decimal(18, 2)), 5, N'images/productos/novas.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.537' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2039, 3054, N'Mediano', N'52 x 36 cm', N'Concreto', CAST(45000.00 AS Decimal(18, 2)), 6, N'images/productos/novas.jpg', N'Activo', CAST(N'2026-08-13T17:23:16.537' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2041, 3052, N'Tamaño 1', N'72 x 88 cm', N'Concreto', CAST(100000.00 AS Decimal(18, 2)), 4, N'images/productos/macetero-redondo.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.267' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2042, 3052, N'Tamaño 2', N'63 x 72 cm', N'Concreto', CAST(70000.00 AS Decimal(18, 2)), 5, N'images/productos/macetero-redondo.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.267' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2043, 3052, N'Tamaño 3', N'58 x 68 cm', N'Concreto', CAST(60000.00 AS Decimal(18, 2)), 5, N'images/productos/macetero-redondo.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.267' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2044, 3052, N'Tamaño 4', N'48 x 56 cm', N'Concreto', CAST(50000.00 AS Decimal(18, 2)), 5, N'images/productos/macetero-redondo.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.267' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2045, 3052, N'Tamaño 5', N'45 x 50 cm', N'Concreto', CAST(39000.00 AS Decimal(18, 2)), 6, N'images/productos/macetero-redondo.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.267' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2046, 3053, N'Pequeña', N'20 x 50 cm', N'Concreto', CAST(30000.00 AS Decimal(18, 2)), 7, N'images/productos/paila-pequena.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.267' AS DateTime))
GO

INSERT [dbo].[ProductoVariantes] ([IdVariante], [IdProducto], [NombreVariante], [Tamano], [Material], [Precio], [Stock], [Imagen], [Estado], [FechaRegistro]) VALUES (2047, 3054, N'Pequeño', N'40 x 34 cm', N'Concreto', CAST(35000.00 AS Decimal(18, 2)), 7, N'images/productos/novas.jpg', N'Activo', CAST(N'2026-08-13T17:24:34.267' AS DateTime))
GO

SET IDENTITY_INSERT [dbo].[ProductoVariantes] OFF
GO

SET IDENTITY_INSERT [dbo].[Roles] ON
GO

INSERT [dbo].[Roles] ([IdRol], [NombreRol]) VALUES (1, N'Administrador')
GO

INSERT [dbo].[Roles] ([IdRol], [NombreRol]) VALUES (2, N'Vendedor')
GO

INSERT [dbo].[Roles] ([IdRol], [NombreRol]) VALUES (3, N'Cliente')
GO

INSERT [dbo].[Roles] ([IdRol], [NombreRol]) VALUES (4, N'Inactivo')
GO

SET IDENTITY_INSERT [dbo].[Roles] OFF
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 1)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 2)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 3)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 4)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 5)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 6)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 7)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 8)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 9)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 10)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 11)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 12)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 13)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 14)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 15)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 16)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 17)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 18)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 19)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 20)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 21)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 22)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 23)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 24)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 25)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 26)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 27)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 28)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 29)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 30)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (1, 31)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 8)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 9)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 10)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 11)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 12)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 13)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 14)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 25)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 26)
GO

INSERT [dbo].[RolPermisos] ([IdRol], [IdPermiso]) VALUES (2, 27)
GO

SET IDENTITY_INSERT [dbo].[SolicitudCotizacionProductos] ON
GO

INSERT [dbo].[SolicitudCotizacionProductos] ([IdSolicitudCotizacionProducto], [IdCotizacion], [IdProducto], [Cantidad]) VALUES (8, 16, 5, 30)
GO

INSERT [dbo].[SolicitudCotizacionProductos] ([IdSolicitudCotizacionProducto], [IdCotizacion], [IdProducto], [Cantidad]) VALUES (9, 20, 32, 1)
GO

SET IDENTITY_INSERT [dbo].[SolicitudCotizacionProductos] OFF
GO

SET IDENTITY_INSERT [dbo].[TiposProducto] ON
GO

INSERT [dbo].[TiposProducto] ([IdTipo], [NombreTipo], [Descripcion], [Estado]) VALUES (1, N'Interior', N'Productos pensados para espacios interiores.', N'Activo')
GO

INSERT [dbo].[TiposProducto] ([IdTipo], [NombreTipo], [Descripcion], [Estado]) VALUES (2, N'Exterior', N'Productos pensados para espacios exteriores.', N'Activo')
GO

INSERT [dbo].[TiposProducto] ([IdTipo], [NombreTipo], [Descripcion], [Estado]) VALUES (3, N'Decorativo', N'Productos con fines decorativos.', N'Activo')
GO

SET IDENTITY_INSERT [dbo].[TiposProducto] OFF
GO

SET IDENTITY_INSERT [dbo].[Usuarios] ON
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (1, N'Usuario 1', N'Desarrollo', N'usuario1@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000001', N'Activo', CAST(N'2026-06-04T15:40:24.930' AS DateTime), 1)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (2, N'Usuario 2', N'Desarrollo', N'usuario2@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000002', N'Activo', CAST(N'2026-06-04T15:40:24.963' AS DateTime), 2)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (3, N'Usuario 3', N'Desarrollo', N'usuario3@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000003', N'Activo', CAST(N'2026-06-04T15:40:24.990' AS DateTime), 3)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (4, N'Usuario 4', N'Desarrollo', N'usuario4@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000004', N'Activo', CAST(N'2026-06-04T15:40:25.013' AS DateTime), 4)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (5, N'Usuario 5', N'Desarrollo', N'usuario5@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000005', N'Activo', CAST(N'2026-06-07T14:49:24.857' AS DateTime), 4)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (6, N'Usuario 6', N'Desarrollo', N'usuario6@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000006', N'Activo', CAST(N'2026-06-07T15:08:01.030' AS DateTime), 3)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (11, N'Usuario 11', N'Desarrollo', N'usuario11@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000011', N'Activo', CAST(N'2026-06-11T18:09:44.280' AS DateTime), 3)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (12, N'Usuario 12', N'Desarrollo', N'usuario12@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000012', N'Activo', CAST(N'2026-06-11T19:07:45.880' AS DateTime), 1)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (13, N'Usuario 13', N'Desarrollo', N'usuario13@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000000013', N'Activo', CAST(N'2026-06-11T19:16:33.340' AS DateTime), 2)
GO

INSERT [dbo].[Usuarios] ([IdUsuario], [Nombre], [Apellido], [Correo], [ContrasenaHash], [Telefono], [Estado], [FechaRegistro], [IdRol]) VALUES (3034, N'Usuario 3034', N'Desarrollo', N'usuario3034@example.test', N'71639C54BD3E9AC992003CF537B431313D816204F9764990326B4E016EEBEE99', N'0000003034', N'Activo', CAST(N'2026-08-22T03:51:39.837' AS DateTime), 3)
GO

SET IDENTITY_INSERT [dbo].[Usuarios] OFF
GO

SET IDENTITY_INSERT [dbo].[Ventas] ON
GO

INSERT [dbo].[Ventas] ([IdVenta], [IdPedido], [FechaVenta], [MetodoPago], [EstadoPago], [Total], [FechaVencimiento], [Observaciones]) VALUES (6, 6, CAST(N'2026-07-23T09:59:40.570' AS DateTime), N'SINPE Movil', N'Pendiente', CAST(111.00 AS Decimal(10, 2)), CAST(N'2026-08-07T09:59:40.570' AS DateTime), NULL)
GO

INSERT [dbo].[Ventas] ([IdVenta], [IdPedido], [FechaVenta], [MetodoPago], [EstadoPago], [Total], [FechaVencimiento], [Observaciones]) VALUES (7, 14, CAST(N'2026-07-23T15:11:07.377' AS DateTime), N'Tarjeta', N'Pendiente', CAST(2234.00 AS Decimal(10, 2)), CAST(N'2026-08-07T15:11:07.377' AS DateTime), NULL)
GO

SET IDENTITY_INSERT [dbo].[Ventas] OFF
GO

-- ============================================================================
-- Estado de columnas identity
-- ============================================================================

DBCC CHECKIDENT (N'[dbo].[AsesorCriterios]', RESEED, 37) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[AsesorOpciones]', RESEED, 11) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[AsesorPreguntas]', RESEED, 4) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Bitacora]', RESEED, 9610) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[BotIntenciones]', RESEED, 20) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[BotIntencionPalabras]', RESEED, 110) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Categorias]', RESEED, 1007) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Chats]', RESEED, 2) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Clientes]', RESEED, 3009) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Cotizaciones]', RESEED, 20) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[CotizacionEstadoHistorial]', RESEED, 47) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[CotizacionImagenes]', RESEED, 11) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[CotizacionNotificaciones]', RESEED, 30) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[DetalleCotizacion]', RESEED, 19) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[DetallePedido]', RESEED, 1019) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[InformacionEmpresa]', RESEED, 1) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Inventario]', RESEED, 2050) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[MensajesChat]', RESEED, 22) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Notificaciones]', RESEED, 1003) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Pedidos]', RESEED, 1017) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Permisos]', RESEED, 31) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Productos]', RESEED, 3056) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[ProductoVariantes]', RESEED, 2047) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Roles]', RESEED, 4) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[SolicitudCotizacionProductos]', RESEED, 9) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[TiposProducto]', RESEED, 3) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Usuarios]', RESEED, 3034) WITH NO_INFOMSGS;
GO

DBCC CHECKIDENT (N'[dbo].[Ventas]', RESEED, 1008) WITH NO_INFOMSGS;
GO

-- ============================================================================
-- Claves foraneas
-- ============================================================================

ALTER TABLE [dbo].[AsesorCriterios]  WITH CHECK ADD  CONSTRAINT [FK_AsesorCriterios_AsesorOpciones] FOREIGN KEY([IdOpcion])
REFERENCES [dbo].[AsesorOpciones] ([IdOpcion])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[AsesorCriterios] CHECK CONSTRAINT [FK_AsesorCriterios_AsesorOpciones]
GO

ALTER TABLE [dbo].[AsesorCriterios]  WITH CHECK ADD  CONSTRAINT [FK_AsesorCriterios_Categorias] FOREIGN KEY([IdCategoria])
REFERENCES [dbo].[Categorias] ([IdCategoria])
GO

ALTER TABLE [dbo].[AsesorCriterios] CHECK CONSTRAINT [FK_AsesorCriterios_Categorias]
GO

ALTER TABLE [dbo].[AsesorCriterios]  WITH CHECK ADD  CONSTRAINT [FK_AsesorCriterios_TiposProducto] FOREIGN KEY([IdTipo])
REFERENCES [dbo].[TiposProducto] ([IdTipo])
GO

ALTER TABLE [dbo].[AsesorCriterios] CHECK CONSTRAINT [FK_AsesorCriterios_TiposProducto]
GO

ALTER TABLE [dbo].[AsesorOpciones]  WITH CHECK ADD  CONSTRAINT [FK_AsesorOpciones_AsesorPreguntas] FOREIGN KEY([IdPregunta])
REFERENCES [dbo].[AsesorPreguntas] ([IdPregunta])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[AsesorOpciones] CHECK CONSTRAINT [FK_AsesorOpciones_AsesorPreguntas]
GO

ALTER TABLE [dbo].[AsesorRespuestas]  WITH CHECK ADD  CONSTRAINT [FK_AsesorRespuestas_AsesorOpciones] FOREIGN KEY([IdOpcion])
REFERENCES [dbo].[AsesorOpciones] ([IdOpcion])
GO

ALTER TABLE [dbo].[AsesorRespuestas] CHECK CONSTRAINT [FK_AsesorRespuestas_AsesorOpciones]
GO

ALTER TABLE [dbo].[AsesorRespuestas]  WITH CHECK ADD  CONSTRAINT [FK_AsesorRespuestas_AsesorPreguntas] FOREIGN KEY([IdPregunta])
REFERENCES [dbo].[AsesorPreguntas] ([IdPregunta])
GO

ALTER TABLE [dbo].[AsesorRespuestas] CHECK CONSTRAINT [FK_AsesorRespuestas_AsesorPreguntas]
GO

ALTER TABLE [dbo].[AsesorRespuestas]  WITH CHECK ADD  CONSTRAINT [FK_AsesorRespuestas_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[AsesorRespuestas] CHECK CONSTRAINT [FK_AsesorRespuestas_Usuarios]
GO

ALTER TABLE [dbo].[Bitacora]  WITH CHECK ADD  CONSTRAINT [FK_Bitacora_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[Bitacora] CHECK CONSTRAINT [FK_Bitacora_Usuarios]
GO

ALTER TABLE [dbo].[BotIntencionPalabras]  WITH CHECK ADD  CONSTRAINT [FK_BotIntencionPalabras_BotIntenciones] FOREIGN KEY([IdIntencion])
REFERENCES [dbo].[BotIntenciones] ([IdIntencion])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[BotIntencionPalabras] CHECK CONSTRAINT [FK_BotIntencionPalabras_BotIntenciones]
GO

ALTER TABLE [dbo].[CategoriaClasificacion]  WITH CHECK ADD  CONSTRAINT [FK_CategoriaClasificacion_Categorias] FOREIGN KEY([IdCategoria])
REFERENCES [dbo].[Categorias] ([IdCategoria])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[CategoriaClasificacion] CHECK CONSTRAINT [FK_CategoriaClasificacion_Categorias]
GO

ALTER TABLE [dbo].[CategoriaTipo]  WITH CHECK ADD  CONSTRAINT [FK_CategoriaTipo_Categorias] FOREIGN KEY([IdCategoria])
REFERENCES [dbo].[Categorias] ([IdCategoria])
GO

ALTER TABLE [dbo].[CategoriaTipo] CHECK CONSTRAINT [FK_CategoriaTipo_Categorias]
GO

ALTER TABLE [dbo].[CategoriaTipo]  WITH CHECK ADD  CONSTRAINT [FK_CategoriaTipo_TiposProducto] FOREIGN KEY([IdTipo])
REFERENCES [dbo].[TiposProducto] ([IdTipo])
GO

ALTER TABLE [dbo].[CategoriaTipo] CHECK CONSTRAINT [FK_CategoriaTipo_TiposProducto]
GO

ALTER TABLE [dbo].[Chats]  WITH CHECK ADD  CONSTRAINT [FK_Chats_Clientes] FOREIGN KEY([IdCliente])
REFERENCES [dbo].[Clientes] ([IdCliente])
GO

ALTER TABLE [dbo].[Chats] CHECK CONSTRAINT [FK_Chats_Clientes]
GO

ALTER TABLE [dbo].[Chats]  WITH CHECK ADD  CONSTRAINT [FK_Chats_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[Chats] CHECK CONSTRAINT [FK_Chats_Usuarios]
GO

ALTER TABLE [dbo].[Clientes]  WITH CHECK ADD  CONSTRAINT [FK_Clientes_Usuarios_IdUsuario] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[Clientes] CHECK CONSTRAINT [FK_Clientes_Usuarios_IdUsuario]
GO

ALTER TABLE [dbo].[Cotizaciones]  WITH CHECK ADD  CONSTRAINT [FK_Cotizaciones_Clientes] FOREIGN KEY([IdCliente])
REFERENCES [dbo].[Clientes] ([IdCliente])
GO

ALTER TABLE [dbo].[Cotizaciones] CHECK CONSTRAINT [FK_Cotizaciones_Clientes]
GO

ALTER TABLE [dbo].[CotizacionEstadoHistorial]  WITH CHECK ADD  CONSTRAINT [FK_CotizacionEstadoHistorial_Cotizaciones] FOREIGN KEY([IdCotizacion])
REFERENCES [dbo].[Cotizaciones] ([IdCotizacion])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[CotizacionEstadoHistorial] CHECK CONSTRAINT [FK_CotizacionEstadoHistorial_Cotizaciones]
GO

ALTER TABLE [dbo].[CotizacionImagenes]  WITH CHECK ADD  CONSTRAINT [FK_CotizacionImagenes_Cotizaciones] FOREIGN KEY([IdCotizacion])
REFERENCES [dbo].[Cotizaciones] ([IdCotizacion])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[CotizacionImagenes] CHECK CONSTRAINT [FK_CotizacionImagenes_Cotizaciones]
GO

ALTER TABLE [dbo].[CotizacionNotificaciones]  WITH CHECK ADD  CONSTRAINT [FK_CotizacionNotificaciones_Cotizaciones] FOREIGN KEY([IdCotizacion])
REFERENCES [dbo].[Cotizaciones] ([IdCotizacion])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[CotizacionNotificaciones] CHECK CONSTRAINT [FK_CotizacionNotificaciones_Cotizaciones]
GO

ALTER TABLE [dbo].[DetalleCotizacion]  WITH CHECK ADD  CONSTRAINT [FK_DetalleCotizacion_Cotizacion] FOREIGN KEY([IdCotizacion])
REFERENCES [dbo].[Cotizaciones] ([IdCotizacion])
GO

ALTER TABLE [dbo].[DetalleCotizacion] CHECK CONSTRAINT [FK_DetalleCotizacion_Cotizacion]
GO

ALTER TABLE [dbo].[DetalleCotizacion]  WITH CHECK ADD  CONSTRAINT [FK_DetalleCotizacion_Producto] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO

ALTER TABLE [dbo].[DetalleCotizacion] CHECK CONSTRAINT [FK_DetalleCotizacion_Producto]
GO

ALTER TABLE [dbo].[DetallePedido]  WITH CHECK ADD  CONSTRAINT [FK_DetallePedido_Pedido] FOREIGN KEY([IdPedido])
REFERENCES [dbo].[Pedidos] ([IdPedido])
GO

ALTER TABLE [dbo].[DetallePedido] CHECK CONSTRAINT [FK_DetallePedido_Pedido]
GO

ALTER TABLE [dbo].[DetallePedido]  WITH CHECK ADD  CONSTRAINT [FK_DetallePedido_Producto] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO

ALTER TABLE [dbo].[DetallePedido] CHECK CONSTRAINT [FK_DetallePedido_Producto]
GO

ALTER TABLE [dbo].[Favoritos]  WITH CHECK ADD  CONSTRAINT [FK_Favoritos_Productos] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO

ALTER TABLE [dbo].[Favoritos] CHECK CONSTRAINT [FK_Favoritos_Productos]
GO

ALTER TABLE [dbo].[Favoritos]  WITH CHECK ADD  CONSTRAINT [FK_Favoritos_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[Favoritos] CHECK CONSTRAINT [FK_Favoritos_Usuarios]
GO

ALTER TABLE [dbo].[IntentosLogin]  WITH CHECK ADD  CONSTRAINT [FK_IntentosLogin_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[IntentosLogin] CHECK CONSTRAINT [FK_IntentosLogin_Usuarios]
GO

ALTER TABLE [dbo].[Inventario]  WITH CHECK ADD  CONSTRAINT [FK_Inventario_Productos] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO

ALTER TABLE [dbo].[Inventario] CHECK CONSTRAINT [FK_Inventario_Productos]
GO

ALTER TABLE [dbo].[MensajesChat]  WITH CHECK ADD  CONSTRAINT [FK_MensajesChat_Chats] FOREIGN KEY([IdChat])
REFERENCES [dbo].[Chats] ([IdChat])
GO

ALTER TABLE [dbo].[MensajesChat] CHECK CONSTRAINT [FK_MensajesChat_Chats]
GO

ALTER TABLE [dbo].[MensajesContacto]  WITH CHECK ADD  CONSTRAINT [FK_MensajesContacto_UsuarioRespuesta] FOREIGN KEY([IdUsuarioRespuesta])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[MensajesContacto] CHECK CONSTRAINT [FK_MensajesContacto_UsuarioRespuesta]
GO

ALTER TABLE [dbo].[MensajesContacto]  WITH CHECK ADD  CONSTRAINT [FK_MensajesContacto_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[MensajesContacto] CHECK CONSTRAINT [FK_MensajesContacto_Usuarios]
GO

ALTER TABLE [dbo].[Notificaciones]  WITH CHECK ADD  CONSTRAINT [FK_Notificaciones_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[Notificaciones] CHECK CONSTRAINT [FK_Notificaciones_Usuarios]
GO

ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [FK_Pagos_UsuarioRegistro] FOREIGN KEY([IdUsuarioRegistro])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [FK_Pagos_UsuarioRegistro]
GO

ALTER TABLE [dbo].[Pagos]  WITH CHECK ADD  CONSTRAINT [FK_Pagos_Ventas] FOREIGN KEY([IdVenta])
REFERENCES [dbo].[Ventas] ([IdVenta])
GO

ALTER TABLE [dbo].[Pagos] CHECK CONSTRAINT [FK_Pagos_Ventas]
GO

ALTER TABLE [dbo].[Pedidos]  WITH CHECK ADD  CONSTRAINT [FK_Pedidos_Clientes] FOREIGN KEY([IdCliente])
REFERENCES [dbo].[Clientes] ([IdCliente])
GO

ALTER TABLE [dbo].[Pedidos] CHECK CONSTRAINT [FK_Pedidos_Clientes]
GO

ALTER TABLE [dbo].[Pedidos]  WITH CHECK ADD  CONSTRAINT [FK_Pedidos_Cotizaciones] FOREIGN KEY([IdCotizacion])
REFERENCES [dbo].[Cotizaciones] ([IdCotizacion])
GO

ALTER TABLE [dbo].[Pedidos] CHECK CONSTRAINT [FK_Pedidos_Cotizaciones]
GO

ALTER TABLE [dbo].[PreferenciasUsuario]  WITH CHECK ADD  CONSTRAINT [FK_PreferenciasUsuario_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
GO

ALTER TABLE [dbo].[PreferenciasUsuario] CHECK CONSTRAINT [FK_PreferenciasUsuario_Usuarios]
GO

ALTER TABLE [dbo].[Productos]  WITH CHECK ADD  CONSTRAINT [FK_Productos_Categorias] FOREIGN KEY([IdCategoria])
REFERENCES [dbo].[Categorias] ([IdCategoria])
GO

ALTER TABLE [dbo].[Productos] CHECK CONSTRAINT [FK_Productos_Categorias]
GO

ALTER TABLE [dbo].[Productos]  WITH CHECK ADD  CONSTRAINT [FK_Productos_TiposProducto] FOREIGN KEY([IdTipo])
REFERENCES [dbo].[TiposProducto] ([IdTipo])
GO

ALTER TABLE [dbo].[Productos] CHECK CONSTRAINT [FK_Productos_TiposProducto]
GO

ALTER TABLE [dbo].[ProductoVariantes]  WITH CHECK ADD  CONSTRAINT [FK_ProductoVariantes_Productos] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO

ALTER TABLE [dbo].[ProductoVariantes] CHECK CONSTRAINT [FK_ProductoVariantes_Productos]
GO

ALTER TABLE [dbo].[RolPermisos]  WITH CHECK ADD  CONSTRAINT [FK_RolPermisos_Permisos] FOREIGN KEY([IdPermiso])
REFERENCES [dbo].[Permisos] ([IdPermiso])
GO

ALTER TABLE [dbo].[RolPermisos] CHECK CONSTRAINT [FK_RolPermisos_Permisos]
GO

ALTER TABLE [dbo].[RolPermisos]  WITH CHECK ADD  CONSTRAINT [FK_RolPermisos_Roles] FOREIGN KEY([IdRol])
REFERENCES [dbo].[Roles] ([IdRol])
GO

ALTER TABLE [dbo].[RolPermisos] CHECK CONSTRAINT [FK_RolPermisos_Roles]
GO

ALTER TABLE [dbo].[SolicitudCotizacionProductos]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudCotizacionProductos_Cotizaciones] FOREIGN KEY([IdCotizacion])
REFERENCES [dbo].[Cotizaciones] ([IdCotizacion])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[SolicitudCotizacionProductos] CHECK CONSTRAINT [FK_SolicitudCotizacionProductos_Cotizaciones]
GO

ALTER TABLE [dbo].[SolicitudCotizacionProductos]  WITH CHECK ADD  CONSTRAINT [FK_SolicitudCotizacionProductos_Productos] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO

ALTER TABLE [dbo].[SolicitudCotizacionProductos] CHECK CONSTRAINT [FK_SolicitudCotizacionProductos_Productos]
GO

ALTER TABLE [dbo].[Usuarios]  WITH CHECK ADD  CONSTRAINT [FK_Usuarios_Roles] FOREIGN KEY([IdRol])
REFERENCES [dbo].[Roles] ([IdRol])
GO

ALTER TABLE [dbo].[Usuarios] CHECK CONSTRAINT [FK_Usuarios_Roles]
GO

ALTER TABLE [dbo].[Ventas]  WITH CHECK ADD  CONSTRAINT [FK_Ventas_Pedidos] FOREIGN KEY([IdPedido])
REFERENCES [dbo].[Pedidos] ([IdPedido])
GO

ALTER TABLE [dbo].[Ventas] CHECK CONSTRAINT [FK_Ventas_Pedidos]
GO

ALTER TABLE [dbo].[Visualizaciones]  WITH CHECK ADD  CONSTRAINT [FK_Visualizaciones_Usuarios] FOREIGN KEY([IdUsuario])
REFERENCES [dbo].[Usuarios] ([IdUsuario])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Visualizaciones] CHECK CONSTRAINT [FK_Visualizaciones_Usuarios]
GO

ALTER TABLE [dbo].[VisualizacionProductos]  WITH CHECK ADD  CONSTRAINT [FK_VisualizacionProductos_Productos] FOREIGN KEY([IdProducto])
REFERENCES [dbo].[Productos] ([IdProducto])
GO

ALTER TABLE [dbo].[VisualizacionProductos] CHECK CONSTRAINT [FK_VisualizacionProductos_Productos]
GO

ALTER TABLE [dbo].[VisualizacionProductos]  WITH CHECK ADD  CONSTRAINT [FK_VisualizacionProductos_ProductoVariantes] FOREIGN KEY([IdVariante])
REFERENCES [dbo].[ProductoVariantes] ([IdVariante])
GO

ALTER TABLE [dbo].[VisualizacionProductos] CHECK CONSTRAINT [FK_VisualizacionProductos_ProductoVariantes]
GO

ALTER TABLE [dbo].[VisualizacionProductos]  WITH CHECK ADD  CONSTRAINT [FK_VisualizacionProductos_Visualizaciones] FOREIGN KEY([IdVisualizacion])
REFERENCES [dbo].[Visualizaciones] ([IdVisualizacion])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[VisualizacionProductos] CHECK CONSTRAINT [FK_VisualizacionProductos_Visualizaciones]
GO

-- ============================================================================
-- Funciones y vistas
-- ============================================================================

-- ============================================================================
-- Procedimientos almacenados
-- ============================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Mantiene al dia la direccion del cliente cuando confirma una entrega distinta.
CREATE   PROCEDURE dbo.SP_ActualizarDireccionCliente
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* 5. Cambio de estado ----------------------------------------------------- */
CREATE   PROCEDURE dbo.SP_ActualizarEstadoFactura
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ActualizarEstadoPedido
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ActualizarInformacionEmpresa
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[SP_ActualizarInformacionUsuario]
(
	@IdUsuario INT,
	@Nombre VARCHAR(100),
	@Apellido VARCHAR(100),
	@Correo VARCHAR(150),
	@Telefono VARCHAR(20),
	@Direccion VARCHAR(255),
	@Contrasena VARCHAR(255) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		-- Verificar que el usuario exista
		IF NOT EXISTS (
			SELECT 1
			FROM Usuarios
			WHERE IdUsuario = @IdUsuario
		)
		BEGIN
			SELECT
				0 AS Codigo,
				'El usuario no existe.' AS Mensaje;

			ROLLBACK TRANSACTION;
			RETURN;
		END;


		-- Verificar que el correo no pertenezca a otro usuario
		IF EXISTS (
			SELECT 1
			FROM Usuarios
			WHERE Correo = @Correo
			  AND IdUsuario <> @IdUsuario
		)
		BEGIN
			SELECT
				0 AS Codigo,
				'El correo ya se encuentra registrado por otro usuario.' AS Mensaje;

			ROLLBACK TRANSACTION;
			RETURN;
		END;


		/*
			Si @Contrasena es NULL:
			se mantiene la contraseÃ±a actual.

			Si @Contrasena tiene un valor:
			se genera un nuevo hash SHA2_256.
		*/

		IF @Contrasena IS NULL OR LTRIM(RTRIM(@Contrasena)) = ''
		BEGIN

			UPDATE Usuarios
			SET
				Nombre = @Nombre,
				Apellido = @Apellido,
				Correo = @Correo,
				Telefono = @Telefono
			WHERE IdUsuario = @IdUsuario;

		END
		ELSE
		BEGIN

			DECLARE @ContrasenaHash VARCHAR(64);

			SET @ContrasenaHash =
				CONVERT(
					VARCHAR(64),
					HASHBYTES('SHA2_256', @Contrasena),
					2
				);

			UPDATE Usuarios
			SET
				Nombre = @Nombre,
				Apellido = @Apellido,
				Correo = @Correo,
				Telefono = @Telefono,
				ContrasenaHash = @ContrasenaHash
			WHERE IdUsuario = @IdUsuario;

		END;


		-- Actualizar informaciÃ³n del cliente
		UPDATE Clientes
		SET
			Nombre = @Nombre,
			Apellido = @Apellido,
			Correo = @Correo,
			Telefono = @Telefono,
			Direccion = @Direccion
		WHERE IdUsuario = @IdUsuario;


		COMMIT TRANSACTION;


		SELECT
			1 AS Codigo,
			'InformaciÃ³n del usuario actualizada correctamente.' AS Mensaje,
			@IdUsuario AS IdUsuario;


	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT
			-1 AS Codigo,
			ERROR_MESSAGE() AS Mensaje;

	END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* --------------------------------------------------------------------------
   4. Ajuste de existencias
   -------------------------------------------------------------------------- */
CREATE   PROCEDURE dbo.SP_ActualizarInventario
(
    @IdProducto         INT,
    @CantidadDisponible INT,
    @CantidadMinima     INT,
    @IdUsuario          INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @CantidadDisponible < 0 OR @CantidadMinima < 0
        BEGIN
            SELECT 0 AS Codigo, 'CANTIDAD_INVALIDA' AS Mensaje;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.Productos WHERE IdProducto = @IdProducto)
        BEGIN
            SELECT 0 AS Codigo, 'PRODUCTO_NO_ENCONTRADO' AS Mensaje;
            RETURN;
        END

        DECLARE @Anterior INT =
            (SELECT ISNULL(CantidadDisponible, 0) FROM dbo.Inventario WHERE IdProducto = @IdProducto);

        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM dbo.Inventario WHERE IdProducto = @IdProducto)
        BEGIN
            UPDATE dbo.Inventario
            SET CantidadDisponible = @CantidadDisponible,
                CantidadMinima     = @CantidadMinima,
                FechaActualizacion = GETDATE()
            WHERE IdProducto = @IdProducto;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.Inventario (IdProducto, CantidadDisponible, CantidadMinima, FechaActualizacion)
            VALUES (@IdProducto, @CantidadDisponible, @CantidadMinima, GETDATE());
        END

        -- El resumen del producto y el inventario deben contar lo mismo: el
        -- catalogo y la validacion del carrito leen Productos.Stock.
        UPDATE dbo.Productos
        SET Stock = @CantidadDisponible
        WHERE IdProducto = @IdProducto;

        INSERT INTO dbo.Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora)
        VALUES (@IdUsuario, 'Inventario', 'UPDATE',
                CONCAT('Existencias del producto #', @IdProducto, ' ajustadas de ',
                       ISNULL(@Anterior, 0), ' a ', @CantidadDisponible,
                       ' (minimo ', @CantidadMinima, ').'),
                GETDATE());

        COMMIT TRANSACTION;

        SELECT 1 AS Codigo, 'INVENTARIO_ACTUALIZADO' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ActualizarPreferenciasUsuario
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_ActualizarProducto]
(
    @IdProducto INT,
    @Nombre VARCHAR(150),
    @Descripcion VARCHAR(MAX),
    @Precio DECIMAL(10,2),
    @Imagen VARCHAR(255) = NULL,
    @IdCategoria INT,
    @CantidadDisponible INT,
    @CantidadMinima INT,
    @Estado VARCHAR(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validar que exista el producto
        IF NOT EXISTS
        (
            SELECT 1
            FROM Productos
            WHERE IdProducto = @IdProducto
        )
        BEGIN
            RAISERROR('El producto no existe.',16,1);
            RETURN;
        END

        -- Validar categoría
        IF NOT EXISTS
        (
            SELECT 1
            FROM Categorias
            WHERE IdCategoria = @IdCategoria
        )
        BEGIN
            RAISERROR('La categoría indicada no existe.',16,1);
            RETURN;
        END

        -- Actualizar producto
        UPDATE Productos
        SET
            Nombre = @Nombre,
            Descripcion = @Descripcion,
            Precio = @Precio,
            IdCategoria = @IdCategoria,
            Estado = @Estado,
            Stock = @CantidadDisponible,
            Imagen = CASE
                        WHEN @Imagen IS NULL OR @Imagen = ''
                        THEN Imagen
                        ELSE @Imagen
                     END
        WHERE IdProducto = @IdProducto;

        -- Actualizar inventario
        UPDATE Inventario
        SET
            CantidadDisponible = @CantidadDisponible,
            CantidadMinima = @CantidadMinima,
            FechaActualizacion = GETDATE()
        WHERE IdProducto = @IdProducto;

        SELECT
            1 AS Codigo,
            'Producto actualizado correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ActualizarUsuario]
(
    @IdUsuario INT,
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Correo VARCHAR(150),
    @Contrasena VARCHAR(255) = NULL,
    @Telefono VARCHAR(20),
    @IdRol INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Validar existencia del usuario
        IF NOT EXISTS (
            SELECT 1
            FROM Usuarios
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'El usuario no existe.' AS Mensaje;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar correo duplicado
        IF EXISTS (
            SELECT 1
            FROM Usuarios
            WHERE Correo = @Correo
              AND IdUsuario <> @IdUsuario
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'El correo ya pertenece a otro usuario.' AS Mensaje;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar rol
        IF NOT EXISTS (
            SELECT 1
            FROM Roles
            WHERE IdRol = @IdRol
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'El rol indicado no existe.' AS Mensaje;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar incluyendo contraseña
        IF @Contrasena IS NOT NULL AND LTRIM(RTRIM(@Contrasena)) <> ''
        BEGIN
            DECLARE @ContrasenaHash VARCHAR(64);

            SET @ContrasenaHash =
                CONVERT(VARCHAR(64),
                        HASHBYTES('SHA2_256', @Contrasena),
                        2);

            UPDATE Usuarios
            SET
                Nombre = @Nombre,
                Apellido = @Apellido,
                Correo = @Correo,
                ContrasenaHash = @ContrasenaHash,
                Telefono = @Telefono,
                IdRol = @IdRol
            WHERE IdUsuario = @IdUsuario;
        END
        ELSE
        BEGIN
            UPDATE Usuarios
            SET
                Nombre = @Nombre,
                Apellido = @Apellido,
                Correo = @Correo,
                Telefono = @Telefono,
                IdRol = @IdRol
            WHERE IdUsuario = @IdUsuario;
        END

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'Usuario actualizado correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_CancelarPedido
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
        FROM dbo.Pedidos WITH (UPDLOCK, HOLDLOCK)
        WHERE IdPedido = @IdPedido;

        IF @EstadoActual IS NULL
        BEGIN
            THROW 51004, 'PEDIDO_NO_ENCONTRADO', 1;
        END;

        IF @EstadoActual IN ('Cancelado', 'Entregado')
        BEGIN
            THROW 51005, 'PEDIDO_NO_CANCELABLE', 1;
        END;

        SELECT
            IdProducto,
            SUM(Cantidad) AS Cantidad
        INTO #ProductosDevueltos
        FROM dbo.DetallePedido
        WHERE IdPedido = @IdPedido
        GROUP BY IdProducto;

        SELECT
            IdVariante,
            SUM(Cantidad) AS Cantidad
        INTO #VariantesDevueltas
        FROM dbo.DetallePedido
        WHERE IdPedido = @IdPedido
          AND IdVariante IS NOT NULL
        GROUP BY IdVariante;

        UPDATE P
        SET P.Stock = ISNULL(P.Stock, 0) + D.Cantidad
        FROM dbo.Productos P
        INNER JOIN #ProductosDevueltos D
            ON D.IdProducto = P.IdProducto;

        UPDATE V
        SET V.Stock = V.Stock + D.Cantidad
        FROM dbo.ProductoVariantes V
        INNER JOIN #VariantesDevueltas D
            ON D.IdVariante = V.IdVariante;

        UPDATE dbo.Pedidos
        SET Estado = 'Cancelado'
        WHERE IdPedido = @IdPedido;

        INSERT dbo.Bitacora
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
            CONCAT(
                'Pedido #',
                @IdPedido,
                ' cancelado. Estado previo: "',
                @EstadoActual,
                '".'),
            GETDATE()
        );

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'PEDIDO_CANCELADO' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ConvertirCotizacionEnPedido
(
    @IdCotizacion INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @IdCliente INT;
        DECLARE @Estado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);
        DECLARE @IdPedido INT;
        DECLARE @DireccionEntrega VARCHAR(255);
        DECLARE @ProductosEsperados INT;

        SELECT
            @IdCliente = C.IdCliente,
            @Estado = C.Estado,
            @Total = C.Total,
            @DireccionEntrega = ISNULL(
                NULLIF(LTRIM(RTRIM(CL.Direccion)), ''),
                'Pendiente de confirmar')
        FROM dbo.Cotizaciones C WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.Clientes CL
            ON CL.IdCliente = C.IdCliente
        WHERE C.IdCotizacion = @IdCotizacion;

        IF @IdCliente IS NULL
        BEGIN
            THROW 50031, 'COTIZACION_NO_EXISTE', 1;
        END;

        IF @Estado <> 'Aprobada'
        BEGIN
            THROW 50032, 'COTIZACION_NO_APROBADA', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM dbo.Pedidos
            WHERE IdCotizacion = @IdCotizacion
        )
        BEGIN
            THROW 50035, 'COTIZACION_YA_PROCESADA', 1;
        END;

        SELECT
            D.IdProducto,
            SUM(D.Cantidad) AS Cantidad
        INTO #ProductosReservados
        FROM dbo.DetalleCotizacion D
        WHERE D.IdCotizacion = @IdCotizacion
        GROUP BY D.IdProducto;

        IF NOT EXISTS (SELECT 1 FROM #ProductosReservados)
        BEGIN
            THROW 50033, 'COTIZACION_SIN_PRODUCTOS', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM #ProductosReservados
            WHERE Cantidad <= 0
        )
        BEGIN
            THROW 50036, 'CANTIDAD_INVALIDA', 1;
        END;

        SELECT @ProductosEsperados = COUNT(*)
        FROM #ProductosReservados;

        UPDATE P WITH (UPDLOCK, HOLDLOCK)
        SET P.Stock = P.Stock - R.Cantidad
        FROM dbo.Productos P
        INNER JOIN #ProductosReservados R
            ON R.IdProducto = P.IdProducto
        WHERE P.Estado = 'Activo'
          AND ISNULL(P.Stock, 0) >= R.Cantidad;

        IF @@ROWCOUNT <> @ProductosEsperados
        BEGIN
            THROW 50034, 'STOCK_INSUFICIENTE', 1;
        END;

        SELECT @Total = SUM(D.Subtotal)
        FROM dbo.DetalleCotizacion D
        WHERE D.IdCotizacion = @IdCotizacion;

        INSERT dbo.Pedidos
        (
            IdCliente,
            FechaPedido,
            Estado,
            DireccionEntrega,
            Total,
            IdCotizacion
        )
        VALUES
        (
            @IdCliente,
            GETDATE(),
            'Pendiente',
            @DireccionEntrega,
            @Total,
            @IdCotizacion
        );

        SET @IdPedido = CONVERT(INT, SCOPE_IDENTITY());

        INSERT dbo.DetallePedido
        (
            IdPedido,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT
            @IdPedido,
            D.IdProducto,
            D.Cantidad,
            D.PrecioUnitario,
            D.Subtotal
        FROM dbo.DetalleCotizacion D
        WHERE D.IdCotizacion = @IdCotizacion;

        UPDATE dbo.Cotizaciones
        SET Total = @Total
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'Cotizacion convertida en pedido correctamente.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            'Aprobada' AS Estado,
            @Total AS Total,
            @IdPedido AS IdPedido;

        SELECT
            D.IdProducto,
            P.Nombre,
            P.Imagen,
            D.Cantidad,
            D.PrecioUnitario,
            D.Subtotal
        FROM dbo.DetalleCotizacion D
        INNER JOIN dbo.Productos P
            ON P.IdProducto = D.IdProducto
        WHERE D.IdCotizacion = @IdCotizacion
        ORDER BY D.IdDetalleCotizacion;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            '' AS Estado,
            CAST(0 AS DECIMAL(18,2)) AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_CrearCotizacionConImagenes
(
    @IdUsuario INT,
    @Descripcion VARCHAR(1000),
    @Preferencias VARCHAR(1000),
    @ProductosSolicitados dbo.TVP_SolicitudCotizacionProducto READONLY,
    @Imagenes dbo.TVP_CotizacionImagen READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCliente INT;
    DECLARE @IdCotizacion INT;
    DECLARE @Correo VARCHAR(150);
    DECLARE @NumeroSeguimiento VARCHAR(30);

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario
              AND Estado = 'Activo'
        )
        BEGIN
            THROW 50001, 'USUARIO_NO_EXISTE', 1;
        END;

        IF NULLIF(LTRIM(RTRIM(@Descripcion)), '') IS NULL
        BEGIN
            THROW 50002, 'DESCRIPCION_REQUERIDA', 1;
        END;

        IF NULLIF(LTRIM(RTRIM(@Preferencias)), '') IS NULL
        BEGIN
            THROW 50003, 'PREFERENCIAS_REQUERIDAS', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @ProductosSolicitados)
        BEGIN
            THROW 50004, 'PRODUCTOS_REQUERIDOS', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @ProductosSolicitados S
            GROUP BY S.IdProducto
            HAVING COUNT(*) > 1
        )
        BEGIN
            THROW 50005, 'PRODUCTO_DUPLICADO', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @ProductosSolicitados S
            LEFT JOIN dbo.Productos P
                ON P.IdProducto = S.IdProducto
               AND P.Estado = 'Activo'
            WHERE P.IdProducto IS NULL
               OR S.Cantidad <= 0
        )
        BEGIN
            THROW 50006, 'PRODUCTO_NO_DISPONIBLE', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @Imagenes)
        BEGIN
            THROW 50007, 'IMAGEN_REQUERIDA', 1;
        END;

        SELECT @IdCliente = C.IdCliente
        FROM dbo.Clientes C
        WHERE C.IdUsuario = @IdUsuario;

        IF @IdCliente IS NULL
        BEGIN
            SELECT @Correo = U.Correo
            FROM dbo.Usuarios U
            WHERE U.IdUsuario = @IdUsuario;

            SELECT @IdCliente = C.IdCliente
            FROM dbo.Clientes C
            WHERE C.Correo = @Correo
              AND C.IdUsuario IS NULL;

            IF @IdCliente IS NOT NULL
            BEGIN
                UPDATE dbo.Clientes
                SET IdUsuario = @IdUsuario
                WHERE IdCliente = @IdCliente;
            END;
            ELSE
            BEGIN
                INSERT dbo.Clientes
                (
                    Nombre,
                    Apellido,
                    Correo,
                    Telefono,
                    FechaRegistro,
                    Estado,
                    IdUsuario
                )
                SELECT
                    U.Nombre,
                    ISNULL(U.Apellido, ''),
                    U.Correo,
                    U.Telefono,
                    GETDATE(),
                    'Activo',
                    U.IdUsuario
                FROM dbo.Usuarios U
                WHERE U.IdUsuario = @IdUsuario;

                SET @IdCliente = SCOPE_IDENTITY();
            END;
        END;

        INSERT dbo.Cotizaciones
        (
            IdCliente,
            FechaCotizacion,
            Estado,
            Total,
            Descripcion,
            Preferencias
        )
        VALUES
        (
            @IdCliente,
            GETDATE(),
            'Pendiente',
            0,
            LTRIM(RTRIM(@Descripcion)),
            LTRIM(RTRIM(@Preferencias))
        );

        SET @IdCotizacion = SCOPE_IDENTITY();
        SET @NumeroSeguimiento =
            CONCAT('COT-', RIGHT(REPLICATE('0', 10) +
                CONVERT(VARCHAR(10), @IdCotizacion), 10));

        UPDATE dbo.Cotizaciones
        SET NumeroSeguimiento = @NumeroSeguimiento
        WHERE IdCotizacion = @IdCotizacion;

        INSERT dbo.SolicitudCotizacionProductos
        (
            IdCotizacion,
            IdProducto,
            Cantidad
        )
        SELECT
            @IdCotizacion,
            S.IdProducto,
            S.Cantidad
        FROM @ProductosSolicitados S;

        INSERT dbo.CotizacionImagenes
        (
            IdCotizacion,
            RutaArchivo,
            NombreOriginal,
            TipoContenido,
            TamanoBytes
        )
        SELECT
            @IdCotizacion,
            I.RutaArchivo,
            I.NombreOriginal,
            I.TipoContenido,
            I.TamanoBytes
        FROM @Imagenes I;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'Cotizacion recibida y lista para ser procesada.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            @NumeroSeguimiento AS NumeroSeguimiento,
            COUNT(*) AS CantidadImagenes
        FROM @Imagenes;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            '' AS NumeroSeguimiento,
            0 AS CantidadImagenes;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_DecidirCotizacion
(
    @IdUsuario INT,
    @IdCotizacion INT,
    @Aceptar BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @IdCliente INT;
        DECLARE @Estado VARCHAR(30);
        DECLARE @NuevoEstado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);

        SELECT
            @IdCliente = C.IdCliente,
            @Estado = C.Estado,
            @Total = C.Total
        FROM dbo.Cotizaciones C WITH (UPDLOCK, HOLDLOCK)
        INNER JOIN dbo.Clientes CL
            ON CL.IdCliente = C.IdCliente
        INNER JOIN dbo.Usuarios U
            ON U.IdUsuario = CL.IdUsuario
           AND U.Estado = 'Activo'
        WHERE C.IdCotizacion = @IdCotizacion
          AND CL.IdUsuario = @IdUsuario;

        IF @IdCliente IS NULL
        BEGIN
            THROW 50011, 'COTIZACION_NO_PERTENECE_AL_USUARIO', 1;
        END;

        IF @Estado <> 'Respondida'
        BEGIN
            THROW 50012, 'COTIZACION_ESTADO_INVALIDO', 1;
        END;

        IF @Aceptar = 1
           AND NOT EXISTS
           (
               SELECT 1
               FROM dbo.DetalleCotizacion
               WHERE IdCotizacion = @IdCotizacion
           )
        BEGIN
            THROW 50013, 'COTIZACION_SIN_PRODUCTOS', 1;
        END;

        SET @NuevoEstado =
            CASE WHEN @Aceptar = 1 THEN 'Aceptada' ELSE 'Rechazada' END;

        UPDATE dbo.Cotizaciones
        SET Estado = @NuevoEstado
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            CASE
                WHEN @Aceptar = 1
                    THEN 'Cotizacion aceptada y enviada a revision de ventas.'
                ELSE 'Cotizacion rechazada correctamente.'
            END AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            @NuevoEstado AS Estado,
            @Total AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            '' AS Estado,
            CAST(0 AS DECIMAL(18,2)) AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_DesactivarUsuario]
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1
            FROM Usuarios
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'El usuario no existe.' AS Mensaje;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Usuarios
        SET IdRol = 4
        WHERE IdUsuario = @IdUsuario;

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'Usuario desactivado correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ======================================================
-- DUPLICACION DE PRODUCTOS
-- ======================================================

-- Crea una copia del producto indicado, incluyendo inventario y variantes,
-- y la deja en estado Borrador para que no aparezca en el catalogo publico.
CREATE   PROCEDURE dbo.SP_DuplicarProducto
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_EliminarProducto]
(
    @IdProducto INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validar que el producto exista
        IF NOT EXISTS
        (
            SELECT 1
            FROM Productos
            WHERE IdProducto = @IdProducto
        )
        BEGIN
            RAISERROR('El producto no existe.',16,1);
            RETURN;
        END

        -- Validar que no esté ya inactivo
        IF EXISTS
        (
            SELECT 1
            FROM Productos
            WHERE IdProducto = @IdProducto
            AND Estado = 'Inactivo'
        )
        BEGIN
            RAISERROR('El producto ya se encuentra inactivo.',16,1);
            RETURN;
        END

        -- Borrado lógico
        UPDATE Productos
        SET
            Estado = 'Inactivo'
        WHERE IdProducto = @IdProducto;

        SELECT
            1 AS Codigo,
            'Producto desactivado correctamente.' AS Mensaje;

    END TRY
    BEGIN CATCH

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_EliminarVisualizacion
(
    @IdUsuario INT,
    @IdVisualizacion INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RutaImagenEspacio VARCHAR(255) = NULL;

    SELECT
        @RutaImagenEspacio = RutaImagenEspacio
    FROM dbo.Visualizaciones
    WHERE IdVisualizacion = @IdVisualizacion
      AND IdUsuario = @IdUsuario;

    IF @RutaImagenEspacio IS NULL
    BEGIN
        SELECT
            0 AS Codigo,
            'VISUALIZACION_NO_ENCONTRADA' AS Mensaje,
            NULL AS RutaImagenEspacio;

        RETURN;
    END

    DELETE FROM dbo.Visualizaciones
    WHERE IdVisualizacion = @IdVisualizacion
      AND IdUsuario = @IdUsuario;

    SELECT
        1 AS Codigo,
        'VISUALIZACION_ELIMINADA' AS Mensaje,
        @RutaImagenEspacio AS RutaImagenEspacio;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ======================================================
-- ESCALAMIENTO DE CHAT
-- Se conserva el comportamiento anterior y solo se completan
-- los nuevos campos de clasificacion de la notificacion.
-- ======================================================

CREATE   PROCEDURE dbo.SP_EscalarChatASoporte
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_EstadisticasClientesFrecuentes
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_EstadisticasDashboard
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_EstadisticasPorCategoria
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_EstadisticasProductosDestacados
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_EstadisticasResumenNegocio
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_FinalizarChat
(
    @IdChat INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Chats WHERE IdChat = @IdChat)
    BEGIN
        SELECT
            0 AS Codigo,
            'CHAT_NO_EXISTE' AS Mensaje;

        RETURN;
    END

    UPDATE dbo.Chats
    SET
        Estado = 'Finalizado',
        FechaCierre = GETDATE()
    WHERE IdChat = @IdChat;

    SELECT
        1 AS Codigo,
        'CHAT_FINALIZADO' AS Mensaje;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_GenerarRecomendacionesAsesor
(
    @Opciones dbo.TVP_AsesorOpcion READONLY,
    @LimitePorClasificacion INT = 4
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @LimitePorClasificacion =
        CASE
            WHEN @LimitePorClasificacion < 1 THEN 4
            WHEN @LimitePorClasificacion > 12 THEN 12
            ELSE @LimitePorClasificacion
        END;

    SELECT
        CR.IdCategoria,
        CR.IdTipo,
        CR.PalabraClave,
        CR.Peso
    INTO #CriteriosSeleccionados
    FROM dbo.AsesorCriterios CR
    INNER JOIN @Opciones O
        ON O.IdOpcion = CR.IdOpcion;

    SELECT
        P.IdProducto,
        ISNULL(CC.Clasificacion, 'Otro') AS Clasificacion,
        ISNULL
        (
            (
                SELECT SUM(CS.Peso)
                FROM #CriteriosSeleccionados CS
                WHERE
                    (CS.IdCategoria IS NOT NULL AND CS.IdCategoria = P.IdCategoria)
                    OR (CS.IdTipo IS NOT NULL AND CS.IdTipo = P.IdTipo)
                    OR
                    (
                        CS.PalabraClave IS NOT NULL
                        AND
                        (
                            P.Nombre COLLATE Latin1_General_CI_AI LIKE '%' + CS.PalabraClave + '%'
                            OR CONVERT(NVARCHAR(MAX), P.Descripcion) COLLATE Latin1_General_CI_AI
                                LIKE '%' + CS.PalabraClave + '%'
                            OR ISNULL(P.Caracteristicas, '') COLLATE Latin1_General_CI_AI
                                LIKE '%' + CS.PalabraClave + '%'
                            OR ISNULL(P.Material, '') COLLATE Latin1_General_CI_AI
                                LIKE '%' + CS.PalabraClave + '%'
                            OR ISNULL(P.Tamano, '') COLLATE Latin1_General_CI_AI
                                LIKE '%' + CS.PalabraClave + '%'
                        )
                    )
            ),
            0
        ) AS Puntaje
    INTO #ProductosPuntuados
    FROM dbo.Productos P
    LEFT JOIN dbo.CategoriaClasificacion CC
        ON CC.IdCategoria = P.IdCategoria
    WHERE P.Estado = 'Activo'
      AND ISNULL(P.Stock, 0) > 0;

    SELECT
        R.IdProducto,
        P.Nombre,
        ISNULL(CONVERT(NVARCHAR(MAX), P.Descripcion), '') AS Descripcion,
        P.Precio,
        ISNULL(P.Imagen, '') AS Imagen,
        P.IdCategoria,
        C.NombreCategoria,
        ISNULL(T.NombreTipo, '') AS NombreTipo,
        ISNULL(P.Tamano, '') AS Tamano,
        ISNULL(P.Material, '') AS Material,
        ISNULL(P.Stock, 0) AS Stock,
        R.Clasificacion,
        R.Puntaje
    FROM
    (
        SELECT
            PP.IdProducto,
            PP.Clasificacion,
            PP.Puntaje,
            ROW_NUMBER() OVER
            (
                PARTITION BY PP.Clasificacion
                ORDER BY PP.Puntaje DESC, PP.IdProducto DESC
            ) AS Posicion
        FROM #ProductosPuntuados PP
    ) R
    INNER JOIN dbo.Productos P
        ON P.IdProducto = R.IdProducto
    INNER JOIN dbo.Categorias C
        ON C.IdCategoria = P.IdCategoria
    LEFT JOIN dbo.TiposProducto T
        ON T.IdTipo = P.IdTipo
    WHERE R.Posicion <= @LimitePorClasificacion
      AND R.Clasificacion <> 'Otro'
    ORDER BY
        R.Clasificacion,
        R.Puntaje DESC,
        R.IdProducto DESC;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_GuardarRespuestasAsesor
(
    @IdUsuario INT,
    @Opciones dbo.TVP_AsesorOpcion READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.Usuarios
        WHERE IdUsuario = @IdUsuario
          AND Estado = 'Activo'
    )
    BEGIN
        SELECT
            0 AS Codigo,
            'USUARIO_NO_EXISTE' AS Mensaje;

        RETURN;
    END

    BEGIN TRANSACTION;

    DELETE FROM dbo.AsesorRespuestas
    WHERE IdUsuario = @IdUsuario;

    INSERT dbo.AsesorRespuestas (IdUsuario, IdPregunta, IdOpcion)
    SELECT
        @IdUsuario,
        O.IdPregunta,
        O.IdOpcion
    FROM dbo.AsesorOpciones O
    INNER JOIN @Opciones S
        ON S.IdOpcion = O.IdOpcion;

    COMMIT TRANSACTION;

    SELECT
        1 AS Codigo,
        'RESPUESTAS_GUARDADAS' AS Mensaje;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ---------------------------------------------------------------------------
-- 4. Procedimientos.
-- ---------------------------------------------------------------------------

-- Crea o actualiza una visualizacion. Devuelve la ruta de la imagen anterior
-- cuando se reemplaza, para que la API pueda borrar el archivo en desuso.
CREATE   PROCEDURE dbo.SP_GuardarVisualizacion
(
    @IdUsuario INT,
    @IdVisualizacion INT = NULL,
    @Nombre VARCHAR(120),
    @RutaImagenEspacio VARCHAR(255),
    @AnchoLienzo INT,
    @AltoLienzo INT,
    @Productos dbo.TVP_VisualizacionProducto READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RutaImagenAnterior VARCHAR(255) = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario
              AND Estado = 'Activo'
        )
        BEGIN
            THROW 52001, 'USUARIO_NO_EXISTE', 1;
        END

        IF NOT EXISTS (SELECT 1 FROM @Productos)
        BEGIN
            THROW 52002, 'SIN_PRODUCTOS', 1;
        END

        IF EXISTS
        (
            SELECT 1
            FROM @Productos P
            LEFT JOIN dbo.Productos PR
                ON PR.IdProducto = P.IdProducto
            WHERE PR.IdProducto IS NULL
               OR PR.Estado <> 'Activo'
        )
        BEGIN
            THROW 52003, 'PRODUCTO_NO_DISPONIBLE', 1;
        END

        IF @IdVisualizacion IS NOT NULL
        BEGIN
            SELECT
                @RutaImagenAnterior = RutaImagenEspacio
            FROM dbo.Visualizaciones
            WHERE IdVisualizacion = @IdVisualizacion
              AND IdUsuario = @IdUsuario;

            IF @RutaImagenAnterior IS NULL
            BEGIN
                THROW 52004, 'VISUALIZACION_NO_ENCONTRADA', 1;
            END

            UPDATE dbo.Visualizaciones
            SET
                Nombre = @Nombre,
                RutaImagenEspacio = @RutaImagenEspacio,
                AnchoLienzo = @AnchoLienzo,
                AltoLienzo = @AltoLienzo,
                FechaActualizacion = SYSDATETIME(),
                Estado = 'Activo'
            WHERE IdVisualizacion = @IdVisualizacion
              AND IdUsuario = @IdUsuario;

            DELETE FROM dbo.VisualizacionProductos
            WHERE IdVisualizacion = @IdVisualizacion;

            IF @RutaImagenAnterior = @RutaImagenEspacio
            BEGIN
                SET @RutaImagenAnterior = NULL;
            END
        END
        ELSE
        BEGIN
            INSERT INTO dbo.Visualizaciones
            (
                IdUsuario,
                Nombre,
                RutaImagenEspacio,
                AnchoLienzo,
                AltoLienzo
            )
            VALUES
            (
                @IdUsuario,
                @Nombre,
                @RutaImagenEspacio,
                @AnchoLienzo,
                @AltoLienzo
            );

            SET @IdVisualizacion = CONVERT(INT, SCOPE_IDENTITY());
        END

        INSERT INTO dbo.VisualizacionProductos
        (
            IdVisualizacion,
            IdProducto,
            IdVariante,
            Cantidad,
            Color,
            Macetero,
            PosicionX,
            PosicionY,
            Ancho,
            Alto,
            Rotacion,
            Orden
        )
        SELECT
            @IdVisualizacion,
            P.IdProducto,
            P.IdVariante,
            P.Cantidad,
            ISNULL(P.Color, ''),
            ISNULL(P.Macetero, ''),
            P.PosicionX,
            P.PosicionY,
            P.Ancho,
            P.Alto,
            P.Rotacion,
            P.Orden
        FROM @Productos P;

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'VISUALIZACION_GUARDADA' AS Mensaje,
            @IdVisualizacion AS IdVisualizacion,
            @RutaImagenAnterior AS RutaImagenAnterior;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Codigo,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS IdVisualizacion,
            NULL AS RutaImagenAnterior;
    END CATCH
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE SP_InsertarBitacora
(
    @IdUsuario     INT,
    @TablaAfectada VARCHAR(100),
    @Operacion     VARCHAR(20),
    @Descripcion   VARCHAR(500),
    @IpUsuario     VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        INSERT INTO Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, IpUsuario)
        VALUES (@IdUsuario, @TablaAfectada, @Operacion, @Descripcion, @IpUsuario);

        DECLARE @IdBitacora INT = SCOPE_IDENTITY();

        SELECT
            1           AS Codigo,
            'Registro guardado en bitácora.' AS Mensaje,
            @IdBitacora AS IdBitacora;

    END TRY
    BEGIN CATCH
        SELECT
            -1              AS Codigo,
            ERROR_MESSAGE() AS Mensaje,
            NULL            AS IdBitacora;
    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_InsertarProducto]
(
    @Nombre VARCHAR(150),
    @Descripcion VARCHAR(MAX),
    @Precio DECIMAL(10,2),
    @Imagen VARCHAR(255),
    @IdCategoria INT,
    @CantidadDisponible INT,
    @CantidadMinima INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Validar categoría
        IF NOT EXISTS
        (
            SELECT 1
            FROM Categorias
            WHERE IdCategoria = @IdCategoria
            AND Estado = 'Activo'
        )
        BEGIN
            RAISERROR('La categoría no existe o está inactiva.',16,1);
            RETURN;
        END

        -- Insertar producto
        INSERT INTO Productos
        (
            Nombre,
            Descripcion,
            Precio,
            Stock,
            Imagen,
            IdCategoria
        )
        VALUES
        (
            @Nombre,
            @Descripcion,
            @Precio,
            @CantidadDisponible,
            @Imagen,
            @IdCategoria
        );

        DECLARE @IdProducto INT = SCOPE_IDENTITY();

        -- Insertar inventario
        INSERT INTO Inventario
        (
            IdProducto,
            CantidadDisponible,
            CantidadMinima
        )
        VALUES
        (
            @IdProducto,
            @CantidadDisponible,
            @CantidadMinima
        );

        -- Respuesta exitosa
        SELECT
            1 AS Codigo,
            'Producto registrado correctamente.' AS Mensaje,
            @IdProducto AS IdProducto;

    END TRY
    BEGIN CATCH

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_InsertarUsuario]
(
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Correo VARCHAR(150),
    @Contrasena VARCHAR(255),
    @Telefono VARCHAR(20),
    @IdRol INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM Usuarios
            WHERE Correo = @Correo
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'El correo ya se encuentra registrado.' AS Mensaje;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM Roles
            WHERE IdRol = @IdRol
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'El rol indicado no existe.' AS Mensaje;

            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @ContrasenaHash VARCHAR(64);

        SET @ContrasenaHash =
            CONVERT(VARCHAR(64),
                    HASHBYTES('SHA2_256', @Contrasena),
                    2);

        INSERT INTO Usuarios
        (
            Nombre,
            Apellido,
            Correo,
            ContrasenaHash,
            Telefono,
            IdRol
        )
        VALUES
        (
            @Nombre,
            @Apellido,
            @Correo,
            @ContrasenaHash,
            @Telefono,
            @IdRol
        );

        DECLARE @IdUsuario INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'Usuario registrado correctamente.' AS Mensaje,
            @IdUsuario AS IdUsuario;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_LimpiarRespuestasAsesor
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.AsesorRespuestas
    WHERE IdUsuario = @IdUsuario;

    SELECT
        1 AS Codigo,
        'RESPUESTAS_REINICIADAS' AS Mensaje;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_Login]
(
    @Correo VARCHAR(150),
    @Contrasena VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @ContrasenaHash VARCHAR(64);
        DECLARE @IdUsuario INT;
        DECLARE @Intentos INT;

        SET @ContrasenaHash =
            CONVERT(VARCHAR(64),
                    HASHBYTES('SHA2_256', @Contrasena),
                    2);

        -- Validar existencia del usuario
        IF NOT EXISTS
        (
            SELECT 1
            FROM Usuarios
            WHERE Correo = @Correo
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'Correo o contraseña incorrectos.' AS Mensaje;

            RETURN;
        END

        -- Obtener IdUsuario
        SELECT @IdUsuario = IdUsuario
        FROM Usuarios
        WHERE Correo = @Correo;

        -- Validar estado
        IF EXISTS
        (
            SELECT 1
            FROM Usuarios
            WHERE IdUsuario = @IdUsuario
              AND Estado = 'Inactivo'
        )
        BEGIN
            SELECT
                0 AS Codigo,
                'La cuenta se encuentra bloqueada o inactiva.' AS Mensaje;

            RETURN;
        END

        -- Validar credenciales
        IF EXISTS
        (
            SELECT 1
            FROM Usuarios
            WHERE Correo = @Correo
              AND ContrasenaHash = @ContrasenaHash
              AND Estado = 'Activo'
        )
        BEGIN

            -- Reiniciar intentos fallidos
            DELETE FROM IntentosLogin
            WHERE IdUsuario = @IdUsuario;

            SELECT
                1 AS Codigo,
                'Inicio de sesión exitoso.' AS Mensaje,
                IdUsuario,
                IdRol
            FROM Usuarios
            WHERE IdUsuario = @IdUsuario;

        END
        ELSE
        BEGIN

            -- Registrar intento fallido
            IF NOT EXISTS
            (
                SELECT 1
                FROM IntentosLogin
                WHERE IdUsuario = @IdUsuario
            )
            BEGIN

                INSERT INTO IntentosLogin
                (
                    IdUsuario,
                    CantidadIntentos,
                    FechaUltimoIntento
                )
                VALUES
                (
                    @IdUsuario,
                    1,
                    GETDATE()
                );

                SET @Intentos = 1;

            END
            ELSE
            BEGIN

                UPDATE IntentosLogin
                SET
                    CantidadIntentos = CantidadIntentos + 1,
                    FechaUltimoIntento = GETDATE()
                WHERE IdUsuario = @IdUsuario;

                SELECT @Intentos = CantidadIntentos
                FROM IntentosLogin
                WHERE IdUsuario = @IdUsuario;

            END

            -- Bloqueo por 3 intentos
            IF @Intentos >= 3
            BEGIN

                UPDATE Usuarios
                SET Estado = 'Inactivo'
                WHERE IdUsuario = @IdUsuario;

                SELECT
                    0 AS Codigo,
                    'Cuenta bloqueada por exceder el número máximo de intentos permitidos.' AS Mensaje;

                RETURN;

            END

            SELECT
                0 AS Codigo,
                CONCAT(
                    'Correo o contraseña incorrectos. Intento ',
                    @Intentos,
                    ' de 3.'
                ) AS Mensaje;

        END

    END TRY
    BEGIN CATCH

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Marca como leidas todas las notificaciones pendientes del usuario.
CREATE   PROCEDURE dbo.SP_MarcarNotificacionesLeidas
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Marca una notificacion como leida. El filtro por usuario evita
-- que alguien modifique notificaciones de otra cuenta.
CREATE   PROCEDURE dbo.SP_MarcarNotificacionLeida
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE SP_ObtenerBitacora
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        b.IdBitacora    AS idBitacora,
        b.IdUsuario     AS idUsuario,
        u.Correo        AS correo,
        u.Nombre + ' ' + u.Apellido AS nombreUsuario,
        b.TablaAfectada AS tablaAfectada,
        b.Operacion     AS operacion,
        b.Descripcion   AS descripcion,
        b.FechaHora     AS fechaHora,
        b.IpUsuario     AS ipUsuario
    FROM Bitacora b
    INNER JOIN Usuarios u ON b.IdUsuario = u.IdUsuario
    ORDER BY b.FechaHora DESC;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ObtenerCatalogoProductos
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SELECT
            P.IdProducto,
            P.Nombre,
            P.Descripcion,
            P.Precio,
            P.Imagen,
            C.IdCategoria,
            C.NombreCategoria,
            ISNULL(P.Stock, 0) AS Stock,
            CASE
                WHEN ISNULL(P.Stock, 0) > 10 THEN 'Disponible'
                WHEN ISNULL(P.Stock, 0) > 0
                    THEN CONCAT(ISNULL(P.Stock, 0), ' unidades')
                ELSE 'Agotado'
            END AS Disponibilidad
        FROM dbo.Productos P
        INNER JOIN dbo.Categorias C
            ON P.IdCategoria = C.IdCategoria
        WHERE P.Estado = 'Activo'
        ORDER BY P.Nombre;
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_ObtenerCategorias]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT
            IdCategoria,
            NombreCategoria,
            Descripcion,
            Estado
        FROM Categorias
        WHERE Estado = 'Activo'
        ORDER BY NombreCategoria;

    END TRY
    BEGIN CATCH

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ======================================================
-- ATENCION DE CHATS
-- ======================================================

-- Agrega el conteo de mensajes del cliente pendientes de respuesta.
-- Un mensaje esta pendiente cuando llego despues de la ultima respuesta
-- de soporte y la conversacion sigue abierta.
CREATE   PROCEDURE dbo.SP_ObtenerChatsAdmin
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ObtenerConversacionCliente
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdChat INT;

    SELECT TOP (1)
        @IdChat = CH.IdChat
    FROM dbo.Chats CH
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = CH.IdCliente
    WHERE CL.IdUsuario = @IdUsuario
      AND ISNULL(CH.Estado, 'Abierto') <> 'Finalizado'
    ORDER BY CH.IdChat DESC;

    SELECT
        CH.IdChat,
        ISNULL(CH.Estado, 'Abierto') AS Estado,
        CH.FechaInicio,
        CH.FechaCierre
    FROM dbo.Chats CH
    WHERE CH.IdChat = @IdChat;

    SELECT
        M.IdMensaje,
        M.IdChat,
        ISNULL(M.Remitente, 'Bot') AS Remitente,
        ISNULL(M.Mensaje, '') AS Mensaje,
        M.FechaHora
    FROM dbo.MensajesChat M
    WHERE M.IdChat = @IdChat
    ORDER BY M.FechaHora, M.IdMensaje;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ObtenerCotizacionesAdmin
(
    @Pagina INT = 1,
    @TamanoPagina INT = 20,
    @Estado VARCHAR(30) = NULL,
    @Busqueda VARCHAR(100) = NULL,
    @SoloGestionadas BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Pagina = CASE WHEN @Pagina < 1 THEN 1 ELSE @Pagina END;
    SET @TamanoPagina =
        CASE
            WHEN @TamanoPagina < 1 THEN 20
            WHEN @TamanoPagina > 100 THEN 100
            ELSE @TamanoPagina
        END;
    SET @Estado = NULLIF(LTRIM(RTRIM(@Estado)), '');
    SET @Busqueda = NULLIF(LTRIM(RTRIM(@Busqueda)), '');
    SET @SoloGestionadas = ISNULL(@SoloGestionadas, 0);

    DECLARE @PatronBusqueda VARCHAR(306) = NULL;
    IF @Busqueda IS NOT NULL
    BEGIN
        SET @PatronBusqueda =
            '%' +
            REPLACE(
                REPLACE(
                    REPLACE(@Busqueda, '\', '\\'),
                    '%',
                    '\%'),
                '_',
                '\_') +
            '%';
    END;

    SELECT
        C.IdCotizacion,
        C.FechaCotizacion
    INTO #CotizacionesFiltradas
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    WHERE (@Estado IS NULL OR C.Estado = @Estado)
      AND (@SoloGestionadas = 0 OR ISNULL(C.Estado, 'Pendiente') <> 'Pendiente')
      AND
      (
          @PatronBusqueda IS NULL
          OR C.NumeroSeguimiento LIKE @PatronBusqueda ESCAPE '\'
          OR C.Descripcion LIKE @PatronBusqueda ESCAPE '\'
          OR C.Preferencias LIKE @PatronBusqueda ESCAPE '\'
          OR C.Respuesta LIKE @PatronBusqueda ESCAPE '\'
          OR CL.Nombre LIKE @PatronBusqueda ESCAPE '\'
          OR CL.Apellido LIKE @PatronBusqueda ESCAPE '\'
          OR CL.Correo LIKE @PatronBusqueda ESCAPE '\'
          OR EXISTS
          (
              SELECT 1
              FROM dbo.SolicitudCotizacionProductos S
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = S.IdProducto
              WHERE S.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
          OR EXISTS
          (
              SELECT 1
              FROM dbo.DetalleCotizacion D
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = D.IdProducto
              WHERE D.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
      );

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesFiltradas_Id
        ON #CotizacionesFiltradas (IdCotizacion);

    SELECT F.IdCotizacion
    INTO #CotizacionesPagina
    FROM #CotizacionesFiltradas F
    ORDER BY F.FechaCotizacion DESC, F.IdCotizacion DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesPagina_Id
        ON #CotizacionesPagina (IdCotizacion);

    SELECT
        C.IdCotizacion,
        ISNULL(
            C.NumeroSeguimiento,
            CONCAT(
                'COT-',
                RIGHT(
                    REPLICATE('0', 10) +
                    CONVERT(VARCHAR(10), C.IdCotizacion),
                    10))) AS NumeroSeguimiento,
        C.IdCliente,
        CONCAT(CL.Nombre, ' ', CL.Apellido) AS Cliente,
        ISNULL(C.FechaCotizacion, GETDATE()) AS FechaSolicitud,
        ISNULL(C.Estado, 'Pendiente') AS Estado,
        C.Total,
        ISNULL(C.Descripcion, '') AS Descripcion,
        ISNULL(C.Preferencias, '') AS Preferencias,
        ISNULL(C.Respuesta, '') AS Respuesta,
        C.FechaRespuesta,
        P.IdPedido
    FROM #CotizacionesPagina CP
    INNER JOIN dbo.Cotizaciones C
        ON C.IdCotizacion = CP.IdCotizacion
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    LEFT JOIN dbo.Pedidos P
        ON P.IdCotizacion = C.IdCotizacion
    ORDER BY C.FechaCotizacion DESC, C.IdCotizacion DESC;

    SELECT
        D.IdCotizacion,
        D.IdProducto,
        P.Nombre,
        P.Imagen,
        D.Cantidad,
        D.PrecioUnitario,
        D.Subtotal
    FROM dbo.DetalleCotizacion D
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = D.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = D.IdProducto
    ORDER BY D.IdDetalleCotizacion;

    SELECT
        S.IdCotizacion,
        S.IdProducto,
        P.Nombre,
        P.Imagen,
        S.Cantidad
    FROM dbo.SolicitudCotizacionProductos S
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = S.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = S.IdProducto
    ORDER BY S.IdSolicitudCotizacionProducto;

    SELECT
        I.IdCotizacion,
        I.RutaArchivo,
        I.NombreOriginal,
        I.TipoContenido,
        I.TamanoBytes
    FROM dbo.CotizacionImagenes I
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = I.IdCotizacion
    ORDER BY I.IdCotizacionImagen;

    SELECT
        H.IdCotizacion,
        H.EstadoAnterior,
        H.EstadoNuevo,
        H.FechaCambio
    FROM dbo.CotizacionEstadoHistorial H
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = H.IdCotizacion
    ORDER BY
        H.IdCotizacion,
        H.FechaCambio,
        H.IdCotizacionEstadoHistorial;

    SELECT COUNT(*) AS TotalItems
    FROM #CotizacionesFiltradas;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ---------------------------------------------------------------------------
-- 5. Procedimientos del Asesor Inteligente.
-- ---------------------------------------------------------------------------

CREATE   PROCEDURE dbo.SP_ObtenerCuestionarioAsesor
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.IdPregunta,
        P.Codigo,
        P.Texto,
        P.Ayuda,
        P.Orden
    FROM dbo.AsesorPreguntas P
    WHERE P.Estado = 'Activo'
    ORDER BY P.Orden, P.IdPregunta;

    SELECT
        O.IdOpcion,
        O.IdPregunta,
        O.Codigo,
        O.Etiqueta,
        O.Descripcion,
        O.Orden
    FROM dbo.AsesorOpciones O
    INNER JOIN dbo.AsesorPreguntas P
        ON P.IdPregunta = O.IdPregunta
    WHERE O.Estado = 'Activo'
      AND P.Estado = 'Activo'
    ORDER BY O.IdPregunta, O.Orden, O.IdOpcion;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* 4. Detalle -------------------------------------------------------------- */
CREATE   PROCEDURE dbo.SP_ObtenerFacturaDetalle
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* 3. Listado -------------------------------------------------------------- */
CREATE   PROCEDURE dbo.SP_ObtenerFacturasAdmin
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ObtenerInformacionEmpresa
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ObtenerInformacionUsuario
	@IdUsuario INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		U.IdUsuario,
		U.Nombre,
		U.Apellido,
		U.Correo,
		U.Telefono,
		U.Estado,
		U.FechaRegistro,
		U.IdRol,
		R.NombreRol,

		C.IdCliente,
		C.Direccion,
		C.Estado AS EstadoCliente,
		C.FechaRegistro AS FechaRegistroCliente

	FROM Usuarios U
	INNER JOIN Roles R
		ON U.IdRol = R.IdRol
	LEFT JOIN Clientes C
		ON U.IdUsuario = C.IdUsuario

	WHERE U.IdUsuario = @IdUsuario;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ---------------------------------------------------------------------------
-- 3. Procedimientos.
-- ---------------------------------------------------------------------------

CREATE   PROCEDURE dbo.SP_ObtenerIntencionesBot
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        I.IdIntencion,
        I.Codigo,
        I.Respuesta,
        I.SugiereProductos,
        I.SugiereEscalamiento,
        I.Orden
    FROM dbo.BotIntenciones I
    WHERE I.Estado = 'Activo'
    ORDER BY I.Orden, I.IdIntencion;

    SELECT
        P.IdIntencion,
        P.PalabraClave
    FROM dbo.BotIntencionPalabras P
    INNER JOIN dbo.BotIntenciones I
        ON I.IdIntencion = P.IdIntencion
    WHERE I.Estado = 'Activo'
    ORDER BY P.IdIntencion, P.IdPalabra;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* --------------------------------------------------------------------------
   2. Listado de inventario
   -------------------------------------------------------------------------- */
CREATE   PROCEDURE dbo.SP_ObtenerInventario
(
    @Busqueda      NVARCHAR(120) = NULL,
    @IdCategoria   INT           = NULL,
    @Estado        VARCHAR(20)   = NULL,  -- disponible | bajo | agotado
    @Pagina        INT           = 1,
    @TamanoPagina  INT           = 10
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Pagina - 1) * @TamanoPagina;
    DECLARE @Filtro NVARCHAR(140) =
        CASE WHEN NULLIF(LTRIM(RTRIM(@Busqueda)), '') IS NULL
             THEN NULL
             ELSE '%' + LTRIM(RTRIM(@Busqueda)) + '%'
        END;

    ;WITH Base AS (
        SELECT
            P.IdProducto,
            P.Nombre,
            P.Estado                       AS EstadoProducto,
            P.Precio,
            P.Imagen,
            P.IdCategoria,
            C.NombreCategoria,
            ISNULL(I.CantidadDisponible, ISNULL(P.Stock, 0)) AS CantidadDisponible,
            ISNULL(I.CantidadMinima, 0)                      AS CantidadMinima,
            I.FechaActualizacion,
            (SELECT COUNT(1) FROM dbo.ProductoVariantes V
              WHERE V.IdProducto = P.IdProducto)             AS TotalVariantes
        FROM dbo.Productos P
        LEFT JOIN dbo.Inventario I ON I.IdProducto = P.IdProducto
        LEFT JOIN dbo.Categorias C ON C.IdCategoria = P.IdCategoria
    ),
    Clasificada AS (
        SELECT
            Base.*,
            CASE
                WHEN CantidadDisponible <= 0 THEN 'agotado'
                WHEN CantidadDisponible <= CantidadMinima THEN 'bajo'
                ELSE 'disponible'
            END AS EstadoExistencias
        FROM Base
    ),
    Filtrada AS (
        SELECT *
        FROM Clasificada
        WHERE (@Filtro IS NULL OR Nombre LIKE @Filtro)
          AND (@IdCategoria IS NULL OR IdCategoria = @IdCategoria)
          AND (NULLIF(@Estado, '') IS NULL OR EstadoExistencias = @Estado)
    )
    SELECT
        IdProducto,
        Nombre,
        EstadoProducto,
        Precio,
        Imagen,
        IdCategoria,
        NombreCategoria,
        CantidadDisponible,
        CantidadMinima,
        FechaActualizacion,
        TotalVariantes,
        EstadoExistencias,
        COUNT(1) OVER () AS TotalItems
    FROM Filtrada
    ORDER BY
        CASE EstadoExistencias WHEN 'agotado' THEN 0 WHEN 'bajo' THEN 1 ELSE 2 END,
        Nombre
    OFFSET @Offset ROWS FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* --------------------------------------------------------------------------
   3. Ficha de un producto del inventario
   -------------------------------------------------------------------------- */
CREATE   PROCEDURE dbo.SP_ObtenerInventarioDetalle
(
    @IdProducto INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.IdProducto,
        P.Nombre,
        P.Descripcion,
        P.Estado                        AS EstadoProducto,
        P.Precio,
        P.Imagen,
        P.Tamano,
        P.Material,
        P.Caracteristicas,
        P.IdCategoria,
        C.NombreCategoria,
        T.NombreTipo,
        ISNULL(I.CantidadDisponible, ISNULL(P.Stock, 0)) AS CantidadDisponible,
        ISNULL(I.CantidadMinima, 0)                      AS CantidadMinima,
        I.FechaActualizacion
    FROM dbo.Productos P
    LEFT JOIN dbo.Inventario I    ON I.IdProducto = P.IdProducto
    LEFT JOIN dbo.Categorias C    ON C.IdCategoria = P.IdCategoria
    LEFT JOIN dbo.TiposProducto T ON T.IdTipo = P.IdTipo
    WHERE P.IdProducto = @IdProducto;

    SELECT
        V.IdVariante,
        V.NombreVariante,
        V.Tamano,
        V.Material,
        V.Precio,
        V.Stock,
        V.Estado
    FROM dbo.ProductoVariantes V
    WHERE V.IdProducto = @IdProducto
    ORDER BY V.NombreVariante;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ObtenerMensajesChat
(
    @IdChat INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        M.IdMensaje,
        M.IdChat,
        ISNULL(M.Remitente, 'Bot') AS Remitente,
        ISNULL(M.Mensaje, '') AS Mensaje,
        M.FechaHora
    FROM dbo.MensajesChat M
    WHERE M.IdChat = @IdChat
    ORDER BY M.FechaHora, M.IdMensaje;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Se conserva el contrato anterior y solo se agregan las columnas de respuesta.
CREATE   PROCEDURE dbo.SP_ObtenerMensajesContacto
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ObtenerMisCotizaciones
(
    @IdUsuario INT,
    @Pagina INT = 1,
    @TamanoPagina INT = 10,
    @Estado VARCHAR(30) = NULL,
    @Busqueda VARCHAR(100) = NULL,
    @SoloGestionadas BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Pagina = CASE WHEN @Pagina < 1 THEN 1 ELSE @Pagina END;
    SET @TamanoPagina =
        CASE
            WHEN @TamanoPagina < 1 THEN 10
            WHEN @TamanoPagina > 100 THEN 100
            ELSE @TamanoPagina
        END;
    SET @Estado = NULLIF(LTRIM(RTRIM(@Estado)), '');
    SET @Busqueda = NULLIF(LTRIM(RTRIM(@Busqueda)), '');
    SET @SoloGestionadas = ISNULL(@SoloGestionadas, 0);

    DECLARE @PatronBusqueda VARCHAR(306) = NULL;
    IF @Busqueda IS NOT NULL
    BEGIN
        SET @PatronBusqueda =
            '%' +
            REPLACE(
                REPLACE(
                    REPLACE(@Busqueda, '\', '\\'),
                    '%',
                    '\%'),
                '_',
                '\_') +
            '%';
    END;

    SELECT
        C.IdCotizacion,
        C.FechaCotizacion
    INTO #CotizacionesFiltradas
    FROM dbo.Cotizaciones C
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    WHERE CL.IdUsuario = @IdUsuario
      AND (@Estado IS NULL OR C.Estado = @Estado)
      AND (@SoloGestionadas = 0 OR ISNULL(C.Estado, 'Pendiente') <> 'Pendiente')
      AND
      (
          @PatronBusqueda IS NULL
          OR C.NumeroSeguimiento LIKE @PatronBusqueda ESCAPE '\'
          OR C.Descripcion LIKE @PatronBusqueda ESCAPE '\'
          OR C.Preferencias LIKE @PatronBusqueda ESCAPE '\'
          OR C.Respuesta LIKE @PatronBusqueda ESCAPE '\'
          OR EXISTS
          (
              SELECT 1
              FROM dbo.SolicitudCotizacionProductos S
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = S.IdProducto
              WHERE S.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
          OR EXISTS
          (
              SELECT 1
              FROM dbo.DetalleCotizacion D
              INNER JOIN dbo.Productos P
                  ON P.IdProducto = D.IdProducto
              WHERE D.IdCotizacion = C.IdCotizacion
                AND P.Nombre LIKE @PatronBusqueda ESCAPE '\'
          )
      );

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesFiltradas_Id
        ON #CotizacionesFiltradas (IdCotizacion);

    SELECT F.IdCotizacion
    INTO #CotizacionesPagina
    FROM #CotizacionesFiltradas F
    ORDER BY F.FechaCotizacion DESC, F.IdCotizacion DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;

    CREATE UNIQUE CLUSTERED INDEX IX_CotizacionesPagina_Id
        ON #CotizacionesPagina (IdCotizacion);

    SELECT
        C.IdCotizacion,
        ISNULL(
            C.NumeroSeguimiento,
            CONCAT(
                'COT-',
                RIGHT(
                    REPLICATE('0', 10) +
                    CONVERT(VARCHAR(10), C.IdCotizacion),
                    10))) AS NumeroSeguimiento,
        C.IdCliente,
        CONCAT(CL.Nombre, ' ', CL.Apellido) AS Cliente,
        ISNULL(C.FechaCotizacion, GETDATE()) AS FechaSolicitud,
        ISNULL(C.Estado, 'Pendiente') AS Estado,
        C.Total,
        ISNULL(C.Descripcion, '') AS Descripcion,
        ISNULL(C.Preferencias, '') AS Preferencias,
        ISNULL(C.Respuesta, '') AS Respuesta,
        C.FechaRespuesta,
        P.IdPedido
    FROM #CotizacionesPagina CP
    INNER JOIN dbo.Cotizaciones C
        ON C.IdCotizacion = CP.IdCotizacion
    INNER JOIN dbo.Clientes CL
        ON CL.IdCliente = C.IdCliente
    LEFT JOIN dbo.Pedidos P
        ON P.IdCotizacion = C.IdCotizacion
    ORDER BY C.FechaCotizacion DESC, C.IdCotizacion DESC;

    SELECT
        D.IdCotizacion,
        D.IdProducto,
        P.Nombre,
        P.Imagen,
        D.Cantidad,
        D.PrecioUnitario,
        D.Subtotal
    FROM dbo.DetalleCotizacion D
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = D.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = D.IdProducto
    ORDER BY D.IdDetalleCotizacion;

    SELECT
        S.IdCotizacion,
        S.IdProducto,
        P.Nombre,
        P.Imagen,
        S.Cantidad
    FROM dbo.SolicitudCotizacionProductos S
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = S.IdCotizacion
    INNER JOIN dbo.Productos P
        ON P.IdProducto = S.IdProducto
    ORDER BY S.IdSolicitudCotizacionProducto;

    SELECT
        I.IdCotizacion,
        I.RutaArchivo,
        I.NombreOriginal,
        I.TipoContenido,
        I.TamanoBytes
    FROM dbo.CotizacionImagenes I
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = I.IdCotizacion
    ORDER BY I.IdCotizacionImagen;

    SELECT
        H.IdCotizacion,
        H.EstadoAnterior,
        H.EstadoNuevo,
        H.FechaCambio
    FROM dbo.CotizacionEstadoHistorial H
    INNER JOIN #CotizacionesPagina CP
        ON CP.IdCotizacion = H.IdCotizacion
    ORDER BY
        H.IdCotizacion,
        H.FechaCambio,
        H.IdCotizacionEstadoHistorial;

    SELECT COUNT(*) AS TotalItems
    FROM #CotizacionesFiltradas;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ---------------------------------------------------------------------------
-- 6. Detalle de pedido con tipo de producto y macetero por linea.
-- ---------------------------------------------------------------------------

CREATE   PROCEDURE dbo.SP_ObtenerMisPedidos
(
    @IdUsuario INT,
    @FechaDesde DATE = NULL,
    @FechaHasta DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

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

    SELECT
        P.IdPedido,
        P.FechaPedido,
        ISNULL(P.Estado, 'Pendiente') AS Estado,
        ISNULL(P.DireccionEntrega, '') AS DireccionEntrega,
        ISNULL(V.MetodoPago, '') AS MetodoPago,
        ISNULL(V.EstadoPago, '') AS EstadoPago,
        P.Total,
        DP.IdDetallePedido,
        DP.IdProducto,
        DP.IdVariante,
        COALESCE(PR.Nombre, CONCAT('Producto #', DP.IdProducto)) AS Nombre,
        ISNULL(DP.NombreVariante, '') AS NombreVariante,
        COALESCE(NULLIF(DP.Tamano, ''), PR.Tamano, '') AS Tamano,
        COALESCE(NULLIF(DP.Material, ''), PR.Material, '') AS Material,
        ISNULL(DP.Color, '') AS Color,
        COALESCE(NULLIF(TP.NombreTipo, ''), CA.NombreCategoria, '') AS NombreTipo,
        CASE
            WHEN ISNULL(CC.Clasificacion, '') = 'Macetero'
                THEN COALESCE(PR.Nombre, '')
            ELSE ''
        END AS Macetero,
        ISNULL(PV.Imagen, PR.Imagen) AS Imagen,
        DP.Cantidad,
        DP.PrecioUnitario,
        DP.Subtotal
    FROM Pedidos P
    INNER JOIN Clientes C
        ON C.IdCliente = P.IdCliente
       AND C.IdUsuario = @IdUsuario
    INNER JOIN DetallePedido DP
        ON P.IdPedido = DP.IdPedido
    LEFT JOIN Productos PR
        ON DP.IdProducto = PR.IdProducto
    LEFT JOIN Categorias CA
        ON CA.IdCategoria = PR.IdCategoria
    LEFT JOIN CategoriaClasificacion CC
        ON CC.IdCategoria = PR.IdCategoria
    LEFT JOIN TiposProducto TP
        ON TP.IdTipo = PR.IdTipo
    LEFT JOIN ProductoVariantes PV
        ON PV.IdVariante = DP.IdVariante
       AND PV.IdProducto = DP.IdProducto
    OUTER APPLY
    (
        SELECT TOP (1)
            VE.MetodoPago,
            VE.EstadoPago
        FROM Ventas VE
        WHERE VE.IdPedido = P.IdPedido
        ORDER BY VE.IdVenta DESC
    ) V
    WHERE
        (@FechaDesde IS NULL OR P.FechaPedido >= @FechaDesde)
        AND
        (
            @FechaHasta IS NULL
            OR P.FechaPedido < DATEADD(DAY, 1, @FechaHasta)
        )
    ORDER BY
        P.FechaPedido DESC,
        P.IdPedido DESC,
        DP.IdDetallePedido ASC;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Devuelve la pagina solicitada de notificaciones y, en un segundo
-- conjunto de resultados, los totales de la bandeja del usuario.
CREATE   PROCEDURE dbo.SP_ObtenerNotificacionesUsuario
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Devuelve la conversacion activa del cliente y la crea si aun no existe.
CREATE   PROCEDURE dbo.SP_ObtenerOCrearChatCliente
(
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCliente INT;
    DECLARE @IdChat INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario
              AND Estado = 'Activo'
        )
        BEGIN
            THROW 51001, 'USUARIO_NO_EXISTE', 1;
        END

        SELECT TOP (1)
            @IdCliente = IdCliente
        FROM dbo.Clientes
        WHERE IdUsuario = @IdUsuario
          AND ISNULL(Estado, 'Activo') = 'Activo'
        ORDER BY IdCliente DESC;

        IF @IdCliente IS NULL
        BEGIN
            INSERT INTO dbo.Clientes
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
                '',
                'Activo',
                GETDATE()
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario;

            SET @IdCliente = CONVERT(INT, SCOPE_IDENTITY());
        END

        SELECT TOP (1)
            @IdChat = IdChat
        FROM dbo.Chats
        WHERE IdCliente = @IdCliente
          AND ISNULL(Estado, 'Abierto') <> 'Finalizado'
        ORDER BY IdChat DESC;

        IF @IdChat IS NULL
        BEGIN
            INSERT INTO dbo.Chats (IdCliente, IdUsuario, FechaInicio, Estado)
            VALUES (@IdCliente, NULL, GETDATE(), 'Abierto');

            SET @IdChat = CONVERT(INT, SCOPE_IDENTITY());
        END

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'CHAT_DISPONIBLE' AS Mensaje,
            @IdChat AS IdChat,
            @IdCliente AS IdCliente;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            0 AS Codigo,
            ERROR_MESSAGE() AS Mensaje,
            NULL AS IdChat,
            NULL AS IdCliente;
    END CATCH
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ObtenerPedidoAdminDetalle
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ObtenerPedidosAdmin
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ObtenerPreferenciasUsuario
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Contadores de la bandeja de atencion mostrados en el panel del personal.
CREATE   PROCEDURE dbo.SP_ObtenerResumenChatsAdmin
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Resumen liviano usado por el indicador de notificaciones.
CREATE   PROCEDURE dbo.SP_ObtenerResumenNotificaciones
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_ObtenerRoles]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdRol,
        NombreRol
    FROM Roles
    ORDER BY IdRol;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ======================================================
-- Observacion menor Â· SP_ObtenerUsuarios no devolvia el nombre del rol
-- ======================================================

-- Se conserva el orden y el manejo de errores original; solo se agrega NombreRol.
CREATE   PROCEDURE dbo.SP_ObtenerUsuarios
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ObtenerVisualizacionesUsuario
(
    @IdUsuario INT,
    @IdVisualizacion INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        V.IdVisualizacion,
        V.Nombre,
        V.RutaImagenEspacio,
        V.AnchoLienzo,
        V.AltoLienzo,
        V.FechaCreacion,
        V.FechaActualizacion
    INTO #VisualizacionesUsuario
    FROM dbo.Visualizaciones V
    WHERE V.IdUsuario = @IdUsuario
      AND V.Estado = 'Activo'
      AND (@IdVisualizacion IS NULL OR V.IdVisualizacion = @IdVisualizacion);

    SELECT
        VU.IdVisualizacion,
        VU.Nombre,
        VU.RutaImagenEspacio,
        VU.AnchoLienzo,
        VU.AltoLienzo,
        VU.FechaCreacion,
        VU.FechaActualizacion,
        (
            SELECT COUNT(*)
            FROM dbo.VisualizacionProductos VP
            WHERE VP.IdVisualizacion = VU.IdVisualizacion
        ) AS TotalProductos
    FROM #VisualizacionesUsuario VU
    ORDER BY VU.FechaActualizacion DESC, VU.IdVisualizacion DESC;

    SELECT
        VP.IdVisualizacionProducto,
        VP.IdVisualizacion,
        VP.IdProducto,
        VP.IdVariante,
        COALESCE(PR.Nombre, CONCAT('Producto #', VP.IdProducto)) AS Nombre,
        ISNULL(PV.Imagen, PR.Imagen) AS Imagen,
        COALESCE(PV.Precio, PR.Precio, 0) AS Precio,
        COALESCE(NULLIF(PV.Tamano, ''), PR.Tamano, '') AS Tamano,
        COALESCE(NULLIF(PV.Material, ''), PR.Material, '') AS Material,
        ISNULL(CC.Clasificacion, 'Otro') AS Clasificacion,
        VP.Cantidad,
        VP.Color,
        VP.Macetero,
        VP.PosicionX,
        VP.PosicionY,
        VP.Ancho,
        VP.Alto,
        VP.Rotacion,
        VP.Orden
    FROM dbo.VisualizacionProductos VP
    INNER JOIN #VisualizacionesUsuario VU
        ON VU.IdVisualizacion = VP.IdVisualizacion
    LEFT JOIN dbo.Productos PR
        ON PR.IdProducto = VP.IdProducto
    LEFT JOIN dbo.ProductoVariantes PV
        ON PV.IdVariante = VP.IdVariante
       AND PV.IdProducto = VP.IdProducto
    LEFT JOIN dbo.CategoriaClasificacion CC
        ON CC.IdCategoria = PR.IdCategoria
    ORDER BY VP.IdVisualizacion, VP.Orden, VP.IdVisualizacionProducto;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_PrepararRecompraPedido
(
    @IdUsuario INT,
    @IdPedido INT
)
AS
BEGIN
    SET NOCOUNT ON;

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

    IF NOT EXISTS
    (
        SELECT 1
        FROM Pedidos P
        INNER JOIN Clientes C
            ON C.IdCliente = P.IdCliente
        WHERE P.IdPedido = @IdPedido
          AND C.IdUsuario = @IdUsuario
    )
    BEGIN
        SELECT
            0 AS Exitoso,
            'PEDIDO_NO_ENCONTRADO' AS Mensaje;

        RETURN;
    END

    SELECT
        DP.IdProducto,
        DP.IdVariante,
        COALESCE(P.Nombre, CONCAT('Producto #', DP.IdProducto)) AS Nombre,
        ISNULL(CONVERT(VARCHAR(MAX), P.Descripcion), '') AS Descripcion,
        COALESCE(V.Precio, P.Precio, DP.PrecioUnitario) AS Precio,
        ISNULL(V.Imagen, P.Imagen) AS Imagen,
        COALESCE(NULLIF(DP.NombreVariante, ''), V.NombreVariante, '') AS NombreVariante,
        COALESCE(NULLIF(DP.Tamano, ''), V.Tamano, P.Tamano, '') AS Tamano,
        COALESCE(NULLIF(DP.Material, ''), V.Material, P.Material, '') AS Material,
        ISNULL(DP.Color, '') AS Color,
        DP.Cantidad,
        CAST
        (
            CASE
                WHEN P.IdProducto IS NULL THEN 0
                WHEN ISNULL(P.Estado, 'Activo') <> 'Activo' THEN 0
                WHEN ISNULL(P.Stock, 0) < DP.Cantidad THEN 0
                WHEN DP.IdVariante IS NOT NULL AND V.IdVariante IS NULL THEN 0
                WHEN DP.IdVariante IS NOT NULL AND V.Estado <> 'Activo' THEN 0
                WHEN DP.IdVariante IS NOT NULL AND V.Stock < DP.Cantidad THEN 0
                ELSE 1
            END
            AS BIT
        ) AS Disponible,
        CASE
            WHEN P.IdProducto IS NULL THEN 'El producto ya no existe.'
            WHEN ISNULL(P.Estado, 'Activo') <> 'Activo' THEN 'El producto no esta activo.'
            WHEN ISNULL(P.Stock, 0) < DP.Cantidad THEN 'No hay stock suficiente.'
            WHEN DP.IdVariante IS NOT NULL AND V.IdVariante IS NULL THEN 'La variante ya no existe.'
            WHEN DP.IdVariante IS NOT NULL AND V.Estado <> 'Activo' THEN 'La variante no esta activa.'
            WHEN DP.IdVariante IS NOT NULL AND V.Stock < DP.Cantidad THEN 'No hay stock suficiente para la variante.'
            ELSE ''
        END AS MotivoNoDisponible
    FROM DetallePedido DP
    LEFT JOIN Productos P
        ON P.IdProducto = DP.IdProducto
    LEFT JOIN ProductoVariantes V
        ON V.IdVariante = DP.IdVariante
       AND V.IdProducto = DP.IdProducto
    WHERE DP.IdPedido = @IdPedido
    ORDER BY DP.IdDetallePedido;
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ======================================================
-- B-04 Â· El intento de acceso denegado debe quedar registrado
-- ======================================================

-- Registra en bitacora un acceso rechazado por las guardas de la aplicacion web.
CREATE   PROCEDURE dbo.SP_RegistrarAccesoDenegado
(
    @IdUsuario INT,
    @Ruta VARCHAR(255),
    @IpAddress VARCHAR(50) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.Bitacora (IdUsuario, TablaAfectada, Operacion, Descripcion, FechaHora, IpUsuario)
        VALUES
        (
            @IdUsuario,
            'Seguridad',
            'DENIED',
            CONCAT('Acceso denegado a la ruta protegida ', @Ruta, '.'),
            GETDATE(),
            @IpAddress
        );

        SELECT 1 AS Codigo, 'ACCESO_REGISTRADO' AS Mensaje;
    END TRY
    BEGIN CATCH
        SELECT 0 AS Codigo, ERROR_MESSAGE() AS Mensaje;
    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Alta de cliente: crea la cuenta y su ficha en una sola transaccion, de modo
-- que la direccion queda asociada desde el primer momento.
CREATE   PROCEDURE dbo.SP_RegistrarCliente
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ======================================================
-- 3. Registro del comprobante de pago
-- ======================================================

CREATE   PROCEDURE dbo.SP_RegistrarComprobantePago
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_RegistrarMensajeChat
(
    @IdChat INT,
    @Remitente VARCHAR(100),
    @Mensaje NVARCHAR(1000)
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.Chats WHERE IdChat = @IdChat)
    BEGIN
        SELECT
            0 AS Codigo,
            'CHAT_NO_EXISTE' AS Mensaje,
            NULL AS IdMensaje;

        RETURN;
    END

    INSERT INTO dbo.MensajesChat (IdChat, Remitente, Mensaje, FechaHora)
    VALUES (@IdChat, @Remitente, @Mensaje, GETDATE());

    SELECT
        1 AS Codigo,
        'MENSAJE_REGISTRADO' AS Mensaje,
        CONVERT(INT, SCOPE_IDENTITY()) AS IdMensaje;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_RegistrarMensajeContacto
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ======================================================
-- PROCEDIMIENTOS ALMACENADOS
-- ======================================================

-- Registra una notificacion para un usuario.
CREATE   PROCEDURE dbo.SP_RegistrarNotificacion
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_RegistrarPedido
(
    @IdUsuario INT,
    @DireccionEntrega VARCHAR(255),
    @MetodoPago VARCHAR(50),
    @Carrito dbo.TVP_PedidoItem READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdCliente INT;
    DECLARE @IdPedido INT;
    DECLARE @Total DECIMAL(10,2);
    DECLARE @ProductosEsperados INT;
    DECLARE @VariantesEsperadas INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario
              AND Estado = 'Activo'
        )
        BEGIN
            THROW 50001, 'USUARIO_NO_EXISTE', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @Carrito)
        BEGIN
            THROW 50002, 'CARRITO_VACIO', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @Carrito
            WHERE IdProducto <= 0
               OR Cantidad <= 0
        )
        BEGIN
            THROW 50003, 'ITEM_INVALIDO', 1;
        END;

        SELECT
            C.IdProducto,
            C.IdVariante,
            SUM(C.Cantidad) AS Cantidad,
            MAX(NULLIF(C.NombreVariante, '')) AS NombreVariante,
            MAX(NULLIF(C.Tamano, '')) AS Tamano,
            MAX(NULLIF(C.Material, '')) AS Material,
            MAX(NULLIF(C.Color, '')) AS Color
        INTO #ItemsPedido
        FROM @Carrito C
        GROUP BY
            C.IdProducto,
            C.IdVariante;

        SELECT
            I.IdProducto,
            SUM(I.Cantidad) AS Cantidad
        INTO #ProductosRequeridos
        FROM #ItemsPedido I
        GROUP BY I.IdProducto;

        SELECT
            I.IdProducto,
            I.IdVariante,
            SUM(I.Cantidad) AS Cantidad
        INTO #VariantesRequeridas
        FROM #ItemsPedido I
        WHERE I.IdVariante IS NOT NULL
        GROUP BY
            I.IdProducto,
            I.IdVariante;

        SELECT
            @ProductosEsperados = COUNT(*)
        FROM #ProductosRequeridos;

        SELECT
            @VariantesEsperadas = COUNT(*)
        FROM #VariantesRequeridas;

        SELECT TOP (1)
            @IdCliente = IdCliente
        FROM dbo.Clientes
        WHERE IdUsuario = @IdUsuario
          AND ISNULL(Estado, 'Activo') = 'Activo'
        ORDER BY IdCliente DESC;

        IF @IdCliente IS NULL
        BEGIN
            INSERT dbo.Clientes
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
            FROM dbo.Usuarios
            WHERE IdUsuario = @IdUsuario;

            SET @IdCliente = CONVERT(INT, SCOPE_IDENTITY());
        END;

        SELECT
            @Total = SUM(COALESCE(V.Precio, P.Precio) * I.Cantidad)
        FROM #ItemsPedido I
        INNER JOIN dbo.Productos P
            ON P.IdProducto = I.IdProducto
        LEFT JOIN dbo.ProductoVariantes V
            ON V.IdVariante = I.IdVariante
           AND V.IdProducto = I.IdProducto
           AND V.Estado = 'Activo'
        WHERE P.Estado = 'Activo';

        IF @Total IS NULL
        BEGIN
            THROW 50004, 'STOCK_INSUFICIENTE', 1;
        END;

        UPDATE P WITH (UPDLOCK, HOLDLOCK)
        SET P.Stock = P.Stock - R.Cantidad
        FROM dbo.Productos P
        INNER JOIN #ProductosRequeridos R
            ON R.IdProducto = P.IdProducto
        WHERE P.Estado = 'Activo'
          AND ISNULL(P.Stock, 0) >= R.Cantidad;

        IF @@ROWCOUNT <> @ProductosEsperados
        BEGIN
            THROW 50004, 'STOCK_INSUFICIENTE', 1;
        END;

        UPDATE V WITH (UPDLOCK, HOLDLOCK)
        SET V.Stock = V.Stock - R.Cantidad
        FROM dbo.ProductoVariantes V
        INNER JOIN #VariantesRequeridas R
            ON R.IdVariante = V.IdVariante
           AND R.IdProducto = V.IdProducto
        WHERE V.Estado = 'Activo'
          AND V.Stock >= R.Cantidad;

        IF @@ROWCOUNT <> @VariantesEsperadas
        BEGIN
            THROW 50004, 'STOCK_INSUFICIENTE', 1;
        END;

        INSERT dbo.Pedidos
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

        INSERT dbo.DetallePedido
        (
            IdPedido,
            IdProducto,
            IdVariante,
            NombreVariante,
            Tamano,
            Material,
            Color,
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT
            @IdPedido,
            I.IdProducto,
            I.IdVariante,
            COALESCE(V.NombreVariante, I.NombreVariante),
            COALESCE(V.Tamano, I.Tamano, P.Tamano),
            COALESCE(V.Material, I.Material, P.Material),
            I.Color,
            I.Cantidad,
            COALESCE(V.Precio, P.Precio),
            COALESCE(V.Precio, P.Precio) * I.Cantidad
        FROM #ItemsPedido I
        INNER JOIN dbo.Productos P
            ON P.IdProducto = I.IdProducto
        LEFT JOIN dbo.ProductoVariantes V
            ON V.IdVariante = I.IdVariante
           AND V.IdProducto = I.IdProducto;

        INSERT dbo.Ventas
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

        INSERT dbo.Bitacora
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
            CONCAT(
                'Pedido #',
                @IdPedido,
                ' creado. Cliente: ',
                @IdCliente,
                '. Metodo de pago: ',
                @MetodoPago,
                '.'),
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
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ReporteComparativoPeriodos
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ReporteProductosMasVendidos
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE SP_ReporteVentasPorPeriodo
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ResolverCotizacionVendedor
(
    @IdCotizacion INT,
    @Aprobar BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado VARCHAR(30);
        DECLARE @NuevoEstado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);

        SELECT
            @Estado = C.Estado,
            @Total = C.Total
        FROM dbo.Cotizaciones C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.IdCotizacion = @IdCotizacion;

        IF @Estado IS NULL
        BEGIN
            THROW 50021, 'COTIZACION_NO_EXISTE', 1;
        END;

        IF @Estado <> 'Aceptada'
        BEGIN
            THROW 50022, 'COTIZACION_REQUIERE_ACEPTACION', 1;
        END;

        IF @Aprobar = 1
           AND NOT EXISTS
           (
               SELECT 1
               FROM dbo.DetalleCotizacion
               WHERE IdCotizacion = @IdCotizacion
           )
        BEGIN
            THROW 50023, 'COTIZACION_SIN_PRODUCTOS', 1;
        END;

        SET @NuevoEstado =
            CASE WHEN @Aprobar = 1 THEN 'Aprobada' ELSE 'Rechazada' END;

        UPDATE dbo.Cotizaciones
        SET Estado = @NuevoEstado
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            CASE
                WHEN @Aprobar = 1
                    THEN 'Cotizacion aprobada por ventas.'
                ELSE 'Cotizacion rechazada por ventas.'
            END AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            @NuevoEstado AS Estado,
            @Total AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            '' AS Estado,
            CAST(0 AS DECIMAL(18,2)) AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ResponderCotizacion
(
    @IdCotizacion INT,
    @Respuesta VARCHAR(1000),
    @Productos dbo.TVP_CotizacionProducto READONLY
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado VARCHAR(30);
        DECLARE @Total DECIMAL(18,2);

        SELECT @Estado = C.Estado
        FROM dbo.Cotizaciones C WITH (UPDLOCK, HOLDLOCK)
        WHERE C.IdCotizacion = @IdCotizacion;

        IF @Estado IS NULL
        BEGIN
            THROW 50001, 'COTIZACION_NO_EXISTE', 1;
        END;

        IF @Estado NOT IN ('Pendiente', 'Respondida')
        BEGIN
            THROW 50002, 'COTIZACION_ESTADO_INVALIDO', 1;
        END;

        IF NULLIF(LTRIM(RTRIM(@Respuesta)), '') IS NULL
        BEGIN
            THROW 50003, 'RESPUESTA_REQUERIDA', 1;
        END;

        IF NOT EXISTS (SELECT 1 FROM @Productos)
        BEGIN
            THROW 50004, 'PRODUCTOS_REQUERIDOS', 1;
        END;

        IF EXISTS
        (
            SELECT 1
            FROM @Productos Q
            LEFT JOIN dbo.Productos P
                ON P.IdProducto = Q.IdProducto
               AND P.Estado = 'Activo'
            WHERE P.IdProducto IS NULL
               OR Q.Cantidad <= 0
               OR Q.PrecioUnitario <= 0
        )
        BEGIN
            THROW 50005, 'PRODUCTO_NO_DISPONIBLE', 1;
        END;

        SELECT
            @Total = SUM(
                CONVERT(DECIMAL(18,2), Q.Cantidad * Q.PrecioUnitario))
        FROM @Productos Q;

        DELETE FROM dbo.DetalleCotizacion
        WHERE IdCotizacion = @IdCotizacion;

        INSERT dbo.DetalleCotizacion
        (
            IdCotizacion,
            IdProducto,
            Cantidad,
            PrecioUnitario,
            Subtotal
        )
        SELECT
            @IdCotizacion,
            Q.IdProducto,
            Q.Cantidad,
            Q.PrecioUnitario,
            CONVERT(DECIMAL(18,2), Q.Cantidad * Q.PrecioUnitario)
        FROM @Productos Q;

        UPDATE dbo.Cotizaciones
        SET
            Respuesta = LTRIM(RTRIM(@Respuesta)),
            FechaRespuesta = GETDATE(),
            Estado = 'Respondida',
            Total = @Total
        WHERE IdCotizacion = @IdCotizacion;

        COMMIT TRANSACTION;

        SELECT
            1 AS Exitoso,
            'Cotizacion respondida correctamente.' AS Mensaje,
            @IdCotizacion AS IdCotizacion,
            'Respondida' AS Estado,
            @Total AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SELECT
            0 AS Exitoso,
            ERROR_MESSAGE() AS Mensaje,
            CAST(NULL AS INT) AS IdCotizacion,
            '' AS Estado,
            CAST(0 AS DECIMAL(18,2)) AS Total,
            CAST(NULL AS INT) AS IdPedido;
    END CATCH;
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- Registra la respuesta del personal y marca la consulta como atendida.
CREATE   PROCEDURE dbo.SP_ResponderMensajeContacto
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_RestablecerContrasena]
(
    @IdUsuario INT,
    @NuevaContrasena VARCHAR(255)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM Usuarios
            WHERE IdUsuario = @IdUsuario
        )
        BEGIN

            SELECT
                0 AS Codigo,
                'El usuario no existe.' AS Mensaje;

            ROLLBACK TRANSACTION;
            RETURN;

        END

        DECLARE @ContrasenaHash VARCHAR(64);

        SET @ContrasenaHash =
            CONVERT(VARCHAR(64),
                    HASHBYTES('SHA2_256', @NuevaContrasena),
                    2);

        UPDATE Usuarios
        SET
            ContrasenaHash = @ContrasenaHash,
            Estado = 'Activo'
        WHERE IdUsuario = @IdUsuario;

        -- Reiniciar intentos fallidos
        DELETE FROM IntentosLogin
        WHERE IdUsuario = @IdUsuario;

        COMMIT TRANSACTION;

        SELECT
            1 AS Codigo,
            'Contraseña actualizada correctamente. La cuenta ha sido reactivada.' AS Mensaje;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[SP_ValidarCorreoRecuperacion]
(
    @Correo VARCHAR(150)
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF EXISTS
        (
            SELECT 1
            FROM Usuarios
            WHERE Correo = @Correo
        )
        BEGIN

            SELECT
                1 AS Codigo,
                'Correo encontrado.' AS Mensaje,
                IdUsuario
            FROM Usuarios
            WHERE Correo = @Correo;

        END
        ELSE
        BEGIN

            SELECT
                0 AS Codigo,
                'No existe una cuenta asociada a ese correo.' AS Mensaje;

        END

    END TRY
    BEGIN CATCH

        SELECT
            -1 AS Codigo,
            ERROR_MESSAGE() AS Mensaje;

    END CATCH
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE dbo.SP_ValidarStockCarrito
(
    @Carrito dbo.TVP_PedidoItem READONLY
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.IdProducto,
        C.IdVariante,
        SUM(C.Cantidad) AS Cantidad
    INTO #ItemsCarrito
    FROM @Carrito C
    GROUP BY
        C.IdProducto,
        C.IdVariante;

    SELECT
        C.IdProducto,
        SUM(C.Cantidad) AS Cantidad
    INTO #ProductosCarrito
    FROM #ItemsCarrito C
    GROUP BY C.IdProducto;

    SELECT
        C.IdProducto,
        C.IdVariante,
        CASE
            WHEN C.IdVariante IS NULL THEN P.Nombre
            ELSE CONCAT(P.Nombre, ' - ', V.NombreVariante)
        END AS Nombre,
        C.Cantidad AS CantidadSolicitada,
        CASE
            WHEN C.IdVariante IS NULL THEN ISNULL(P.Stock, 0)
            WHEN ISNULL(P.Stock, 0) < ISNULL(V.Stock, 0)
                THEN ISNULL(P.Stock, 0)
            ELSE ISNULL(V.Stock, 0)
        END AS StockDisponible,
        CONVERT
        (
            DECIMAL(10,2),
            CASE
                WHEN C.IdVariante IS NULL THEN ISNULL(P.Precio, 0)
                ELSE COALESCE(V.Precio, P.Precio, 0)
            END
        ) AS PrecioUnitario,
        CONVERT
        (
            DECIMAL(28,2),
            C.Cantidad *
            CASE
                WHEN C.IdVariante IS NULL THEN ISNULL(P.Precio, 0)
                ELSE COALESCE(V.Precio, P.Precio, 0)
            END
        ) AS Subtotal,
        CASE
            WHEN P.IdProducto IS NULL THEN 'PRODUCTO_NO_EXISTE'
            WHEN C.Cantidad <= 0 THEN 'CANTIDAD_INVALIDA'
            WHEN ISNULL(P.Estado, 'Activo') <> 'Activo'
                THEN 'PRODUCTO_NO_DISPONIBLE'
            WHEN C.IdVariante IS NOT NULL AND V.IdVariante IS NULL
                THEN 'VARIANTE_NO_EXISTE'
            WHEN C.IdVariante IS NOT NULL AND V.Estado <> 'Activo'
                THEN 'VARIANTE_NO_DISPONIBLE'
            WHEN ISNULL(P.Stock, 0) <= 0 THEN 'SIN_STOCK'
            WHEN ISNULL(P.Stock, 0) < T.Cantidad THEN 'STOCK_INSUFICIENTE'
            WHEN C.IdVariante IS NOT NULL AND ISNULL(V.Stock, 0) <= 0
                THEN 'SIN_STOCK'
            WHEN C.IdVariante IS NOT NULL AND ISNULL(V.Stock, 0) < C.Cantidad
                THEN 'STOCK_INSUFICIENTE'
            ELSE 'DISPONIBLE'
        END AS Estado
    FROM #ItemsCarrito C
    INNER JOIN #ProductosCarrito T
        ON T.IdProducto = C.IdProducto
    LEFT JOIN dbo.Productos P
        ON P.IdProducto = C.IdProducto
    LEFT JOIN dbo.ProductoVariantes V
        ON V.IdVariante = C.IdVariante
       AND V.IdProducto = C.IdProducto;
END;
GO

-- ============================================================================
-- Triggers
-- ============================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   TRIGGER [dbo].[TR_Cotizaciones_RegistrarCambioEstado]
ON [dbo].[Cotizaciones]
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

ALTER TABLE [dbo].[Cotizaciones] ENABLE TRIGGER [TR_Cotizaciones_RegistrarCambioEstado]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   TRIGGER [dbo].[TR_Productos_SincronizarInventarioStock]
ON [dbo].[Productos]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(Stock)
    BEGIN
        RETURN;
    END;

    UPDATE I
    SET
        I.CantidadDisponible = ISNULL(N.Stock, 0),
        I.FechaActualizacion = GETDATE()
    FROM dbo.Inventario I
    INNER JOIN inserted N
        ON N.IdProducto = I.IdProducto
    WHERE I.CantidadDisponible <> ISNULL(N.Stock, 0);
END;
GO

ALTER TABLE [dbo].[Productos] ENABLE TRIGGER [TR_Productos_SincronizarInventarioStock]
GO

-- ============================================================================
-- Finalizacion
-- ============================================================================

PRINT N'Base de datos ConcreInnovaDB creada correctamente.';
GO

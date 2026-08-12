-- Asistente virtual (bot) del chat, persistencia de conversaciones y escalamiento a soporte humano.
-- Fecha: 2026-08-12
-- Base de datos: ConcreInnovaDB
--
-- Contenido:
--   1. Ajustes necesarios sobre Chats y MensajesChat.
--   2. Intenciones del bot y sus palabras clave.
--   3. Procedimientos de conversacion, bot, escalamiento y cierre.
--   4. Carga inicial de intenciones (mismas respuestas que ya usaba el bot).
--
-- Notas sobre cambios a tablas existentes (ambas estaban vacias):
--   * Chats.IdUsuario pasa a ser NULL: una conversacion atendida por el bot
--     todavia no tiene una persona de soporte asignada. El usuario se asigna
--     cuando la conversacion se escala.
--   * MensajesChat.Mensaje pasa a NVARCHAR: las respuestas del bot incluyen
--     emojis, que VARCHAR no puede almacenar sin perder informacion.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ---------------------------------------------------------------------------
-- 1. Ajustes sobre las tablas de chat existentes.
-- ---------------------------------------------------------------------------

IF EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.Chats')
      AND name = 'IdUsuario'
      AND is_nullable = 0
)
BEGIN
    ALTER TABLE dbo.Chats ALTER COLUMN IdUsuario INT NULL;
END;
GO

IF COL_LENGTH('dbo.Chats', 'FechaCierre') IS NULL
BEGIN
    ALTER TABLE dbo.Chats ADD FechaCierre DATETIME NULL;
END;
GO

IF EXISTS
(
    SELECT 1
    FROM sys.columns C
    INNER JOIN sys.types T
        ON T.user_type_id = C.user_type_id
    WHERE C.object_id = OBJECT_ID('dbo.MensajesChat')
      AND C.name = 'Mensaje'
      AND T.name = 'varchar'
)
BEGIN
    ALTER TABLE dbo.MensajesChat ALTER COLUMN Mensaje NVARCHAR(1000) NULL;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Chats')
      AND name = 'IX_Chats_EstadoFechaInicio'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Chats_EstadoFechaInicio
        ON dbo.Chats (Estado, FechaInicio DESC, IdChat DESC)
        INCLUDE (IdCliente, IdUsuario);
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.MensajesChat')
      AND name = 'IX_MensajesChat_ChatFecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_MensajesChat_ChatFecha
        ON dbo.MensajesChat (IdChat, FechaHora, IdMensaje)
        INCLUDE (Remitente, Mensaje);
END;
GO

-- ---------------------------------------------------------------------------
-- 2. Intenciones del bot.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.BotIntenciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BotIntenciones
    (
        IdIntencion INT IDENTITY(1,1) NOT NULL,
        Codigo VARCHAR(40) NOT NULL,
        Respuesta NVARCHAR(600) NOT NULL,
        SugiereProductos BIT NOT NULL
            CONSTRAINT DF_BotIntenciones_SugiereProductos DEFAULT (0),
        SugiereEscalamiento BIT NOT NULL
            CONSTRAINT DF_BotIntenciones_SugiereEscalamiento DEFAULT (0),
        Orden INT NOT NULL CONSTRAINT DF_BotIntenciones_Orden DEFAULT (1),
        Estado VARCHAR(20) NOT NULL CONSTRAINT DF_BotIntenciones_Estado DEFAULT ('Activo'),
        CONSTRAINT PK_BotIntenciones PRIMARY KEY CLUSTERED (IdIntencion),
        CONSTRAINT UQ_BotIntenciones_Codigo UNIQUE (Codigo)
    );
END;
GO

IF OBJECT_ID('dbo.BotIntencionPalabras', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BotIntencionPalabras
    (
        IdPalabra INT IDENTITY(1,1) NOT NULL,
        IdIntencion INT NOT NULL,
        PalabraClave NVARCHAR(80) NOT NULL,
        CONSTRAINT PK_BotIntencionPalabras PRIMARY KEY CLUSTERED (IdPalabra),
        CONSTRAINT UQ_BotIntencionPalabras_IntencionPalabra
            UNIQUE (IdIntencion, PalabraClave),
        CONSTRAINT FK_BotIntencionPalabras_BotIntenciones
            FOREIGN KEY (IdIntencion)
            REFERENCES dbo.BotIntenciones (IdIntencion)
            ON DELETE CASCADE
    );
END;
GO

-- ---------------------------------------------------------------------------
-- 3. Procedimientos.
-- ---------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerIntencionesBot
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

-- Devuelve la conversacion activa del cliente y la crea si aun no existe.
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerOCrearChatCliente
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

CREATE OR ALTER PROCEDURE dbo.SP_RegistrarMensajeChat
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

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerConversacionCliente
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

-- Escala la conversacion a soporte humano y notifica al personal disponible.
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
            INSERT INTO dbo.Notificaciones (IdUsuario, Mensaje, Leida, FechaEnvio)
            VALUES (@IdUsuarioSoporte, @MensajeNotificacion, 0, GETDATE());
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

CREATE OR ALTER PROCEDURE dbo.SP_FinalizarChat
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
        ISNULL(U.TotalMensajes, 0) AS TotalMensajes
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
    WHERE (@Estado IS NULL OR ISNULL(CH.Estado, 'Abierto') = @Estado)
    ORDER BY
        CASE WHEN ISNULL(CH.Estado, 'Abierto') = 'Escalado' THEN 0 ELSE 1 END,
        ISNULL(U.FechaUltimoMensaje, CH.FechaInicio) DESC,
        CH.IdChat DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerMensajesChat
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

-- ---------------------------------------------------------------------------
-- 4. Carga inicial de intenciones del bot.
-- ---------------------------------------------------------------------------

MERGE dbo.BotIntenciones AS destino
USING
(
    VALUES
        ('saludo',
         N'¡Hola! 👋 Soy el asistente virtual de ConcreInnova. Puedo ayudarte con información sobre productos, pedidos, pagos, cotizaciones, envíos y contacto.',
         0, 0, 1),
        ('pagos',
         N'💳 En ConcreInnova puedes realizar tus pagos mediante tarjeta de crédito o débito y SINPE Móvil. El método disponible se mostrará durante el proceso de compra.',
         0, 0, 2),
        ('contacto',
         N'📞 Puedes contactar a ConcreInnova mediante nuestro teléfono 8888-1111 o por correo electrónico a contacto@concreinnova.com.',
         0, 0, 3),
        ('horarios',
         N'🕐 Nuestro horario de atención es de lunes a viernes de 8:00 a.m. a 5:00 p.m.',
         0, 0, 4),
        ('ubicacion',
         N'📍 ConcreInnova ofrece sus servicios en Costa Rica. Para obtener información específica sobre nuestra ubicación, puedes comunicarte con nuestro equipo de atención.',
         0, 0, 5),
        ('productos',
         N'🏗️ En ConcreInnova puedes encontrar productos decorativos y soluciones elaboradas en concreto. Puedes consultar nuestro catálogo para conocer los productos disponibles, sus características y precios.',
         1, 0, 6),
        ('precios',
         N'💰 Los precios dependen del producto, sus características y opciones de personalización. Puedes consultar el precio directamente desde el detalle de cada producto.',
         1, 0, 7),
        ('compra',
         N'🛒 Para realizar una compra, selecciona el producto que deseas, agrega la cantidad al carrito y luego continúa al proceso de checkout para completar tu pedido.',
         1, 0, 8),
        ('carrito',
         N'🛒 Puedes agregar productos al carrito desde su página de detalle. Después puedes revisar las cantidades y continuar al proceso de compra.',
         1, 0, 9),
        ('pedidos',
         N'📦 Puedes consultar tus pedidos desde la sección ''Mis pedidos''. Allí podrás revisar la información y los detalles de las compras realizadas.',
         0, 0, 10),
        ('seguimiento',
         N'📦 Para consultar el estado de tu pedido, ingresa a la sección ''Mis pedidos'' de tu cuenta. Si necesitas ayuda adicional, puedes contactar a nuestro equipo de soporte.',
         0, 1, 11),
        ('envios',
         N'🚚 Los tiempos de entrega pueden variar dependiendo del producto, cantidad y ubicación. Para obtener información específica sobre tu pedido, consulta sus detalles o contacta con soporte.',
         0, 0, 12),
        ('cotizaciones',
         N'📋 ConcreInnova permite solicitar cotizaciones para productos o necesidades específicas. Puedes utilizar el módulo de cotizaciones para enviar tu solicitud y recibir una respuesta.',
         1, 0, 13),
        ('personalizacion',
         N'🎨 Algunos productos pueden contar con opciones de personalización. Puedes revisar las características disponibles en el detalle del producto o solicitar una cotización para necesidades específicas.',
         1, 0, 14),
        ('stock',
         N'📦 La disponibilidad de cada producto se muestra en su página de detalle. Si un producto no está disponible, puedes contactar con nosotros para consultar cuándo volverá a estar disponible.',
         1, 0, 15),
        ('cancelaciones',
         N'❌ Para solicitar la cancelación de un pedido, te recomendamos contactar con nuestro equipo de soporte indicando el número de pedido y el motivo de la solicitud.',
         0, 1, 16),
        ('devoluciones',
         N'↩️ Para consultas sobre devoluciones o reembolsos, contacta con nuestro equipo de soporte indicando los detalles de tu pedido para revisar tu caso.',
         0, 1, 17),
        ('soporte',
         N'🛠️ Claro, puedo ayudarte. Puedes preguntarme sobre productos, pedidos, pagos, cotizaciones, envíos o información de contacto. Si tu problema requiere atención personalizada, puedes comunicarte con nuestro equipo de soporte.',
         0, 1, 18),
        ('agradecimiento',
         N'¡Con mucho gusto! 😊 Estamos para ayudarte. ¿Necesitas información sobre algún producto, pedido o servicio?',
         0, 0, 19),
        ('despedida',
         N'¡Hasta luego! 👋 Gracias por visitar ConcreInnova. Esperamos ayudarte nuevamente.',
         0, 0, 20)
) AS origen (Codigo, Respuesta, SugiereProductos, SugiereEscalamiento, Orden)
    ON origen.Codigo = destino.Codigo
WHEN MATCHED THEN
    UPDATE SET
        destino.Respuesta = origen.Respuesta,
        destino.SugiereProductos = origen.SugiereProductos,
        destino.SugiereEscalamiento = origen.SugiereEscalamiento,
        destino.Orden = origen.Orden,
        destino.Estado = 'Activo'
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Respuesta, SugiereProductos, SugiereEscalamiento, Orden, Estado)
    VALUES
    (
        origen.Codigo,
        origen.Respuesta,
        origen.SugiereProductos,
        origen.SugiereEscalamiento,
        origen.Orden,
        'Activo'
    );
GO

MERGE dbo.BotIntencionPalabras AS destino
USING
(
    SELECT
        I.IdIntencion,
        K.PalabraClave
    FROM
    (
        VALUES
            ('saludo', N'hola'), ('saludo', N'buenas'), ('saludo', N'buenos dias'),
            ('saludo', N'buenas tardes'), ('saludo', N'buenas noches'), ('saludo', N'hey'),
            ('pagos', N'pago'), ('pagos', N'pagos'), ('pagos', N'metodo de pago'),
            ('pagos', N'metodos de pago'), ('pagos', N'formas de pago'),
            ('pagos', N'como pagar'), ('pagos', N'tarjeta'), ('pagos', N'sinpe'),
            ('contacto', N'contacto'), ('contacto', N'contactar'), ('contacto', N'telefono'),
            ('contacto', N'correo'), ('contacto', N'email'), ('contacto', N'correo electronico'),
            ('horarios', N'horario'), ('horarios', N'horarios'), ('horarios', N'abierto'),
            ('horarios', N'atencion'), ('horarios', N'cuando atienden'),
            ('ubicacion', N'ubicacion'), ('ubicacion', N'direccion'),
            ('ubicacion', N'donde estan'), ('ubicacion', N'lugar'),
            ('productos', N'producto'), ('productos', N'productos'), ('productos', N'catalogo'),
            ('productos', N'que venden'), ('productos', N'maceta'), ('productos', N'macetas'),
            ('productos', N'macetero'), ('productos', N'maceteros'), ('productos', N'planta'),
            ('productos', N'plantas'), ('productos', N'recomienda'),
            ('productos', N'recomendacion'), ('productos', N'sugerencia'),
            ('productos', N'sugerencias'), ('productos', N'opciones'),
            ('productos', N'muestrame'),
            ('precios', N'precio'), ('precios', N'precios'), ('precios', N'cuanto cuesta'),
            ('precios', N'valor'), ('precios', N'costo'), ('precios', N'costos'),
            ('compra', N'comprar'), ('compra', N'compra'), ('compra', N'como comprar'),
            ('compra', N'hacer compra'),
            ('carrito', N'carrito'), ('carrito', N'carrito de compras'),
            ('carrito', N'agregar al carrito'),
            ('pedidos', N'pedido'), ('pedidos', N'pedidos'), ('pedidos', N'orden'),
            ('pedidos', N'ordenes'), ('pedidos', N'mi pedido'), ('pedidos', N'mis pedidos'),
            ('seguimiento', N'estado del pedido'), ('seguimiento', N'estado pedido'),
            ('seguimiento', N'seguimiento'), ('seguimiento', N'seguimiento pedido'),
            ('seguimiento', N'donde esta mi pedido'),
            ('envios', N'envio'), ('envios', N'envios'), ('envios', N'entrega'),
            ('envios', N'entregas'), ('envios', N'tiempo de entrega'),
            ('cotizaciones', N'cotizacion'), ('cotizaciones', N'cotizaciones'),
            ('cotizaciones', N'presupuesto'), ('cotizaciones', N'presupuestos'),
            ('personalizacion', N'personalizar'), ('personalizacion', N'personalizacion'),
            ('personalizacion', N'personalizado'), ('personalizacion', N'personalizados'),
            ('personalizacion', N'medidas'), ('personalizacion', N'tamano'),
            ('stock', N'stock'), ('stock', N'disponibilidad'), ('stock', N'disponible'),
            ('stock', N'existencias'), ('stock', N'hay disponible'),
            ('cancelaciones', N'cancelar'), ('cancelaciones', N'cancelacion'),
            ('cancelaciones', N'cancelar pedido'),
            ('devoluciones', N'devolucion'), ('devoluciones', N'devolver'),
            ('devoluciones', N'reembolso'), ('devoluciones', N'reembolsar'),
            ('soporte', N'soporte'), ('soporte', N'ayuda'), ('soporte', N'ayudame'),
            ('soporte', N'problema'), ('soporte', N'problemas'), ('soporte', N'agente'),
            ('soporte', N'asesor humano'), ('soporte', N'hablar con alguien'),
            ('agradecimiento', N'gracias'), ('agradecimiento', N'muchas gracias'),
            ('agradecimiento', N'thank you'),
            ('despedida', N'adios'), ('despedida', N'chao'), ('despedida', N'hasta luego')
    ) AS K (CodigoIntencion, PalabraClave)
    INNER JOIN dbo.BotIntenciones I
        ON I.Codigo = K.CodigoIntencion
) AS origen
    ON origen.IdIntencion = destino.IdIntencion
   AND origen.PalabraClave = destino.PalabraClave
WHEN NOT MATCHED BY TARGET THEN
    INSERT (IdIntencion, PalabraClave)
    VALUES (origen.IdIntencion, origen.PalabraClave);
GO

PRINT 'Asistente virtual, conversaciones de chat y escalamiento a soporte instalados.';
GO

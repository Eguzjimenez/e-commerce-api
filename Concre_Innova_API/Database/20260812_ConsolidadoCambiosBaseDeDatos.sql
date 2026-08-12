-- =====================================================================
-- CONCRE INNOVA - CAMBIOS DE BASE DE DATOS CONSOLIDADOS
-- Fecha: 2026-08-12
-- Base de datos destino: ConcreInnovaDB
-- =====================================================================
--
-- Este archivo reune, en orden de dependencia, todos los cambios de base
-- de datos del sprint. Sirve para que cualquier integrante replique el
-- estado completo en su base local con una sola ejecucion.
--
-- COMO EJECUTARLO
--
--   Opcion A (SSMS / Azure Data Studio):
--     Abrir el archivo, seleccionar la base ConcreInnovaDB y ejecutar.
--
--   Opcion B (sqlcmd). El parametro -f 65001 es OBLIGATORIO: las respuestas
--   del asistente virtual contienen emojis y sin ese parametro se guardan
--   como signos de interrogacion.
--
--     sqlcmd -S "(localdb)\MSSQLLocalDB" -d ConcreInnovaDB -E -b -f 65001
--            -i 20260812_ConsolidadoCambiosBaseDeDatos.sql
--
-- CARACTERISTICAS
--
--   * Es idempotente: puede ejecutarse varias veces sin duplicar objetos ni
--     datos. Las tablas se crean solo si no existen, los procedimientos usan
--     CREATE OR ALTER y las cargas de datos usan MERGE / NOT EXISTS.
--   * No incluye USE: seleccione la base antes de ejecutar o pase -d.
--   * Requiere el esquema inicial (ScriptDB-Concre_Innova.sql) ya aplicado,
--     junto con los scripts previos de Database/Scripts.
--   * Al final imprime una tabla de verificacion con lo que debe existir.
--
-- CONTENIDO
--
--   1. Asesor Inteligente, clasificacion de categorias y detalle de pedido
--   2. Historial de cotizaciones ya gestionadas (filtro @SoloGestionadas)
--   3. Asistente virtual, conversaciones persistidas y escalamiento a soporte
--   4. Visualizacion del espacio del usuario (imagen y proyectos guardados)
--
-- OBJETOS NUEVOS
--
--   Tablas:  CategoriaClasificacion, AsesorPreguntas, AsesorOpciones,
--            AsesorCriterios, AsesorRespuestas, BotIntenciones,
--            BotIntencionPalabras, Visualizaciones, VisualizacionProductos
--   Tipos:   TVP_AsesorOpcion, TVP_VisualizacionProducto
--
-- TABLAS EXISTENTES MODIFICADAS (las tres estaban vacias)
--
--   Chats.IdUsuario        pasa a aceptar NULL: una conversacion atendida
--                          por el bot aun no tiene agente asignado.
--   Chats.FechaCierre      columna nueva para el cierre de la conversacion.
--   MensajesChat.Mensaje   pasa de VARCHAR a NVARCHAR porque las respuestas
--                          del bot contienen emojis.
--
-- PROCEDIMIENTOS MODIFICADOS (compatibles hacia atras)
--
--   SP_ObtenerMisPedidos          agrega NombreTipo y Macetero por linea.
--   SP_ObtenerMisCotizaciones     agrega @SoloGestionadas, por defecto 0.
--   SP_ObtenerCotizacionesAdmin   agrega @SoloGestionadas, por defecto 0.
--
-- =====================================================================

-- =====================================================================
-- PARTE 1 DE 4: ASESOR INTELIGENTE, CLASIFICACION DE CATEGORIAS Y DETALLE DE PEDIDO
-- Origen: Concre_Innova_API/Database/Scripts/20260812_AsesorInteligenteYDetalleDePedido.sql
-- =====================================================================

-- Asesor Inteligente (cuestionario y recomendaciones) y detalle enriquecido de pedido.
-- Fecha: 2026-08-12
-- Base de datos: ConcreInnovaDB
--
-- Contenido:
--   1. Clasificacion de categorias (Planta / Macetero) reutilizable por catalogo y asesor.
--   2. Cuestionario del asesor: preguntas, opciones y criterios de recomendacion.
--   3. Respuestas del asesor guardadas por usuario autenticado.
--   4. Procedimientos del asesor: cuestionario, recomendaciones, guardado y reinicio.
--   5. SP_ObtenerMisPedidos ampliado con tipo de producto y macetero por linea.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ---------------------------------------------------------------------------
-- 1. Clasificacion comercial de las categorias del catalogo.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.CategoriaClasificacion', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CategoriaClasificacion
    (
        IdCategoria INT NOT NULL,
        Clasificacion VARCHAR(20) NOT NULL,
        CONSTRAINT PK_CategoriaClasificacion PRIMARY KEY CLUSTERED (IdCategoria),
        CONSTRAINT FK_CategoriaClasificacion_Categorias
            FOREIGN KEY (IdCategoria)
            REFERENCES dbo.Categorias (IdCategoria)
            ON DELETE CASCADE,
        CONSTRAINT CK_CategoriaClasificacion_Clasificacion
            CHECK (Clasificacion IN ('Planta', 'Macetero', 'Otro'))
    );
END;
GO

MERGE dbo.CategoriaClasificacion AS destino
USING
(
    SELECT
        C.IdCategoria,
        CASE
            WHEN C.NombreCategoria LIKE 'Planta%' THEN 'Planta'
            WHEN C.NombreCategoria LIKE 'Macet%' THEN 'Macetero'
            ELSE 'Otro'
        END AS Clasificacion
    FROM dbo.Categorias C
) AS origen
    ON origen.IdCategoria = destino.IdCategoria
WHEN NOT MATCHED BY TARGET THEN
    INSERT (IdCategoria, Clasificacion)
    VALUES (origen.IdCategoria, origen.Clasificacion);
GO

-- ---------------------------------------------------------------------------
-- 2. Cuestionario del Asesor Inteligente.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.AsesorPreguntas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AsesorPreguntas
    (
        IdPregunta INT IDENTITY(1,1) NOT NULL,
        Codigo VARCHAR(40) NOT NULL,
        Texto VARCHAR(200) NOT NULL,
        Ayuda VARCHAR(255) NOT NULL CONSTRAINT DF_AsesorPreguntas_Ayuda DEFAULT (''),
        Orden INT NOT NULL CONSTRAINT DF_AsesorPreguntas_Orden DEFAULT (1),
        Estado VARCHAR(20) NOT NULL CONSTRAINT DF_AsesorPreguntas_Estado DEFAULT ('Activo'),
        CONSTRAINT PK_AsesorPreguntas PRIMARY KEY CLUSTERED (IdPregunta),
        CONSTRAINT UQ_AsesorPreguntas_Codigo UNIQUE (Codigo)
    );
END;
GO

IF OBJECT_ID('dbo.AsesorOpciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AsesorOpciones
    (
        IdOpcion INT IDENTITY(1,1) NOT NULL,
        IdPregunta INT NOT NULL,
        Codigo VARCHAR(40) NOT NULL,
        Etiqueta VARCHAR(100) NOT NULL,
        Descripcion VARCHAR(255) NOT NULL CONSTRAINT DF_AsesorOpciones_Descripcion DEFAULT (''),
        Orden INT NOT NULL CONSTRAINT DF_AsesorOpciones_Orden DEFAULT (1),
        Estado VARCHAR(20) NOT NULL CONSTRAINT DF_AsesorOpciones_Estado DEFAULT ('Activo'),
        CONSTRAINT PK_AsesorOpciones PRIMARY KEY CLUSTERED (IdOpcion),
        CONSTRAINT UQ_AsesorOpciones_PreguntaCodigo UNIQUE (IdPregunta, Codigo),
        CONSTRAINT FK_AsesorOpciones_AsesorPreguntas
            FOREIGN KEY (IdPregunta)
            REFERENCES dbo.AsesorPreguntas (IdPregunta)
            ON DELETE CASCADE
    );
END;
GO

-- Cada criterio suma peso a los productos que cumplen la condicion indicada.
IF OBJECT_ID('dbo.AsesorCriterios', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AsesorCriterios
    (
        IdCriterio INT IDENTITY(1,1) NOT NULL,
        IdOpcion INT NOT NULL,
        IdCategoria INT NULL,
        IdTipo INT NULL,
        PalabraClave VARCHAR(100) NULL,
        Peso INT NOT NULL CONSTRAINT DF_AsesorCriterios_Peso DEFAULT (1),
        CONSTRAINT PK_AsesorCriterios PRIMARY KEY CLUSTERED (IdCriterio),
        CONSTRAINT FK_AsesorCriterios_AsesorOpciones
            FOREIGN KEY (IdOpcion)
            REFERENCES dbo.AsesorOpciones (IdOpcion)
            ON DELETE CASCADE,
        CONSTRAINT FK_AsesorCriterios_Categorias
            FOREIGN KEY (IdCategoria)
            REFERENCES dbo.Categorias (IdCategoria),
        CONSTRAINT FK_AsesorCriterios_TiposProducto
            FOREIGN KEY (IdTipo)
            REFERENCES dbo.TiposProducto (IdTipo),
        CONSTRAINT CK_AsesorCriterios_Peso CHECK (Peso > 0),
        CONSTRAINT CK_AsesorCriterios_TieneCondicion
            CHECK (IdCategoria IS NOT NULL OR IdTipo IS NOT NULL OR PalabraClave IS NOT NULL)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.AsesorCriterios')
      AND name = 'IX_AsesorCriterios_Opcion'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_AsesorCriterios_Opcion
        ON dbo.AsesorCriterios (IdOpcion)
        INCLUDE (IdCategoria, IdTipo, PalabraClave, Peso);
END;
GO

-- ---------------------------------------------------------------------------
-- 3. Respuestas guardadas por usuario autenticado.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.AsesorRespuestas', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AsesorRespuestas
    (
        IdRespuesta INT IDENTITY(1,1) NOT NULL,
        IdUsuario INT NOT NULL,
        IdPregunta INT NOT NULL,
        IdOpcion INT NOT NULL,
        FechaRegistro DATETIME2(0) NOT NULL
            CONSTRAINT DF_AsesorRespuestas_FechaRegistro DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_AsesorRespuestas PRIMARY KEY CLUSTERED (IdRespuesta),
        CONSTRAINT UQ_AsesorRespuestas_UsuarioPregunta UNIQUE (IdUsuario, IdPregunta),
        CONSTRAINT FK_AsesorRespuestas_Usuarios
            FOREIGN KEY (IdUsuario)
            REFERENCES dbo.Usuarios (IdUsuario)
            ON DELETE CASCADE,
        CONSTRAINT FK_AsesorRespuestas_AsesorPreguntas
            FOREIGN KEY (IdPregunta)
            REFERENCES dbo.AsesorPreguntas (IdPregunta),
        CONSTRAINT FK_AsesorRespuestas_AsesorOpciones
            FOREIGN KEY (IdOpcion)
            REFERENCES dbo.AsesorOpciones (IdOpcion)
    );
END;
GO

IF TYPE_ID(N'dbo.TVP_AsesorOpcion') IS NULL
BEGIN
    EXEC
    (
        N'CREATE TYPE dbo.TVP_AsesorOpcion AS TABLE
        (
            IdOpcion INT NOT NULL PRIMARY KEY
        );'
    );
END;
GO

-- ---------------------------------------------------------------------------
-- 4. Datos base del cuestionario.
-- ---------------------------------------------------------------------------

MERGE dbo.AsesorPreguntas AS destino
USING
(
    VALUES
        ('espacio', 'Donde vas a colocar tus plantas o maceteros?',
            'El tipo de espacio define las condiciones ambientales de la recomendacion.', 1),
        ('luz', 'Cuanta luz natural recibe ese espacio?',
            'La luz disponible determina que especies se adaptan mejor.', 2),
        ('tiempo', 'Cuanto tiempo puedes dedicar al cuidado?',
            'El tiempo disponible define el nivel de mantenimiento sugerido.', 3),
        ('estilo', 'Que estilo prefieres para tus maceteros?',
            'El estilo orienta el acabado y el material de los maceteros.', 4)
) AS origen (Codigo, Texto, Ayuda, Orden)
    ON origen.Codigo = destino.Codigo
WHEN MATCHED THEN
    UPDATE SET
        destino.Texto = origen.Texto,
        destino.Ayuda = origen.Ayuda,
        destino.Orden = origen.Orden,
        destino.Estado = 'Activo'
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Codigo, Texto, Ayuda, Orden, Estado)
    VALUES (origen.Codigo, origen.Texto, origen.Ayuda, origen.Orden, 'Activo');
GO

MERGE dbo.AsesorOpciones AS destino
USING
(
    SELECT
        P.IdPregunta,
        O.Codigo,
        O.Etiqueta,
        O.Descripcion,
        O.Orden
    FROM
    (
        VALUES
            ('espacio', 'interior', 'Interior', 'Salas, oficinas y habitaciones techadas.', 1),
            ('espacio', 'exterior', 'Exterior', 'Jardines, terrazas y balcones abiertos.', 2),
            ('luz', 'baja', 'Luz baja', 'Espacios con poca luz natural directa.', 1),
            ('luz', 'media', 'Luz media', 'Luz indirecta durante buena parte del dia.', 2),
            ('luz', 'alta', 'Luz alta', 'Sol directo durante varias horas.', 3),
            ('tiempo', 'poco', 'Poco tiempo', 'Prefiero especies que casi se cuidan solas.', 1),
            ('tiempo', 'moderado', 'Tiempo moderado', 'Puedo dedicar un rato cada semana.', 2),
            ('tiempo', 'bastante', 'Bastante tiempo', 'Disfruto el cuidado frecuente de mis plantas.', 3),
            ('estilo', 'minimalista', 'Minimalista', 'Lineas simples y acabados sobrios.', 1),
            ('estilo', 'natural', 'Natural', 'Materiales calidos como terracota y concreto.', 2),
            ('estilo', 'decorativo', 'Decorativo', 'Piezas llamativas con acabado premium.', 3)
    ) AS O (CodigoPregunta, Codigo, Etiqueta, Descripcion, Orden)
    INNER JOIN dbo.AsesorPreguntas P
        ON P.Codigo = O.CodigoPregunta
) AS origen
    ON origen.IdPregunta = destino.IdPregunta
   AND origen.Codigo = destino.Codigo
WHEN MATCHED THEN
    UPDATE SET
        destino.Etiqueta = origen.Etiqueta,
        destino.Descripcion = origen.Descripcion,
        destino.Orden = origen.Orden,
        destino.Estado = 'Activo'
WHEN NOT MATCHED BY TARGET THEN
    INSERT (IdPregunta, Codigo, Etiqueta, Descripcion, Orden, Estado)
    VALUES (origen.IdPregunta, origen.Codigo, origen.Etiqueta, origen.Descripcion, origen.Orden, 'Activo');
GO

-- Criterios por categoria: el espacio elegido prioriza las categorias equivalentes.
INSERT dbo.AsesorCriterios (IdOpcion, IdCategoria, Peso)
SELECT
    O.IdOpcion,
    C.IdCategoria,
    5
FROM dbo.AsesorOpciones O
INNER JOIN dbo.AsesorPreguntas P
    ON P.IdPregunta = O.IdPregunta
   AND P.Codigo = 'espacio'
INNER JOIN dbo.Categorias C
    ON C.NombreCategoria LIKE '%' + O.Codigo + '%'
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.AsesorCriterios EX
    WHERE EX.IdOpcion = O.IdOpcion
      AND EX.IdCategoria = C.IdCategoria
);
GO

-- Criterios por tipo de producto: el espacio elegido prioriza el tipo equivalente.
INSERT dbo.AsesorCriterios (IdOpcion, IdTipo, Peso)
SELECT
    O.IdOpcion,
    T.IdTipo,
    3
FROM dbo.AsesorOpciones O
INNER JOIN dbo.AsesorPreguntas P
    ON P.IdPregunta = O.IdPregunta
   AND P.Codigo = 'espacio'
INNER JOIN dbo.TiposProducto T
    ON T.NombreTipo = O.Etiqueta
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.AsesorCriterios EX
    WHERE EX.IdOpcion = O.IdOpcion
      AND EX.IdTipo = T.IdTipo
);
GO

-- Criterios por palabra clave: se comparan contra nombre, descripcion,
-- caracteristicas, material y tamano del producto.
MERGE dbo.AsesorCriterios AS destino
USING
(
    SELECT
        O.IdOpcion,
        K.PalabraClave,
        K.Peso
    FROM
    (
        VALUES
            ('luz', 'baja', 'sansevieria', 3),
            ('luz', 'baja', 'pothos', 3),
            ('luz', 'baja', 'sombra', 2),
            ('luz', 'media', 'monstera', 3),
            ('luz', 'media', 'ficus', 3),
            ('luz', 'media', 'palma', 2),
            ('luz', 'alta', 'lavanda', 3),
            ('luz', 'alta', 'rosal', 3),
            ('luz', 'alta', 'hibiscus', 3),
            ('luz', 'alta', 'bugambilia', 2),
            ('tiempo', 'poco', 'sansevieria', 3),
            ('tiempo', 'poco', 'pothos', 3),
            ('tiempo', 'poco', 'facil', 2),
            ('tiempo', 'poco', 'cipres', 2),
            ('tiempo', 'moderado', 'monstera', 3),
            ('tiempo', 'moderado', 'palma', 2),
            ('tiempo', 'moderado', 'lavanda', 2),
            ('tiempo', 'bastante', 'rosal', 3),
            ('tiempo', 'bastante', 'hibiscus', 3),
            ('tiempo', 'bastante', 'ficus', 2),
            ('tiempo', 'bastante', 'bugambilia', 2),
            ('estilo', 'minimalista', 'minimalista', 4),
            ('estilo', 'minimalista', 'ceramica', 3),
            ('estilo', 'minimalista', 'blanca', 2),
            ('estilo', 'minimalista', 'negra', 2),
            ('estilo', 'natural', 'terracota', 4),
            ('estilo', 'natural', 'natural', 3),
            ('estilo', 'natural', 'concreto', 3),
            ('estilo', 'decorativo', 'decorativa', 4),
            ('estilo', 'decorativo', 'marmol', 3),
            ('estilo', 'decorativo', 'premium', 3)
    ) AS K (CodigoPregunta, CodigoOpcion, PalabraClave, Peso)
    INNER JOIN dbo.AsesorPreguntas P
        ON P.Codigo = K.CodigoPregunta
    INNER JOIN dbo.AsesorOpciones O
        ON O.IdPregunta = P.IdPregunta
       AND O.Codigo = K.CodigoOpcion
) AS origen
    ON origen.IdOpcion = destino.IdOpcion
   AND origen.PalabraClave = destino.PalabraClave
WHEN MATCHED THEN
    UPDATE SET destino.Peso = origen.Peso
WHEN NOT MATCHED BY TARGET THEN
    INSERT (IdOpcion, PalabraClave, Peso)
    VALUES (origen.IdOpcion, origen.PalabraClave, origen.Peso);
GO

-- ---------------------------------------------------------------------------
-- 5. Procedimientos del Asesor Inteligente.
-- ---------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerCuestionarioAsesor
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

CREATE OR ALTER PROCEDURE dbo.SP_GenerarRecomendacionesAsesor
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

CREATE OR ALTER PROCEDURE dbo.SP_GuardarRespuestasAsesor
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

CREATE OR ALTER PROCEDURE dbo.SP_LimpiarRespuestasAsesor
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

-- ---------------------------------------------------------------------------
-- 6. Detalle de pedido con tipo de producto y macetero por linea.
-- ---------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerMisPedidos
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

PRINT 'Asesor Inteligente y detalle de pedido enriquecido instalados.';
GO


-- =====================================================================
-- PARTE 2 DE 4: HISTORIAL DE COTIZACIONES YA GESTIONADAS (FILTRO @SOLOGESTIONADAS)
-- Origen: Concre_Innova_API/Database/Scripts/20260812_HistorialCotizacionesGestionadas.sql
-- =====================================================================

-- Historial de cotizaciones ya gestionadas (respondidas, aceptadas, aprobadas y rechazadas).
-- Fecha: 2026-08-12
-- Base de datos: ConcreInnovaDB
--
-- Agrega el filtro opcional @SoloGestionadas a los listados de cotizaciones.
-- El valor por defecto (0) conserva exactamente el comportamiento actual.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Cotizaciones')
      AND name = 'IX_Cotizaciones_EstadoFecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Cotizaciones_EstadoFecha
        ON dbo.Cotizaciones
        (
            Estado,
            FechaCotizacion DESC,
            IdCotizacion DESC
        )
        INCLUDE (IdCliente, NumeroSeguimiento, Total, FechaRespuesta);
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerMisCotizaciones
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

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerCotizacionesAdmin
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

PRINT 'Filtro de cotizaciones gestionadas instalado.';
GO


-- =====================================================================
-- PARTE 3 DE 4: ASISTENTE VIRTUAL, CONVERSACIONES PERSISTIDAS Y ESCALAMIENTO A SOPORTE
-- Origen: Concre_Innova_API/Database/Scripts/20260812_ChatBotYSoporteHumano.sql
-- =====================================================================

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


-- =====================================================================
-- PARTE 4 DE 4: VISUALIZACION DEL ESPACIO DEL USUARIO (IMAGEN Y PROYECTOS GUARDADOS)
-- Origen: Concre_Innova_API/Database/Scripts/20260812_VisualizacionEspacioUsuario.sql
-- =====================================================================

-- Visualizacion del espacio del usuario: imagen cargada y proyectos guardados.
-- Fecha: 2026-08-12
-- Base de datos: ConcreInnovaDB
--
-- Contenido:
--   1. Tabla Visualizaciones (proyecto guardado por usuario).
--   2. Tabla VisualizacionProductos (productos colocados con su configuracion).
--   3. Tipo de tabla para enviar los productos colocados.
--   4. Procedimientos de guardado, consulta y eliminacion.
--
-- Todos los procedimientos filtran por IdUsuario para que una persona solo
-- pueda leer o modificar sus propias visualizaciones.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

-- ---------------------------------------------------------------------------
-- 1. Encabezado de la visualizacion.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.Visualizaciones', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Visualizaciones
    (
        IdVisualizacion INT IDENTITY(1,1) NOT NULL,
        IdUsuario INT NOT NULL,
        Nombre VARCHAR(120) NOT NULL,
        RutaImagenEspacio VARCHAR(255) NOT NULL,
        AnchoLienzo INT NOT NULL,
        AltoLienzo INT NOT NULL,
        FechaCreacion DATETIME2(0) NOT NULL
            CONSTRAINT DF_Visualizaciones_FechaCreacion DEFAULT (SYSDATETIME()),
        FechaActualizacion DATETIME2(0) NOT NULL
            CONSTRAINT DF_Visualizaciones_FechaActualizacion DEFAULT (SYSDATETIME()),
        Estado VARCHAR(20) NOT NULL
            CONSTRAINT DF_Visualizaciones_Estado DEFAULT ('Activo'),
        CONSTRAINT PK_Visualizaciones PRIMARY KEY CLUSTERED (IdVisualizacion),
        CONSTRAINT FK_Visualizaciones_Usuarios
            FOREIGN KEY (IdUsuario)
            REFERENCES dbo.Usuarios (IdUsuario)
            ON DELETE CASCADE,
        CONSTRAINT CK_Visualizaciones_Lienzo
            CHECK (AnchoLienzo > 0 AND AltoLienzo > 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.Visualizaciones')
      AND name = 'IX_Visualizaciones_UsuarioFecha'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Visualizaciones_UsuarioFecha
        ON dbo.Visualizaciones (IdUsuario, FechaActualizacion DESC, IdVisualizacion DESC)
        INCLUDE (Nombre, RutaImagenEspacio, Estado);
END;
GO

-- ---------------------------------------------------------------------------
-- 2. Productos colocados sobre la imagen del espacio.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('dbo.VisualizacionProductos', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.VisualizacionProductos
    (
        IdVisualizacionProducto INT IDENTITY(1,1) NOT NULL,
        IdVisualizacion INT NOT NULL,
        IdProducto INT NOT NULL,
        IdVariante INT NULL,
        Cantidad INT NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Cantidad DEFAULT (1),
        Color VARCHAR(80) NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Color DEFAULT (''),
        Macetero VARCHAR(150) NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Macetero DEFAULT (''),
        PosicionX DECIMAL(9,2) NOT NULL,
        PosicionY DECIMAL(9,2) NOT NULL,
        Ancho DECIMAL(9,2) NOT NULL,
        Alto DECIMAL(9,2) NOT NULL,
        Rotacion DECIMAL(9,2) NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Rotacion DEFAULT (0),
        Orden INT NOT NULL
            CONSTRAINT DF_VisualizacionProductos_Orden DEFAULT (1),
        CONSTRAINT PK_VisualizacionProductos
            PRIMARY KEY CLUSTERED (IdVisualizacionProducto),
        CONSTRAINT FK_VisualizacionProductos_Visualizaciones
            FOREIGN KEY (IdVisualizacion)
            REFERENCES dbo.Visualizaciones (IdVisualizacion)
            ON DELETE CASCADE,
        CONSTRAINT FK_VisualizacionProductos_Productos
            FOREIGN KEY (IdProducto)
            REFERENCES dbo.Productos (IdProducto),
        CONSTRAINT FK_VisualizacionProductos_ProductoVariantes
            FOREIGN KEY (IdVariante)
            REFERENCES dbo.ProductoVariantes (IdVariante),
        CONSTRAINT CK_VisualizacionProductos_Cantidad CHECK (Cantidad > 0),
        CONSTRAINT CK_VisualizacionProductos_Dimensiones
            CHECK (Ancho > 0 AND Alto > 0)
    );
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.VisualizacionProductos')
      AND name = 'IX_VisualizacionProductos_Visualizacion'
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_VisualizacionProductos_Visualizacion
        ON dbo.VisualizacionProductos (IdVisualizacion, Orden, IdVisualizacionProducto);
END;
GO

-- ---------------------------------------------------------------------------
-- 3. Tipo de tabla para los productos colocados.
-- ---------------------------------------------------------------------------

IF TYPE_ID(N'dbo.TVP_VisualizacionProducto') IS NULL
BEGIN
    EXEC
    (
        N'CREATE TYPE dbo.TVP_VisualizacionProducto AS TABLE
        (
            IdProducto INT NOT NULL,
            IdVariante INT NULL,
            Cantidad INT NOT NULL,
            Color VARCHAR(80) NULL,
            Macetero VARCHAR(150) NULL,
            PosicionX DECIMAL(9,2) NOT NULL,
            PosicionY DECIMAL(9,2) NOT NULL,
            Ancho DECIMAL(9,2) NOT NULL,
            Alto DECIMAL(9,2) NOT NULL,
            Rotacion DECIMAL(9,2) NOT NULL,
            Orden INT NOT NULL
        );'
    );
END;
GO

-- ---------------------------------------------------------------------------
-- 4. Procedimientos.
-- ---------------------------------------------------------------------------

-- Crea o actualiza una visualizacion. Devuelve la ruta de la imagen anterior
-- cuando se reemplaza, para que la API pueda borrar el archivo en desuso.
CREATE OR ALTER PROCEDURE dbo.SP_GuardarVisualizacion
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

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerVisualizacionesUsuario
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

CREATE OR ALTER PROCEDURE dbo.SP_EliminarVisualizacion
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

PRINT 'Visualizacion del espacio del usuario instalada.';
GO


-- =====================================================================
-- VERIFICACION FINAL
-- Todas las filas deben mostrar Encontradas = Esperadas.
-- =====================================================================

SET NOCOUNT ON;

SELECT 'Tablas nuevas' AS Objeto, COUNT(*) AS Encontradas, 9 AS Esperadas
FROM sys.tables
WHERE name IN
(
    'CategoriaClasificacion', 'AsesorPreguntas', 'AsesorOpciones',
    'AsesorCriterios', 'AsesorRespuestas', 'BotIntenciones',
    'BotIntencionPalabras', 'Visualizaciones', 'VisualizacionProductos'
)
UNION ALL
SELECT 'Tipos de tabla nuevos', COUNT(*), 2
FROM sys.types
WHERE name IN ('TVP_AsesorOpcion', 'TVP_VisualizacionProducto')
UNION ALL
SELECT 'Procedimientos del sprint', COUNT(*), 18
FROM sys.procedures
WHERE name IN
(
    'SP_ObtenerCuestionarioAsesor', 'SP_GenerarRecomendacionesAsesor',
    'SP_GuardarRespuestasAsesor', 'SP_LimpiarRespuestasAsesor',
    'SP_ObtenerIntencionesBot', 'SP_ObtenerOCrearChatCliente',
    'SP_RegistrarMensajeChat', 'SP_ObtenerConversacionCliente',
    'SP_EscalarChatASoporte', 'SP_FinalizarChat', 'SP_ObtenerChatsAdmin',
    'SP_ObtenerMensajesChat', 'SP_GuardarVisualizacion',
    'SP_ObtenerVisualizacionesUsuario', 'SP_EliminarVisualizacion',
    'SP_ObtenerMisPedidos', 'SP_ObtenerMisCotizaciones',
    'SP_ObtenerCotizacionesAdmin'
)
UNION ALL
SELECT 'Chats.IdUsuario acepta NULL', COUNT(*), 1
FROM sys.columns
WHERE object_id = OBJECT_ID('dbo.Chats')
  AND name = 'IdUsuario'
  AND is_nullable = 1
UNION ALL
SELECT 'MensajesChat.Mensaje es NVARCHAR', COUNT(*), 1
FROM sys.columns C
INNER JOIN sys.types T ON T.user_type_id = C.user_type_id
WHERE C.object_id = OBJECT_ID('dbo.MensajesChat')
  AND C.name = 'Mensaje'
  AND T.name = 'nvarchar'
UNION ALL
SELECT 'Filtro @SoloGestionadas', COUNT(*), 2
FROM sys.parameters
WHERE name = '@SoloGestionadas'
  AND object_id IN
  (
      OBJECT_ID('dbo.SP_ObtenerMisCotizaciones'),
      OBJECT_ID('dbo.SP_ObtenerCotizacionesAdmin')
  )
UNION ALL
SELECT 'Preguntas del asesor', COUNT(*), 4 FROM dbo.AsesorPreguntas
UNION ALL
SELECT 'Opciones del asesor', COUNT(*), 11 FROM dbo.AsesorOpciones
UNION ALL
SELECT 'Intenciones del bot', COUNT(*), 20 FROM dbo.BotIntenciones
UNION ALL
SELECT 'Categorias clasificadas', COUNT(*), (SELECT COUNT(*) FROM dbo.Categorias)
FROM dbo.CategoriaClasificacion
UNION ALL
SELECT 'Emojis del bot legibles', COUNT(*), 1
FROM dbo.BotIntenciones
WHERE Codigo = 'saludo'
  AND Respuesta LIKE N'%' + NCHAR(55357) + NCHAR(56395) + N'%';
GO

PRINT 'Cambios de base de datos aplicados.';
GO

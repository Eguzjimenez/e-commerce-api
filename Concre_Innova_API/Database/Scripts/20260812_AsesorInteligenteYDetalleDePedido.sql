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

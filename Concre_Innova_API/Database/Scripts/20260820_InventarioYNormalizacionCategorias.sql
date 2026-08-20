/* ===========================================================================
   20260820 - Inventario administrable y normalizacion de nombres de categoria

   1. Permisos 'inventario.ver' e 'inventario.actualizar' para Administrador.
   2. SP_ObtenerInventario: listado paginado con busqueda, filtro por categoria
      y filtro por estado de existencias.
   3. SP_ObtenerInventarioDetalle: ficha de un producto con sus variantes.
   4. SP_ActualizarInventario: ajusta existencias y minimo manteniendo
      alineados Inventario.CantidadDisponible y Productos.Stock.
   5. Backfill de filas de Inventario faltantes y realineacion del stock.
   6. Colapso de espacios internos repetidos en Categorias.NombreCategoria,
      para que el control de duplicados no dependa de como se tecleo.

   El script es idempotente: puede ejecutarse varias veces sin efectos extra.
   =========================================================================== */

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

/* --------------------------------------------------------------------------
   1. Permisos
   -------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM dbo.Permisos WHERE Codigo = 'inventario.ver')
BEGIN
    INSERT INTO dbo.Permisos (Codigo, Nombre, Descripcion, Modulo, Estado)
    VALUES ('inventario.ver', N'Ver inventario',
            N'Consultar existencias y minimos de los productos.', N'Inventario', 'Activo');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Permisos WHERE Codigo = 'inventario.actualizar')
BEGIN
    INSERT INTO dbo.Permisos (Codigo, Nombre, Descripcion, Modulo, Estado)
    VALUES ('inventario.actualizar', N'Actualizar inventario',
            N'Ajustar existencias disponibles y cantidad minima.', N'Inventario', 'Activo');
END
GO

-- El inventario queda con el Administrador, igual que la navegacion del panel.
INSERT INTO dbo.RolPermisos (IdRol, IdPermiso)
SELECT R.IdRol, P.IdPermiso
FROM dbo.Roles R
CROSS JOIN dbo.Permisos P
WHERE R.NombreRol = 'Administrador'
  AND P.Codigo IN ('inventario.ver', 'inventario.actualizar')
  AND NOT EXISTS (
      SELECT 1 FROM dbo.RolPermisos RP
      WHERE RP.IdRol = R.IdRol AND RP.IdPermiso = P.IdPermiso);
GO

/* --------------------------------------------------------------------------
   5. Backfill: todo producto debe tener su fila de inventario y el stock
      resumido en Productos debe coincidir con ella.
   -------------------------------------------------------------------------- */
INSERT INTO dbo.Inventario (IdProducto, CantidadDisponible, CantidadMinima, FechaActualizacion)
SELECT P.IdProducto, ISNULL(P.Stock, 0), 0, GETDATE()
FROM dbo.Productos P
WHERE NOT EXISTS (SELECT 1 FROM dbo.Inventario I WHERE I.IdProducto = P.IdProducto);
GO

UPDATE I
SET I.CantidadDisponible = ISNULL(P.Stock, 0)
FROM dbo.Inventario I
INNER JOIN dbo.Productos P ON P.IdProducto = I.IdProducto
WHERE I.CantidadDisponible <> ISNULL(P.Stock, 0);
GO

/* --------------------------------------------------------------------------
   6. Normalizacion de nombres de categoria: se colapsan los espacios internos
      repetidos para que 'Macetas  Interior' y 'Macetas Interior' se traten
      como el mismo nombre.
   -------------------------------------------------------------------------- */
WITH Normalizadas AS (
    SELECT
        IdCategoria,
        NombreCategoria,
        REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(NombreCategoria)), '  ', ' <>'), '> <', ''), ' <>', ' ')
            AS NombreLimpio
    FROM dbo.Categorias
)
UPDATE C
SET C.NombreCategoria = N.NombreLimpio
FROM dbo.Categorias C
INNER JOIN Normalizadas N ON N.IdCategoria = C.IdCategoria
WHERE C.NombreCategoria <> N.NombreLimpio;
GO

/* --------------------------------------------------------------------------
   2. Listado de inventario
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerInventario
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

/* --------------------------------------------------------------------------
   3. Ficha de un producto del inventario
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.SP_ObtenerInventarioDetalle
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

/* --------------------------------------------------------------------------
   4. Ajuste de existencias
   -------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE dbo.SP_ActualizarInventario
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

PRINT 'Inventario administrable y normalizacion de categorias instalados.';
GO

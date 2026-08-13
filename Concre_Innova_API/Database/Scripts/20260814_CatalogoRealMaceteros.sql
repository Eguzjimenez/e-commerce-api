-- Catalogo real de maceteros de concreto: reemplaza los productos de demostracion
-- por las 9 lineas reales con sus 16 tamanos, precios y fotografias de estudio.
-- Fecha: 2026-08-14
-- Base de datos: ConcreInnovaDB
--
-- Las fotografias asociadas viven en wwwroot/images/productos y se despliegan
-- junto con la API. Los productos anteriores no se eliminan: se pasan a
-- Inactivo para conservar el historial de pedidos, cotizaciones y favoritos.
--
-- El script es idempotente: puede ejecutarse varias veces sin duplicar datos.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;

-- ======================================================
-- 1. Catalogo real
--    IdCategoria: 1 = Macetas Interior, 2 = Macetas Exterior
--    IdTipo:      1 = Interior, 2 = Exterior, 3 = Decorativo
-- ======================================================

DECLARE @Catalogo TABLE (
    Nombre VARCHAR(150),
    Descripcion VARCHAR(1000),
    Precio DECIMAL(10, 2),
    Imagen VARCHAR(255),
    IdCategoria INT,
    IdTipo INT,
    Tamano VARCHAR(80),
    Caracteristicas VARCHAR(500),
    Stock INT
);

INSERT INTO @Catalogo
(Nombre, Descripcion, Precio, Imagen, IdCategoria, IdTipo, Tamano, Caracteristicas, Stock)
VALUES
(N'Macetero Elder',
 'Macetero alto de lineas rectas y paredes ligeramente conicas. Su silueta cuadrada estiliza pasillos y entradas, y sostiene bien plantas de porte vertical como sansevierias o palmas jovenes.',
 32000.00, 'images/productos/macetero-elder.jpg', 1, 3, N'Pequeño',
 N'Alto 39 cm · Ancho 32 cm · Concreto · Acabado liso · Interior y exterior', 10),

(N'Psila Jumbo',
 'Jardinera ovalada de gran formato, baja y muy amplia. Pensada para composiciones de varias especies en terrazas, recibidores y espacios comerciales donde se busca una sola pieza protagonista.',
 65000.00, 'images/productos/psila-jumbo.jpg', 2, 2, 'Jumbo',
 N'Alto 26 cm · Ancho 88 cm · Concreto · Acabado liso · Ideal para composiciones', 6),

(N'Rombo',
 'Macetero hexagonal de caras facetadas y textura de piedra. La geometria marcada aporta caracter sin competir con la planta, y funciona igual de bien solo o en grupos de distinta altura.',
 38000.00, 'images/productos/rombo.jpg', 1, 3, 'Mediano',
 N'Alto 40 cm · Ancho 48 cm · Concreto · Acabado texturizado · Interior y exterior', 10),

(N'Vertical',
 'Macetero alto y estrecho de perfil conico. Gana altura sin ocupar superficie, por lo que resuelve esquinas, entradas y espacios estrechos donde se busca volumen en vertical.',
 45000.00, 'images/productos/vertical.jpg', 2, 2, 'Mediano',
 N'Alto 54 cm · Ancho 32 cm · Concreto · Acabado liso · Interior y exterior', 10),

(N'Cónico',
 'Pieza conica de boca inclinada y acabado texturizado en tono terracota. El corte diagonal del borde le da movimiento y la vuelve una pieza escultorica por si misma.',
 50000.00, 'images/productos/conico.jpg', 2, 2, 'Mediano',
 N'Alto 50 cm · Ancho 51 cm · Concreto · Acabado texturizado · Interior y exterior', 8),

(N'Macetero redondo',
 'Macetero redondo de paredes curvas y base recogida, disponible en cinco tamanos. El formato clasico de la linea: acompana desde arbustos pequenos hasta arboles de patio segun la medida elegida.',
 39000.00, 'images/productos/macetero-redondo.jpg', 2, 2, 'Grande',
 N'Cinco tamanos, de 45 x 50 cm a 72 x 88 cm · Concreto · Acabado liso · Interior y exterior', 25),

(N'Paila',
 'Jardinera baja y amplia en acabado negro mate. Su poca altura deja la planta a la vista y funciona muy bien sobre mesas, bancas y muros bajos. Disponible en dos tamanos.',
 30000.00, 'images/productos/paila-pequena.jpg', 1, 3, 'Mediano',
 N'Dos tamanos: 20 x 50 cm y 24 x 56 cm · Concreto · Acabado negro mate · Interior y exterior', 14),

(N'Novas',
 'Macetero conico de paredes altas y textura granulada, disponible en tres tamanos. Pensado para plantas de follaje amplio que necesitan profundidad de raiz sin ocupar mucho suelo.',
 35000.00, 'images/productos/novas.jpg', 2, 2, 'Grande',
 N'Tres tamanos: 40 x 34 cm, 52 x 36 cm y 64 x 40 cm · Concreto · Acabado texturizado · Interior y exterior', 18),

(N'Gota',
 'Cuenco amplio y de poca altura, con boca generosa y perfil redondeado. Su diametro permite composiciones bajas de varias especies y luce especialmente bien centrado en una mesa o en el piso.',
 43000.00, 'images/productos/gota.jpg', 1, 3, 'Grande',
 N'Alto 28 cm · Ancho 55 cm · Diametro 75 cm · Concreto · Acabado liso · Interior y exterior', 8);

-- ======================================================
-- 2. Los productos anteriores salen del catalogo publico.
--    Se conservan porque cuatro de ellos tienen historial comercial.
-- ======================================================

UPDATE dbo.Productos
SET Estado = 'Inactivo'
WHERE Estado <> 'Inactivo'
  AND Nombre NOT IN (SELECT Nombre FROM @Catalogo);

-- ======================================================
-- 3. Alta o actualizacion de los productos reales
-- ======================================================

MERGE dbo.Productos AS destino
USING @Catalogo AS origen
    ON destino.Nombre = origen.Nombre
WHEN MATCHED THEN
    UPDATE SET
        destino.Descripcion = origen.Descripcion,
        destino.Precio = origen.Precio,
        destino.Stock = origen.Stock,
        destino.Imagen = origen.Imagen,
        destino.Estado = 'Activo',
        destino.IdCategoria = origen.IdCategoria,
        destino.IdTipo = origen.IdTipo,
        destino.Tamano = origen.Tamano,
        destino.Material = 'Concreto',
        destino.Caracteristicas = origen.Caracteristicas
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Nombre, Descripcion, Precio, Stock, Imagen, Estado, FechaRegistro,
            IdCategoria, Tamano, Material, IdTipo, Caracteristicas)
    VALUES (origen.Nombre, origen.Descripcion, origen.Precio, origen.Stock, origen.Imagen,
            'Activo', GETDATE(), origen.IdCategoria, origen.Tamano, 'Concreto',
            origen.IdTipo, origen.Caracteristicas);

-- ======================================================
-- 4. Inventario de los productos activos
-- ======================================================

MERGE dbo.Inventario AS destino
USING
(
    SELECT P.IdProducto, ISNULL(P.Stock, 0) AS Cantidad
    FROM dbo.Productos P
    WHERE P.Estado = 'Activo'
) AS origen
    ON destino.IdProducto = origen.IdProducto
WHEN MATCHED THEN
    UPDATE SET
        destino.CantidadDisponible = origen.Cantidad,
        destino.CantidadMinima = 2,
        destino.FechaActualizacion = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (IdProducto, CantidadDisponible, CantidadMinima, FechaActualizacion)
    VALUES (origen.IdProducto, origen.Cantidad, 2, GETDATE());

-- ======================================================
-- 5. Variantes por tamano
-- ======================================================

DECLARE @Variantes TABLE (
    Producto VARCHAR(150),
    NombreVariante VARCHAR(150),
    Tamano VARCHAR(80),
    Precio DECIMAL(18, 2),
    Stock INT,
    Imagen VARCHAR(255)
);

INSERT INTO @Variantes (Producto, NombreVariante, Tamano, Precio, Stock, Imagen)
VALUES
('Macetero redondo', N'Tamaño 1', '72 x 88 cm', 100000.00, 4, 'images/productos/macetero-redondo.jpg'),
('Macetero redondo', N'Tamaño 2', '63 x 72 cm',  70000.00, 5, 'images/productos/macetero-redondo.jpg'),
('Macetero redondo', N'Tamaño 3', '58 x 68 cm',  60000.00, 5, 'images/productos/macetero-redondo.jpg'),
('Macetero redondo', N'Tamaño 4', '48 x 56 cm',  50000.00, 5, 'images/productos/macetero-redondo.jpg'),
('Macetero redondo', N'Tamaño 5', '45 x 50 cm',  39000.00, 6, 'images/productos/macetero-redondo.jpg'),
('Paila', N'Pequeña', '20 x 50 cm', 30000.00, 7, 'images/productos/paila-pequena.jpg'),
('Paila', 'Mediana', '24 x 56 cm', 35000.00, 7, 'images/productos/paila-mediana.jpg'),
('Novas', 'Grande',  '64 x 40 cm', 50000.00, 5, 'images/productos/novas.jpg'),
('Novas', 'Mediano', '52 x 36 cm', 45000.00, 6, 'images/productos/novas.jpg'),
('Novas', N'Pequeño', '40 x 34 cm', 35000.00, 7, 'images/productos/novas.jpg');

MERGE dbo.ProductoVariantes AS destino
USING
(
    SELECT
        P.IdProducto,
        V.NombreVariante,
        V.Tamano,
        V.Precio,
        V.Stock,
        V.Imagen
    FROM @Variantes V
    INNER JOIN dbo.Productos P ON P.Nombre = V.Producto
) AS origen
    ON destino.IdProducto = origen.IdProducto
   AND destino.NombreVariante = origen.NombreVariante
WHEN MATCHED THEN
    UPDATE SET
        destino.Tamano = origen.Tamano,
        destino.Material = 'Concreto',
        destino.Precio = origen.Precio,
        destino.Stock = origen.Stock,
        destino.Imagen = origen.Imagen,
        destino.Estado = 'Activo'
WHEN NOT MATCHED BY TARGET THEN
    INSERT (IdProducto, NombreVariante, Tamano, Material, Precio, Stock, Imagen, Estado, FechaRegistro)
    VALUES (origen.IdProducto, origen.NombreVariante, origen.Tamano, 'Concreto',
            origen.Precio, origen.Stock, origen.Imagen, 'Activo', GETDATE());

-- Las variantes de los productos retirados dejan de ofrecerse.
UPDATE V
SET V.Estado = 'Inactivo'
FROM dbo.ProductoVariantes V
INNER JOIN dbo.Productos P ON P.IdProducto = V.IdProducto
WHERE P.Estado = 'Inactivo'
  AND V.Estado <> 'Inactivo';

COMMIT TRANSACTION;
GO

-- ======================================================
-- 6. Verificacion
-- ======================================================

SELECT
    P.IdProducto, P.Nombre, P.Tamano, P.Precio, P.Stock, P.Imagen,
    C.NombreCategoria,
    (SELECT COUNT(1) FROM dbo.ProductoVariantes V
     WHERE V.IdProducto = P.IdProducto AND V.Estado = 'Activo') AS Variantes
FROM dbo.Productos P
INNER JOIN dbo.Categorias C ON C.IdCategoria = P.IdCategoria
WHERE P.Estado = 'Activo'
ORDER BY P.Nombre;

PRINT 'Catalogo real de maceteros instalado.';
GO

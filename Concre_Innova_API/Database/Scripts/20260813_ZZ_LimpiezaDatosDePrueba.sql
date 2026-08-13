-- MJ-02 · Depuracion de datos de prueba del catalogo publico.
-- Fecha: 2026-08-13
-- Base de datos: ConcreInnovaDB
--
-- ATENCION: este script BORRA datos. No forma parte de la instalacion y no debe
-- ejecutarse de forma automatica. Revise primero el listado que devuelve la
-- seccion de diagnostico y ajuste la tabla @Descartables antes de ejecutarlo.
--
-- Solo elimina productos sin historial comercial: si un producto aparece en un
-- pedido, en una cotizacion, en favoritos o en una visualizacion, se conserva y
-- se marca como Inactivo para retirarlo del catalogo sin romper la trazabilidad.

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET XACT_ABORT ON;
GO

DECLARE @Descartables TABLE (Nombre VARCHAR(150));

INSERT INTO @Descartables (Nombre)
VALUES
('sasasa'),
('qqqq'),
('ssss'),
('test insert'),
('test update products 2');

-- ------------------------------------------------------------------
-- 1. Diagnostico: que se eliminaria y que se conservaria.
-- ------------------------------------------------------------------
SELECT
    P.IdProducto,
    P.Nombre,
    P.Estado,
    CASE
        WHEN EXISTS (SELECT 1 FROM dbo.DetallePedido D WHERE D.IdProducto = P.IdProducto)
          OR EXISTS (SELECT 1 FROM dbo.DetalleCotizacion C WHERE C.IdProducto = P.IdProducto)
          OR EXISTS (SELECT 1 FROM dbo.SolicitudCotizacionProductos S WHERE S.IdProducto = P.IdProducto)
          OR EXISTS (SELECT 1 FROM dbo.Favoritos F WHERE F.IdProducto = P.IdProducto)
          OR EXISTS (SELECT 1 FROM dbo.VisualizacionProductos V WHERE V.IdProducto = P.IdProducto)
        THEN 'Se conserva como Inactivo (tiene historial)'
        ELSE 'Se elimina'
    END AS Accion
FROM dbo.Productos P
WHERE P.Nombre IN (SELECT Nombre FROM @Descartables);

-- ------------------------------------------------------------------
-- 2. Productos con historial: salen del catalogo pero se conservan.
-- ------------------------------------------------------------------
UPDATE P
SET P.Estado = 'Inactivo'
FROM dbo.Productos P
WHERE P.Nombre IN (SELECT Nombre FROM @Descartables)
  AND (
        EXISTS (SELECT 1 FROM dbo.DetallePedido D WHERE D.IdProducto = P.IdProducto)
     OR EXISTS (SELECT 1 FROM dbo.DetalleCotizacion C WHERE C.IdProducto = P.IdProducto)
     OR EXISTS (SELECT 1 FROM dbo.SolicitudCotizacionProductos S WHERE S.IdProducto = P.IdProducto)
     OR EXISTS (SELECT 1 FROM dbo.Favoritos F WHERE F.IdProducto = P.IdProducto)
     OR EXISTS (SELECT 1 FROM dbo.VisualizacionProductos V WHERE V.IdProducto = P.IdProducto)
  );
GO

-- ------------------------------------------------------------------
-- 3. Productos sin historial: se eliminan junto con sus dependencias.
-- ------------------------------------------------------------------
DECLARE @Eliminables TABLE (IdProducto INT);

INSERT INTO @Eliminables (IdProducto)
SELECT P.IdProducto
FROM dbo.Productos P
WHERE P.Nombre IN ('sasasa', 'qqqq', 'ssss', 'test insert', 'test update products 2')
  AND NOT EXISTS (SELECT 1 FROM dbo.DetallePedido D WHERE D.IdProducto = P.IdProducto)
  AND NOT EXISTS (SELECT 1 FROM dbo.DetalleCotizacion C WHERE C.IdProducto = P.IdProducto)
  AND NOT EXISTS (SELECT 1 FROM dbo.SolicitudCotizacionProductos S WHERE S.IdProducto = P.IdProducto)
  AND NOT EXISTS (SELECT 1 FROM dbo.Favoritos F WHERE F.IdProducto = P.IdProducto)
  AND NOT EXISTS (SELECT 1 FROM dbo.VisualizacionProductos V WHERE V.IdProducto = P.IdProducto);

DELETE FROM dbo.Inventario WHERE IdProducto IN (SELECT IdProducto FROM @Eliminables);
DELETE FROM dbo.ProductoVariantes WHERE IdProducto IN (SELECT IdProducto FROM @Eliminables);
DELETE FROM dbo.Productos WHERE IdProducto IN (SELECT IdProducto FROM @Eliminables);
GO

-- ------------------------------------------------------------------
-- 4. Telefonos que no cumplen el formato aceptado por la aplicacion.
--    Se listan para correccion manual: no se modifican datos de usuarios.
-- ------------------------------------------------------------------
SELECT IdUsuario, Telefono
FROM dbo.Usuarios
WHERE Telefono IS NOT NULL
  AND (LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Telefono, '+', ''), '-', ''), ' ', ''), '(', ''), ')', '')) < 8
       OR Telefono LIKE '%[A-Za-z]%');
GO

PRINT 'Depuracion de datos de prueba finalizada. Revise los listados devueltos.';
GO

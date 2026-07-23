-- Script para implementar la validación de stock del carrito
-- Fecha: 2026-06-26
-- Descripción: Crea el TVP y el Stored Procedure para validar stock de productos en el carrito

-- =============================================
-- 1. Crear el Tipo de Tabla TVP_Carrito
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.types WHERE name = 'TVP_Carrito' AND is_table_type = 1)
BEGIN
	CREATE TYPE TVP_Carrito AS TABLE
	(
		IdProducto INT,
		Cantidad INT
	);
	PRINT 'TVP_Carrito creado exitosamente.';
END
ELSE
BEGIN
	PRINT 'TVP_Carrito ya existe.';
END
GO

-- =============================================
-- 2. Crear/Actualizar el Stored Procedure SP_ValidarStockCarrito
-- =============================================
CREATE OR ALTER PROCEDURE SP_ValidarStockCarrito
(
	@Carrito TVP_Carrito READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		C.IdProducto,
		P.Nombre,
		C.Cantidad AS CantidadSolicitada,
		ISNULL(P.Stock, 0) AS StockDisponible,
		CASE
			WHEN P.IdProducto IS NULL THEN 'PRODUCTO_NO_EXISTE'
			WHEN P.Estado <> 'Activo' THEN 'PRODUCTO_NO_DISPONIBLE'
			WHEN P.Stock <= 0 THEN 'SIN_STOCK'
			WHEN P.Stock < C.Cantidad THEN 'STOCK_INSUFICIENTE'
			ELSE 'DISPONIBLE'
		END AS Estado
	FROM @Carrito C
	LEFT JOIN Productos P
		ON C.IdProducto = P.IdProducto;
END
GO

PRINT 'SP_ValidarStockCarrito creado/actualizado exitosamente.';
GO

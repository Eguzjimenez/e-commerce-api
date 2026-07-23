-- Script para obtener los pedidos de un usuario
-- Fecha: 2026-06-26
-- Descripción: Crea el Stored Procedure para obtener todos los pedidos de un usuario con su detalle

-- =============================================
-- Stored Procedure SP_ObtenerMisPedidos
-- =============================================
CREATE OR ALTER PROCEDURE SP_ObtenerMisPedidos
(
	@IdUsuario INT
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IdCliente INT;

	----------------------------------------
	-- Validar Usuario
	----------------------------------------
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

	----------------------------------------
	-- Obtener Cliente
	----------------------------------------
	SELECT @IdCliente = IdCliente
	FROM Clientes
	WHERE IdUsuario = @IdUsuario
	  AND Estado = 'Activo';

	IF @IdCliente IS NULL
	BEGIN
		SELECT
			0 AS Exitoso,
			'CLIENTE_NO_EXISTE' AS Mensaje;

		RETURN;
	END

	----------------------------------------
	-- Obtener Pedidos con Detalle
	----------------------------------------
	SELECT
		P.IdPedido,
		P.FechaPedido,
		P.Estado,
		P.DireccionEntrega,
		P.Total,

		DP.IdDetallePedido,
		DP.IdProducto,
		PR.Nombre,
		PR.Imagen,

		DP.Cantidad,
		DP.PrecioUnitario,
		DP.Subtotal

	FROM Pedidos P

	INNER JOIN DetallePedido DP
		ON P.IdPedido = DP.IdPedido

	INNER JOIN Productos PR
		ON DP.IdProducto = PR.IdProducto

	WHERE P.IdCliente = @IdCliente

	ORDER BY
		P.FechaPedido DESC,
		DP.IdDetallePedido ASC;

END
GO

PRINT 'SP_ObtenerMisPedidos creado/actualizado exitosamente.';
GO

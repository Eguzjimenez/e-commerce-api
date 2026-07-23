-- Script para registrar pedidos
-- Fecha: 2026-06-26 (Actualizado)
-- Descripción: Crea el Stored Procedure para registrar pedidos con IdUsuario
-- Cambios: Usa IdUsuario en lugar de IdCliente, crea cliente automáticamente si no existe

-- =============================================
-- Stored Procedure SP_RegistrarPedido
-- =============================================
CREATE OR ALTER PROCEDURE SP_RegistrarPedido
(
	@IdUsuario INT,
	@DireccionEntrega VARCHAR(255),
	@MetodoPago VARCHAR(50),
	@Carrito TVP_Carrito READONLY
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @IdCliente INT;
	DECLARE @IdPedido INT;
	DECLARE @Total DECIMAL(10,2);

	BEGIN TRY

		BEGIN TRANSACTION;

		----------------------------------------
		-- Validar que exista el usuario
		----------------------------------------
		IF NOT EXISTS
		(
			SELECT 1
			FROM Usuarios
			WHERE IdUsuario = @IdUsuario
			  AND Estado = 'Activo'
		)
		BEGIN
			RAISERROR('USUARIO_NO_EXISTE',16,1);
		END

		----------------------------------------
		-- Buscar el cliente
		----------------------------------------
		SELECT @IdCliente = IdCliente
		FROM Clientes
		WHERE IdUsuario = @IdUsuario;

		----------------------------------------
		-- Si no existe, crearlo automáticamente
		----------------------------------------
		IF @IdCliente IS NULL
		BEGIN
			INSERT INTO Clientes
			(
				IdUsuario,
				Nombre,
				Apellido,
				Correo,
				Telefono,
				Direccion
			)
			SELECT
				IdUsuario,
				Nombre,
				Apellido,
				Correo,
				Telefono,
				@DireccionEntrega
			FROM Usuarios
			WHERE IdUsuario = @IdUsuario;

			SET @IdCliente = SCOPE_IDENTITY();
		END

		----------------------------------------
		-- Validar Stock nuevamente
		----------------------------------------
		IF EXISTS
		(
			SELECT 1
			FROM @Carrito C
			INNER JOIN Productos P
				ON P.IdProducto = C.IdProducto
			WHERE
				P.Stock < C.Cantidad
				OR P.Estado <> 'Activo'
		)
		BEGIN
			RAISERROR('STOCK_INSUFICIENTE',16,1);
		END

		----------------------------------------
		-- Calcular Total
		----------------------------------------
		SELECT
			@Total = SUM(P.Precio * C.Cantidad)
		FROM @Carrito C
		INNER JOIN Productos P
			ON P.IdProducto = C.IdProducto;

		----------------------------------------
		-- Registrar Pedido
		----------------------------------------
		INSERT INTO Pedidos
		(
			IdCliente,
			DireccionEntrega,
			Total
		)
		VALUES
		(
			@IdCliente,
			@DireccionEntrega,
			@Total
		);

		SET @IdPedido = SCOPE_IDENTITY();

		----------------------------------------
		-- Registrar Detalle
		----------------------------------------
		INSERT INTO DetallePedido
		(
			IdPedido,
			IdProducto,
			Cantidad,
			PrecioUnitario,
			Subtotal
		)
		SELECT
			@IdPedido,
			C.IdProducto,
			C.Cantidad,
			P.Precio,
			P.Precio * C.Cantidad
		FROM @Carrito C
		INNER JOIN Productos P
			ON P.IdProducto = C.IdProducto;

		----------------------------------------
		-- Actualizar Stock
		----------------------------------------
		UPDATE P
		SET
			P.Stock = P.Stock - C.Cantidad
		FROM Productos P
		INNER JOIN @Carrito C
			ON P.IdProducto = C.IdProducto;

		----------------------------------------
		-- Registrar Venta
		----------------------------------------
		INSERT INTO Ventas
		(
			IdPedido,
			MetodoPago,
			EstadoPago,
			Total
		)
		VALUES
		(
			@IdPedido,
			@MetodoPago,
			'Pendiente',
			@Total
		);

		----------------------------------------
		-- Registrar Bitácora
		----------------------------------------
		INSERT INTO Bitacora
		(
			IdUsuario,
			TablaAfectada,
			Operacion,
			Descripcion
		)
		VALUES
		(
			@IdUsuario,
			'Pedidos',
			'INSERT',
			CONCAT(
				'Pedido #', @IdPedido,
				' creado correctamente. Cliente: ', @IdCliente,
				'. Total: ₡', FORMAT(@Total,'N2'),
				'. Inventario actualizado y venta registrada.'
			)
		);

		COMMIT TRANSACTION;

		-- Retornar resultado exitoso
		SELECT
			1 AS Exitoso,
			'PEDIDO_REGISTRADO' AS Mensaje,
			@IdPedido AS IdPedido,
			@IdCliente AS IdCliente,
			@Total AS Total;

	END TRY

	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		-- Retornar resultado fallido
		SELECT
			0 AS Exitoso,
			ERROR_MESSAGE() AS Mensaje;

	END CATCH

END;
GO

PRINT 'SP_RegistrarPedido creado/actualizado exitosamente.';
GO

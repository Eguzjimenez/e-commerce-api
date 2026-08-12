USE [ConcreInnovaDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_ActualizarInformacionUsuario]
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
			se mantiene la contraseña actual.

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


		-- Actualizar información del cliente
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
			'Información del usuario actualizada correctamente.' AS Mensaje,
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

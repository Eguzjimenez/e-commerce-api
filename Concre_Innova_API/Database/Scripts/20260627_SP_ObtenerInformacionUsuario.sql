USE [ConcreInnovaDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerInformacionUsuario
	@IdUsuario INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		U.IdUsuario,
		U.Nombre,
		U.Apellido,
		U.Correo,
		U.Telefono,
		U.Estado,
		U.FechaRegistro,
		U.IdRol,
		R.NombreRol,

		C.IdCliente,
		C.Direccion,
		C.Estado AS EstadoCliente,
		C.FechaRegistro AS FechaRegistroCliente

	FROM Usuarios U
	INNER JOIN Roles R
		ON U.IdRol = R.IdRol
	LEFT JOIN Clientes C
		ON U.IdUsuario = C.IdUsuario

	WHERE U.IdUsuario = @IdUsuario;
END
GO

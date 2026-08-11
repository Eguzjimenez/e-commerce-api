USE [ConcreInnovaDB_NEW]
GO

CREATE OR ALTER PROCEDURE SP_ObtenerInformacionUsuario
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

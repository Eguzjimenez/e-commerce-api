using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Cotizaciones
{
    public class CotizacionRepository : ICotizacionRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public CotizacionRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<CrearCotizacionResponseDto> CrearAsync(
            int idUsuario,
            string descripcion,
            string preferencias,
            IReadOnlyCollection<SolicitudCotizacionProductoRequestDto> productos,
            IReadOnlyCollection<CotizacionImagenAlmacenada> imagenes,
            CancellationToken cancellationToken)
        {
            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(
                "SP_CrearCotizacionConImagenes",
                connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            command.Parameters.Add("@Descripcion", SqlDbType.VarChar, 1000).Value =
                descripcion;
            command.Parameters.Add("@Preferencias", SqlDbType.VarChar, 1000).Value =
                preferencias;
            command.Parameters.Add(CrearSolicitudProductosParameter(productos));
            command.Parameters.Add(CrearImagenesParameter(imagenes));

            await connection.OpenAsync(cancellationToken);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);

            if (!await reader.ReadAsync(cancellationToken))
            {
                return new CrearCotizacionResponseDto
                {
                    Exitoso = false,
                    Mensaje = "La base de datos no devolvio el resultado de la cotización."
                };
            }

            return new CrearCotizacionResponseDto
            {
                Exitoso = reader.GetInt32(reader.GetOrdinal("Exitoso")) == 1,
                Mensaje = reader.GetString(reader.GetOrdinal("Mensaje")),
                IdCotizacion = reader.IsDBNull(reader.GetOrdinal("IdCotizacion"))
                    ? null
                    : reader.GetInt32(reader.GetOrdinal("IdCotizacion")),
                NumeroSeguimiento = GetOptionalString(reader, "NumeroSeguimiento"),
                CantidadImagenes = reader.GetInt32(reader.GetOrdinal("CantidadImagenes"))
            };
        }

        public Task<PaginatedResponseDto<CotizacionHistorialResponseDto>>
            ObtenerPorUsuarioAsync(
                int idUsuario,
                CotizacionHistorialQuery query,
                PaginationQuery pagination,
                CancellationToken cancellationToken)
        {
            return ObtenerPaginadasAsync(
                "SP_ObtenerMisCotizaciones",
                query,
                pagination,
                idUsuario,
                cancellationToken);
        }

        public Task<PaginatedResponseDto<CotizacionHistorialResponseDto>>
            ObtenerAdminAsync(
                CotizacionHistorialQuery query,
                PaginationQuery pagination,
                CancellationToken cancellationToken)
        {
            return ObtenerPaginadasAsync(
                "SP_ObtenerCotizacionesAdmin",
                query,
                pagination,
                null,
                cancellationToken);
        }

        public async Task<ActualizarCotizacionResponseDto> ResponderAsync(
            int idCotizacion,
            string respuesta,
            IReadOnlyCollection<CotizacionProductoRequestDto> productos,
            CancellationToken cancellationToken)
        {
            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(
                "SP_ResponderCotizacion",
                connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.Add("@IdCotizacion", SqlDbType.Int).Value = idCotizacion;
            command.Parameters.Add("@Respuesta", SqlDbType.VarChar, 1000).Value = respuesta;
            command.Parameters.Add(CrearProductosParameter(productos));

            await connection.OpenAsync(cancellationToken);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);

            return await LeerResultadoActualizacionAsync(reader, cancellationToken);
        }

        public async Task<ActualizarCotizacionResponseDto> DecidirAsync(
            int idUsuario,
            int idCotizacion,
            bool aceptar,
            CancellationToken cancellationToken)
        {
            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(
                "SP_DecidirCotizacion",
                connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            command.Parameters.Add("@IdCotizacion", SqlDbType.Int).Value = idCotizacion;
            command.Parameters.Add("@Aceptar", SqlDbType.Bit).Value = aceptar;

            await connection.OpenAsync(cancellationToken);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            var response = await LeerResultadoActualizacionAsync(
                reader,
                cancellationToken);

            if (!response.Exitoso ||
                !await reader.NextResultAsync(cancellationToken))
            {
                return response;
            }

            while (await reader.ReadAsync(cancellationToken))
            {
                response.Productos.Add(LeerProducto(reader));
            }

            return response;
        }

        public async Task<ActualizarCotizacionResponseDto> ResolverPorVendedorAsync(
            int idCotizacion,
            bool aprobar,
            CancellationToken cancellationToken)
        {
            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(
                "SP_ResolverCotizacionVendedor",
                connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.Add("@IdCotizacion", SqlDbType.Int).Value =
                idCotizacion;
            command.Parameters.Add("@Aprobar", SqlDbType.Bit).Value = aprobar;

            await connection.OpenAsync(cancellationToken);
            await using var reader =
                await command.ExecuteReaderAsync(cancellationToken);

            return await LeerResultadoActualizacionAsync(
                reader,
                cancellationToken);
        }

        public async Task<ActualizarCotizacionResponseDto> ConvertirEnPedidoAsync(
            int idCotizacion,
            CancellationToken cancellationToken)
        {
            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(
                "SP_ConvertirCotizacionEnPedido",
                connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.Add("@IdCotizacion", SqlDbType.Int).Value =
                idCotizacion;

            await connection.OpenAsync(cancellationToken);
            await using var reader =
                await command.ExecuteReaderAsync(cancellationToken);
            var response = await LeerResultadoActualizacionAsync(
                reader,
                cancellationToken);

            if (!response.Exitoso ||
                !await reader.NextResultAsync(cancellationToken))
            {
                return response;
            }

            while (await reader.ReadAsync(cancellationToken))
            {
                response.Productos.Add(LeerProducto(reader));
            }

            return response;
        }

        private async Task<PaginatedResponseDto<CotizacionHistorialResponseDto>>
            ObtenerPaginadasAsync(
                string procedureName,
                CotizacionHistorialQuery query,
                PaginationQuery pagination,
                int? idUsuario,
                CancellationToken cancellationToken)
        {
            await using var connection = _connectionFactory.CreateConnection();
            await using var command = new SqlCommand(procedureName, connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            if (idUsuario.HasValue)
            {
                command.Parameters.Add("@IdUsuario", SqlDbType.Int).Value =
                    idUsuario.Value;
            }

            command.Parameters.Add("@Pagina", SqlDbType.Int).Value =
                pagination.PageNumber;
            command.Parameters.Add("@TamanoPagina", SqlDbType.Int).Value =
                pagination.PageSize;
            command.Parameters.Add("@Estado", SqlDbType.VarChar, 30).Value =
                (object?)query.NormalizedStatus ?? DBNull.Value;
            command.Parameters.Add("@Busqueda", SqlDbType.VarChar, 100).Value =
                (object?)query.NormalizedSearchTerm ?? DBNull.Value;
            command.Parameters.Add("@SoloGestionadas", SqlDbType.Bit).Value =
                query.SoloGestionadas;

            await connection.OpenAsync(cancellationToken);
            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            var quotations = new Dictionary<int, CotizacionHistorialResponseDto>();

            while (await reader.ReadAsync(cancellationToken))
            {
                var quotation = new CotizacionHistorialResponseDto
                {
                    IdCotizacion = reader.GetInt32(reader.GetOrdinal("IdCotizacion")),
                    NumeroSeguimiento = GetOptionalString(
                        reader,
                        "NumeroSeguimiento"),
                    IdCliente = reader.GetInt32(reader.GetOrdinal("IdCliente")),
                    Cliente = GetOptionalString(reader, "Cliente"),
                    FechaSolicitud = reader.GetDateTime(reader.GetOrdinal("FechaSolicitud")),
                    Estado = GetOptionalString(reader, "Estado"),
                    Total = reader.GetDecimal(reader.GetOrdinal("Total")),
                    Descripcion = GetOptionalString(reader, "Descripcion"),
                    Preferencias = GetOptionalString(reader, "Preferencias"),
                    Respuesta = GetOptionalString(reader, "Respuesta"),
                    FechaRespuesta = GetOptionalDateTime(reader, "FechaRespuesta"),
                    IdPedido = GetOptionalInt(reader, "IdPedido")
                };

                quotations[quotation.IdCotizacion] = quotation;
            }

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    var idCotizacion = reader.GetInt32(
                        reader.GetOrdinal("IdCotizacion"));
                    if (quotations.TryGetValue(idCotizacion, out var quotation))
                    {
                        quotation.Productos.Add(LeerProducto(reader));
                    }
                }
            }

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    var idCotizacion = reader.GetInt32(
                        reader.GetOrdinal("IdCotizacion"));
                    if (quotations.TryGetValue(idCotizacion, out var quotation))
                    {
                        quotation.ProductosSolicitados.Add(
                            LeerProductoSolicitado(reader));
                    }
                }
            }

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    var idCotizacion = reader.GetInt32(
                        reader.GetOrdinal("IdCotizacion"));
                    if (quotations.TryGetValue(idCotizacion, out var quotation))
                    {
                        quotation.Imagenes.Add(new CotizacionImagenResponseDto
                        {
                            RutaArchivo = GetOptionalString(reader, "RutaArchivo"),
                            NombreOriginal = GetOptionalString(reader, "NombreOriginal"),
                            TipoContenido = GetOptionalString(reader, "TipoContenido"),
                            TamanoBytes = reader.GetInt64(reader.GetOrdinal("TamanoBytes"))
                        });
                    }
                }
            }

            var totalItems = 0;
            if (await reader.NextResultAsync(cancellationToken))
            {
                await LeerHistorialEstadosAsync(
                    reader,
                    quotations,
                    cancellationToken);
            }

            if (await reader.NextResultAsync(cancellationToken) &&
                await reader.ReadAsync(cancellationToken))
            {
                totalItems = reader.GetInt32(reader.GetOrdinal("TotalItems"));
            }

            return new PaginatedResponseDto<CotizacionHistorialResponseDto>
            {
                Items = quotations.Values,
                TotalItems = totalItems,
                PageNumber = pagination.PageNumber,
                PageSize = pagination.PageSize
            };
        }

        private static async Task LeerHistorialEstadosAsync(
            SqlDataReader reader,
            IReadOnlyDictionary<int, CotizacionHistorialResponseDto> quotations,
            CancellationToken cancellationToken)
        {
            while (await reader.ReadAsync(cancellationToken))
            {
                var idCotizacion = reader.GetInt32(
                    reader.GetOrdinal("IdCotizacion"));
                if (quotations.TryGetValue(idCotizacion, out var quotation))
                {
                    quotation.HistorialEstados.Add(
                        new CotizacionEstadoHistorialResponseDto
                        {
                            EstadoAnterior = GetOptionalNullableString(
                                reader,
                                "EstadoAnterior"),
                            EstadoNuevo = GetOptionalString(reader, "EstadoNuevo"),
                            FechaCambio = reader.GetDateTime(
                                reader.GetOrdinal("FechaCambio"))
                        });
                }
            }

        }

        private static CotizacionProductoSolicitadoResponseDto
            LeerProductoSolicitado(SqlDataReader reader)
        {
            return new CotizacionProductoSolicitadoResponseDto
            {
                IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                Nombre = GetOptionalString(reader, "Nombre"),
                Imagen = GetOptionalNullableString(reader, "Imagen"),
                Cantidad = reader.GetInt32(reader.GetOrdinal("Cantidad"))
            };
        }

        private static async Task<ActualizarCotizacionResponseDto>
            LeerResultadoActualizacionAsync(
                SqlDataReader reader,
                CancellationToken cancellationToken)
        {
            if (!await reader.ReadAsync(cancellationToken))
            {
                return new ActualizarCotizacionResponseDto
                {
                    Exitoso = false,
                    Mensaje = "La base de datos no devolvio el resultado de la operación."
                };
            }

            return new ActualizarCotizacionResponseDto
            {
                Exitoso = reader.GetInt32(reader.GetOrdinal("Exitoso")) == 1,
                Mensaje = GetOptionalString(reader, "Mensaje"),
                IdCotizacion = GetOptionalInt(reader, "IdCotizacion"),
                Estado = GetOptionalString(reader, "Estado"),
                Total = GetOptionalDecimal(reader, "Total"),
                IdPedido = GetOptionalInt(reader, "IdPedido")
            };
        }

        private static CotizacionProductoResponseDto LeerProducto(
            SqlDataReader reader)
        {
            return new CotizacionProductoResponseDto
            {
                IdProducto = reader.GetInt32(reader.GetOrdinal("IdProducto")),
                Nombre = GetOptionalString(reader, "Nombre"),
                Imagen = GetOptionalNullableString(reader, "Imagen"),
                Cantidad = reader.GetInt32(reader.GetOrdinal("Cantidad")),
                PrecioUnitario = reader.GetDecimal(
                    reader.GetOrdinal("PrecioUnitario")),
                Subtotal = reader.GetDecimal(reader.GetOrdinal("Subtotal"))
            };
        }

        private static SqlParameter CrearImagenesParameter(
            IEnumerable<CotizacionImagenAlmacenada> imagenes)
        {
            var table = new DataTable();
            table.Columns.Add("RutaArchivo", typeof(string));
            table.Columns.Add("NombreOriginal", typeof(string));
            table.Columns.Add("TipoContenido", typeof(string));
            table.Columns.Add("TamanoBytes", typeof(long));

            foreach (var imagen in imagenes)
            {
                table.Rows.Add(
                    imagen.RutaArchivo,
                    imagen.NombreOriginal,
                    imagen.TipoContenido,
                    imagen.TamanoBytes);
            }

            return new SqlParameter("@Imagenes", table)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "dbo.TVP_CotizacionImagen"
            };
        }

        private static SqlParameter CrearProductosParameter(
            IEnumerable<CotizacionProductoRequestDto> productos)
        {
            var table = new DataTable();
            table.Columns.Add("IdProducto", typeof(int));
            table.Columns.Add("Cantidad", typeof(int));
            table.Columns.Add("PrecioUnitario", typeof(decimal));

            foreach (var producto in productos)
            {
                table.Rows.Add(
                    producto.IdProducto,
                    producto.Cantidad,
                    producto.PrecioUnitario);
            }

            return new SqlParameter("@Productos", table)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "dbo.TVP_CotizacionProducto"
            };
        }

        private static SqlParameter CrearSolicitudProductosParameter(
            IEnumerable<SolicitudCotizacionProductoRequestDto> productos)
        {
            var table = new DataTable();
            table.Columns.Add("IdProducto", typeof(int));
            table.Columns.Add("Cantidad", typeof(int));

            foreach (var producto in productos)
            {
                table.Rows.Add(producto.IdProducto, producto.Cantidad);
            }

            return new SqlParameter("@ProductosSolicitados", table)
            {
                SqlDbType = SqlDbType.Structured,
                TypeName = "dbo.TVP_SolicitudCotizacionProducto"
            };
        }

        private static string GetOptionalString(
            SqlDataReader reader,
            string columnName)
        {
            var value = GetOptionalNullableString(reader, columnName);
            return value ?? string.Empty;
        }

        private static string? GetOptionalNullableString(
            SqlDataReader reader,
            string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static int? GetOptionalInt(
            SqlDataReader reader,
            string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
        }

        private static DateTime? GetOptionalDateTime(
            SqlDataReader reader,
            string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetDateTime(ordinal);
        }

        private static decimal GetOptionalDecimal(
            SqlDataReader reader,
            string columnName)
        {
            var ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? 0 : reader.GetDecimal(ordinal);
        }
    }
}

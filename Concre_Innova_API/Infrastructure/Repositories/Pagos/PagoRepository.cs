using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Pagos
{
    public class PagoRepository : IPagoRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public PagoRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<OperacionResponseDto> RegistrarComprobanteAsync(
            int idPedido,
            int idUsuario,
            string referencia,
            string? comprobanteArchivo,
            CancellationToken cancellationToken)
        {
            var resultado = new OperacionResponseDto();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_RegistrarComprobantePago", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.Add("@IdPedido", SqlDbType.Int).Value = idPedido;
            cmd.Parameters.Add("@IdUsuario", SqlDbType.Int).Value = idUsuario;
            cmd.Parameters.Add("@Referencia", SqlDbType.VarChar, 100).Value = referencia;
            cmd.Parameters.Add("@ComprobanteArchivo", SqlDbType.VarChar, 255).Value =
                (object?)comprobanteArchivo ?? DBNull.Value;

            await conn.OpenAsync(cancellationToken);

            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
            if (await reader.ReadAsync(cancellationToken))
            {
                resultado.Codigo = reader.GetInt32(reader.GetOrdinal("Codigo"));
                resultado.Mensaje = reader.GetString(reader.GetOrdinal("Mensaje"));
            }

            return resultado;
        }
    }
}

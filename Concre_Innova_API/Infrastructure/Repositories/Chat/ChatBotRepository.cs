using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Models;
using Concre_Innova_API.Infrastructure.Data;
using Microsoft.Data.SqlClient;
using System.Data;

namespace Concre_Innova_API.Infrastructure.Repositories.Chat
{
    public class ChatBotRepository : IChatBotRepository
    {
        private readonly ISqlConnectionFactory _connectionFactory;

        public ChatBotRepository(ISqlConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        public async Task<IReadOnlyList<BotIntencion>> ObtenerIntencionesAsync(
            CancellationToken cancellationToken)
        {
            var intencionesOrdenadas = new List<BotIntencion>();
            var intencionesPorId = new Dictionary<int, BotIntencion>();

            await using var conn = _connectionFactory.CreateConnection();
            await using var cmd = new SqlCommand("SP_ObtenerIntencionesBot", conn)
            {
                CommandType = CommandType.StoredProcedure
            };

            await conn.OpenAsync(cancellationToken);
            await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);

            while (await reader.ReadAsync(cancellationToken))
            {
                var intencion = MapIntencion(reader);
                intencionesOrdenadas.Add(intencion);
                intencionesPorId[intencion.IdIntencion] = intencion;
            }

            if (await reader.NextResultAsync(cancellationToken))
            {
                while (await reader.ReadAsync(cancellationToken))
                {
                    var idIntencion = reader.GetInt32(reader.GetOrdinal("IdIntencion"));

                    if (intencionesPorId.TryGetValue(idIntencion, out var intencion))
                    {
                        intencion.PalabrasClave.Add(
                            reader.GetString(reader.GetOrdinal("PalabraClave")));
                    }
                }
            }

            return intencionesOrdenadas;
        }

        private static BotIntencion MapIntencion(SqlDataReader reader)
        {
            return new BotIntencion
            {
                IdIntencion = reader.GetInt32(reader.GetOrdinal("IdIntencion")),
                Codigo = reader.GetString(reader.GetOrdinal("Codigo")),
                Respuesta = reader.GetString(reader.GetOrdinal("Respuesta")),
                SugiereProductos = reader.GetBoolean(reader.GetOrdinal("SugiereProductos")),
                SugiereEscalamiento =
                    reader.GetBoolean(reader.GetOrdinal("SugiereEscalamiento"))
            };
        }
    }
}

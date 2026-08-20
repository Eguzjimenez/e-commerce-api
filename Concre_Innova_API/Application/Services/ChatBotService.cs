using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.DTOs.Responses;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Models;
using System.Globalization;
using System.Text;

namespace Concre_Innova_API.Application.Services
{
    public class ChatBotService : IChatBotService
    {
        private const string RespuestaSinCoincidencia =
            "No estoy seguro de como responder esa pregunta. Puedes preguntarme sobre " +
            "métodos de pago, productos, pedidos, cotizaciones, envios, horarios o " +
            "información de contacto.";

        private const int MaximoTerminosBusqueda = 3;
        private const int LongitudMinimaTermino = 4;
        private const int MaximoProductosRecomendados = 4;
        private const int ProductosPorTermino = 5;

        /// <summary>
        /// Los terminos se recortan a esta longitud para que plurales y variantes
        /// de genero encuentren el producto ("maceteros" y "macetas" -> "macet").
        /// </summary>
        private const int LongitudRaizTermino = 5;

        /// <summary>
        /// Palabras frecuentes que no aportan significado a la busqueda de productos.
        /// </summary>
        private static readonly HashSet<string> PalabrasIgnoradas = new(StringComparer.Ordinal)
        {
            "para", "porque", "puedo", "quiero", "tienen", "tiene", "tienes", "sobre",
            "cual", "cuales", "como", "donde", "cuando", "algun", "alguna", "algunos",
            "algunas", "necesito", "busco", "buscar", "gustaria", "favor", "hola",
            "gracias", "informacion", "producto", "productos", "recomienda",
            "recomiendas", "recomendacion", "recomendaciones", "opciones", "opcion",
            "mejor", "mejores", "tengo", "quisiera", "podrias", "puedes"
        };

        private readonly IChatBotRepository _chatBotRepository;
        private readonly ICatalogoRepository _catalogoRepository;

        public ChatBotService(
            IChatBotRepository chatBotRepository,
            ICatalogoRepository catalogoRepository)
        {
            _chatBotRepository = chatBotRepository;
            _catalogoRepository = catalogoRepository;
        }

        public async Task<RespuestaBot> ResolverRespuestaAsync(
            string mensajeUsuario,
            CancellationToken cancellationToken)
        {
            var mensajeNormalizado = NormalizarTexto(mensajeUsuario);
            var intenciones = await _chatBotRepository.ObtenerIntencionesAsync(cancellationToken);
            var intencionDetectada = DetectarIntencion(mensajeNormalizado, intenciones);

            var respuesta = new RespuestaBot
            {
                Texto = intencionDetectada?.Respuesta ?? RespuestaSinCoincidencia,
                CodigoIntencion = intencionDetectada?.Codigo,
                SugiereEscalamiento =
                    intencionDetectada is null || intencionDetectada.SugiereEscalamiento
            };

            respuesta.ProductosRecomendados = await ObtenerRecomendacionesAsync(
                mensajeNormalizado,
                intencionDetectada,
                cancellationToken);

            return respuesta;
        }

        /// <summary>
        /// Busca productos relacionados con la consulta. Cuando la intencion es de
        /// compra y la busqueda no encuentra coincidencias, se ofrecen los productos
        /// disponibles para que la consulta nunca quede sin sugerencias.
        /// </summary>
        private async Task<List<CatalogoProductoResponseDto>> ObtenerRecomendacionesAsync(
            string mensajeNormalizado,
            BotIntencion? intencionDetectada,
            CancellationToken cancellationToken)
        {
            var recomendaciones = await BuscarProductosRecomendadosAsync(
                mensajeNormalizado,
                cancellationToken);

            if (recomendaciones.Count > 0 || intencionDetectada?.SugiereProductos != true)
                return recomendaciones;

            return await ObtenerProductosDisponiblesAsync();
        }

        private static BotIntencion? DetectarIntencion(
            string mensajeNormalizado,
            IReadOnlyList<BotIntencion> intenciones)
        {
            BotIntencion? mejorIntencion = null;
            var mejorPuntaje = 0;

            foreach (var intencion in intenciones)
            {
                var puntaje = ContarPalabrasClavePresentes(mensajeNormalizado, intencion);

                if (puntaje > mejorPuntaje)
                {
                    mejorPuntaje = puntaje;
                    mejorIntencion = intencion;
                }
            }

            return mejorIntencion;
        }

        private static int ContarPalabrasClavePresentes(
            string mensajeNormalizado,
            BotIntencion intencion)
        {
            return intencion.PalabrasClave.Count(palabraClave =>
                mensajeNormalizado.Contains(
                    NormalizarTexto(palabraClave),
                    StringComparison.Ordinal));
        }

        private async Task<List<CatalogoProductoResponseDto>> ObtenerProductosDisponiblesAsync()
        {
            var disponibles = await BuscarProductosPorTerminoAsync(string.Empty);

            return disponibles
                .OrderByDescending(producto => producto.Stock)
                .Take(MaximoProductosRecomendados)
                .ToList();
        }

        private async Task<List<CatalogoProductoResponseDto>> BuscarProductosRecomendadosAsync(
            string mensajeNormalizado,
            CancellationToken cancellationToken)
        {
            var terminos = ExtraerTerminosDeBusqueda(mensajeNormalizado);
            var coincidenciasPorProducto = new Dictionary<int, int>();
            var productosPorId = new Dictionary<int, CatalogoProductoResponseDto>();

            foreach (var termino in terminos)
            {
                cancellationToken.ThrowIfCancellationRequested();

                var encontrados = await BuscarProductosPorTerminoAsync(termino);

                foreach (var producto in encontrados)
                {
                    productosPorId[producto.IdProducto] = producto;
                    coincidenciasPorProducto[producto.IdProducto] =
                        coincidenciasPorProducto.GetValueOrDefault(producto.IdProducto) + 1;
                }
            }

            return productosPorId.Values
                .OrderByDescending(producto => coincidenciasPorProducto[producto.IdProducto])
                .ThenByDescending(producto => producto.Stock)
                .Take(MaximoProductosRecomendados)
                .ToList();
        }

        private async Task<IReadOnlyList<CatalogoProductoResponseDto>> BuscarProductosPorTerminoAsync(
            string termino)
        {
            var query = new CatalogoProductoQuery
            {
                Busqueda = string.IsNullOrEmpty(termino) ? null : termino,
                Disponibilidad = "disponible"
            };

            var resultado = await _catalogoRepository.BuscarCatalogoProductosPaginadoAsync(
                query,
                new PaginationQuery(1, ProductosPorTermino, ProductosPorTermino));

            return resultado.Items.ToList();
        }

        private static List<string> ExtraerTerminosDeBusqueda(string mensajeNormalizado)
        {
            return mensajeNormalizado
                .Split(
                    new[] { ' ', ',', '.', ';', ':', '?', '!', '\n', '\r', '\t' },
                    StringSplitOptions.RemoveEmptyEntries)
                .Where(EsTerminoBuscable)
                .Select(ObtenerRaizTermino)
                .Distinct(StringComparer.Ordinal)
                .Take(MaximoTerminosBusqueda)
                .ToList();
        }

        private static bool EsTerminoBuscable(string termino)
        {
            return termino.Length >= LongitudMinimaTermino &&
                   !PalabrasIgnoradas.Contains(termino);
        }

        private static string ObtenerRaizTermino(string termino)
        {
            return termino.Length > LongitudRaizTermino
                ? termino[..LongitudRaizTermino]
                : termino;
        }

        /// <summary>
        /// Convierte el texto a minusculas y elimina los acentos para que la
        /// comparacion de palabras clave no dependa de la escritura exacta.
        /// </summary>
        private static string NormalizarTexto(string texto)
        {
            if (string.IsNullOrWhiteSpace(texto))
                return string.Empty;

            var descompuesto = texto.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD);
            var acumulador = new StringBuilder(descompuesto.Length);

            foreach (var caracter in descompuesto)
            {
                if (CharUnicodeInfo.GetUnicodeCategory(caracter) != UnicodeCategory.NonSpacingMark)
                    acumulador.Append(caracter);
            }

            return acumulador.ToString().Normalize(NormalizationForm.FormC);
        }
    }
}

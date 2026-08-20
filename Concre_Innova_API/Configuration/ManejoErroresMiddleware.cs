using System.Text.Json;

namespace Concre_Innova_API.Configuration
{
    /// <summary>
    /// Convierte cualquier excepcion no controlada en una respuesta generica.
    /// El detalle tecnico queda unicamente en el registro del servidor: las
    /// respuestas nunca deben exponer SQL, rutas internas ni trazas de pila.
    /// </summary>
    public class ManejoErroresMiddleware
    {
        private const string MensajeGenerico =
            "Ocurrio un error al procesar la solicitud. Intente nuevamente.";

        // 499 es el codigo que ya usan los controladores para la cancelacion del cliente.
        private const int CodigoClienteCancelo = 499;

        private readonly RequestDelegate _next;
        private readonly ILogger<ManejoErroresMiddleware> _logger;

        public ManejoErroresMiddleware(RequestDelegate next, ILogger<ManejoErroresMiddleware> logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)
            {
                _logger.LogInformation(
                    "La solicitud {Método} {Ruta} fue cancelada por el cliente.",
                    context.Request.Method,
                    context.Request.Path);

                if (!context.Response.HasStarted)
                    context.Response.StatusCode = CodigoClienteCancelo;
            }
            catch (Exception exception)
            {
                _logger.LogError(
                    exception,
                    "Error no controlado en {Método} {Ruta}.",
                    context.Request.Method,
                    context.Request.Path);

                await EscribirRespuestaGenericaAsync(context);
            }
        }

        private static async Task EscribirRespuestaGenericaAsync(HttpContext context)
        {
            if (context.Response.HasStarted)
                return;

            context.Response.Clear();
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            context.Response.ContentType = "application/json; charset=utf-8";

            await context.Response.WriteAsync(
                JsonSerializer.Serialize(new { message = MensajeGenerico }));
        }
    }

    public static class ManejoErroresMiddlewareExtensions
    {
        public static IApplicationBuilder UseManejoDeErrores(this IApplicationBuilder app)
        {
            return app.UseMiddleware<ManejoErroresMiddleware>();
        }
    }
}

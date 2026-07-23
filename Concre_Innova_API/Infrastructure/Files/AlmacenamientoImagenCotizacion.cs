using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Models;

namespace Concre_Innova_API.Infrastructure.Files
{
    public class AlmacenamientoImagenCotizacion : IAlmacenamientoImagenCotizacion
    {
        private readonly string _wwwRootPath;
        private readonly string _cotizacionesRootPath;

        public AlmacenamientoImagenCotizacion(IWebHostEnvironment environment)
        {
            _wwwRootPath = environment.WebRootPath ??
                Path.Combine(environment.ContentRootPath, "wwwroot");
            _cotizacionesRootPath = Path.Combine(
                _wwwRootPath,
                "images",
                "cotizaciones");
        }

        public async Task<CotizacionImagenAlmacenada> GuardarAsync(
            int idUsuario,
            CotizacionImagenUploadDto imagen,
            string extension,
            CancellationToken cancellationToken)
        {
            var userDirectory = Path.Combine(
                _cotizacionesRootPath,
                idUsuario.ToString());
            Directory.CreateDirectory(userDirectory);

            var fileName = $"{Guid.NewGuid():N}{extension}";
            var physicalPath = Path.Combine(userDirectory, fileName);
            await File.WriteAllBytesAsync(
                physicalPath,
                imagen.Contenido,
                cancellationToken);

            return new CotizacionImagenAlmacenada
            {
                RutaArchivo =
                    $"images/cotizaciones/{idUsuario}/{fileName}",
                NombreOriginal = Path.GetFileName(imagen.NombreOriginal),
                TipoContenido = imagen.TipoContenido,
                TamanoBytes = imagen.Contenido.LongLength
            };
        }

        public Task EliminarAsync(
            IEnumerable<string> rutasRelativas,
            CancellationToken cancellationToken)
        {
            foreach (var rutaRelativa in rutasRelativas)
            {
                cancellationToken.ThrowIfCancellationRequested();

                var normalizedRelativePath = rutaRelativa
                    .Replace('/', Path.DirectorySeparatorChar)
                    .TrimStart(Path.DirectorySeparatorChar);
                var physicalPath = Path.GetFullPath(
                    Path.Combine(_wwwRootPath, normalizedRelativePath));
                var allowedRoot = Path.GetFullPath(_cotizacionesRootPath) +
                    Path.DirectorySeparatorChar;

                if (!physicalPath.StartsWith(
                        allowedRoot,
                        StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                if (File.Exists(physicalPath))
                {
                    File.Delete(physicalPath);
                }
            }

            return Task.CompletedTask;
        }
    }
}

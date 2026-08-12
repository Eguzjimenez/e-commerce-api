namespace Concre_Innova_API.Infrastructure.Files
{
    /// <summary>
    /// Guarda y elimina imagenes subidas por los usuarios dentro de
    /// wwwroot/images/{carpetaModulo}/{idUsuario}. Es la pieza compartida por
    /// los modulos que aceptan imagenes, para no repetir el manejo de rutas.
    /// </summary>
    public class AlmacenamientoImagenesEnDisco
    {
        private readonly string _wwwRootPath;
        private readonly string _moduloRootPath;

        public AlmacenamientoImagenesEnDisco(
            IWebHostEnvironment environment,
            string carpetaModulo)
        {
            _wwwRootPath = environment.WebRootPath ??
                Path.Combine(environment.ContentRootPath, "wwwroot");
            CarpetaModulo = carpetaModulo;
            _moduloRootPath = Path.Combine(_wwwRootPath, "images", carpetaModulo);
        }

        public string CarpetaModulo { get; }

        /// <summary>
        /// Escribe la imagen y devuelve su ruta relativa publica.
        /// </summary>
        public async Task<string> GuardarAsync(
            int idUsuario,
            byte[] contenido,
            string extension,
            CancellationToken cancellationToken)
        {
            var userDirectory = Path.Combine(_moduloRootPath, idUsuario.ToString());
            Directory.CreateDirectory(userDirectory);

            var fileName = $"{Guid.NewGuid():N}{extension}";
            var physicalPath = Path.Combine(userDirectory, fileName);

            await File.WriteAllBytesAsync(physicalPath, contenido, cancellationToken);

            return $"images/{CarpetaModulo}/{idUsuario}/{fileName}";
        }

        /// <summary>
        /// Elimina archivos ignorando cualquier ruta que apunte fuera de la
        /// carpeta del modulo.
        /// </summary>
        public Task EliminarAsync(
            IEnumerable<string> rutasRelativas,
            CancellationToken cancellationToken)
        {
            foreach (var rutaRelativa in rutasRelativas)
            {
                cancellationToken.ThrowIfCancellationRequested();
                EliminarArchivoDelModulo(rutaRelativa);
            }

            return Task.CompletedTask;
        }

        private void EliminarArchivoDelModulo(string rutaRelativa)
        {
            if (string.IsNullOrWhiteSpace(rutaRelativa))
                return;

            var normalizedRelativePath = rutaRelativa
                .Replace('/', Path.DirectorySeparatorChar)
                .TrimStart(Path.DirectorySeparatorChar);
            var physicalPath = Path.GetFullPath(
                Path.Combine(_wwwRootPath, normalizedRelativePath));
            var allowedRoot = Path.GetFullPath(_moduloRootPath) +
                Path.DirectorySeparatorChar;

            if (!physicalPath.StartsWith(allowedRoot, StringComparison.OrdinalIgnoreCase))
                return;

            if (File.Exists(physicalPath))
            {
                File.Delete(physicalPath);
            }
        }
    }
}

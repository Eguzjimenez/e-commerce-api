namespace Concre_Innova_API.Domain.Constants
{
    public static class AppRoles
    {
        public const int Administrador = 1;
        public const int Vendedor = 2;
        public const int Cliente = 3;
        public const int Inactivo = 4;

        public const string AdministradorNombre = "Administrador";
        public const string VendedorNombre = "Vendedor";
        public const string ClienteNombre = "Cliente";
        public const string InactivoNombre = "Inactivo";
        public const string RolesCompra = AdministradorNombre + "," + ClienteNombre;
        public const string RolesGestionCotizaciones =
            AdministradorNombre + "," + VendedorNombre;
        public const string RolesAtencionChat =
            AdministradorNombre + "," + VendedorNombre;

        public static string GetName(int? roleId)
        {
            return roleId switch
            {
                Administrador => AdministradorNombre,
                Vendedor => VendedorNombre,
                Cliente => ClienteNombre,
                Inactivo => InactivoNombre,
                _ => "Desconocido"
            };
        }
    }
}

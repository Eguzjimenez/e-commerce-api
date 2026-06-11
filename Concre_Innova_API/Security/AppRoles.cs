namespace Concre_Innova_API.Security
{
    public static class AppRoles
    {
        public const int Administrador = 1;
        public const int Vendedor = 2;
        public const int Cliente = 3;
        public const int Inactivo = 4;

        public static string GetName(int? roleId)
        {
            return roleId switch
            {
                Administrador => "Administrador",
                Vendedor => "Vendedor",
                Cliente => "Cliente",
                Inactivo => "Inactivo",
                _ => "Desconocido"
            };
        }
    }
}

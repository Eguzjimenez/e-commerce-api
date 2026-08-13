using System.Collections.ObjectModel;

namespace Concre_Innova_API.Domain.Constants
{
    public static class PermissionRolePolicy
    {
        private static readonly IReadOnlyDictionary<string, IReadOnlySet<int>> AllowedRolesByPermission =
            new ReadOnlyDictionary<string, IReadOnlySet<int>>(
                new Dictionary<string, IReadOnlySet<int>>(StringComparer.OrdinalIgnoreCase)
                {
                    [PermissionCodes.UsuariosVer] = AdminOnly(),
                    [PermissionCodes.UsuariosCrear] = AdminOnly(),
                    [PermissionCodes.UsuariosActualizar] = AdminOnly(),
                    [PermissionCodes.UsuariosEliminar] = AdminOnly(),
                    [PermissionCodes.RolesVer] = AdminOnly(),
                    [PermissionCodes.PermisosGestionar] = AdminOnly(),
                    [PermissionCodes.BitacoraVer] = AdminOnly(),
                    [PermissionCodes.ProductosCrear] = AdminOnly(),
                    [PermissionCodes.ProductosActualizar] = AdminOnly(),
                    [PermissionCodes.ProductosEliminar] = AdminOnly(),
                    [PermissionCodes.ProductosDuplicar] = AdminAndVendedor(),
                    [PermissionCodes.CategoriasLeer] = AdminOnly(),
                    [PermissionCodes.CategoriasCrear] = AdminOnly(),
                    [PermissionCodes.CategoriasActualizar] = AdminOnly(),
                    [PermissionCodes.CategoriasEliminar] = AdminOnly(),
                    [PermissionCodes.TiposProductoLeer] = AdminOnly(),
                    [PermissionCodes.TiposProductoCrear] = AdminOnly(),
                    [PermissionCodes.TiposProductoActualizar] = AdminOnly(),
                    [PermissionCodes.TiposProductoEliminar] = AdminOnly(),
                    [PermissionCodes.PedidosVer] = AdminOnly(),
                    [PermissionCodes.PedidosActualizar] = AdminOnly(),
                    [PermissionCodes.PedidosCancelar] = AdminOnly(),
                    [PermissionCodes.EstadisticasVer] = AdminOnly(),
                    [PermissionCodes.ReportesVer] = AdminAndVendedor(),
                    [PermissionCodes.EmpresaGestionar] = AdminOnly()
                });

        public static bool IsAdministrator(int roleId)
        {
            return roleId == AppRoles.Administrador;
        }

        public static bool CanRoleReceivePermission(int roleId, string permissionCode)
        {
            if (IsAdministrator(roleId))
                return true;

            var normalizedPermissionCode = NormalizePermissionCode(permissionCode);
            return AllowedRolesByPermission.TryGetValue(normalizedPermissionCode, out var allowedRoles) &&
                   allowedRoles.Contains(roleId);
        }

        private static IReadOnlySet<int> AdminOnly()
        {
            return new HashSet<int> { AppRoles.Administrador };
        }

        private static IReadOnlySet<int> AdminAndVendedor()
        {
            return new HashSet<int> { AppRoles.Administrador, AppRoles.Vendedor };
        }

        private static string NormalizePermissionCode(string permissionCode)
        {
            return string.IsNullOrWhiteSpace(permissionCode)
                ? string.Empty
                : permissionCode.Trim();
        }
    }
}

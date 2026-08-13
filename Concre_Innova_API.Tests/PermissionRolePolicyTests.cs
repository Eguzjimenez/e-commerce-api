using Concre_Innova_API.Domain.Constants;
using Xunit;

namespace Concre_Innova_API.Tests;

/// <summary>
/// Fija la matriz de permisos aprobada para el rol Vendedor. Un cambio accidental
/// en la politica —como el que detecto la auditoria con reportes.ver— rompe estas pruebas.
/// </summary>
public class PermissionRolePolicyTests
{
    [Theory]
    [InlineData(PermissionCodes.ProductosCrear)]
    [InlineData(PermissionCodes.ProductosActualizar)]
    [InlineData(PermissionCodes.ProductosEliminar)]
    [InlineData(PermissionCodes.ProductosDuplicar)]
    [InlineData(PermissionCodes.CategoriasLeer)]
    [InlineData(PermissionCodes.CategoriasCrear)]
    [InlineData(PermissionCodes.CategoriasActualizar)]
    [InlineData(PermissionCodes.CategoriasEliminar)]
    [InlineData(PermissionCodes.ConsultasVer)]
    [InlineData(PermissionCodes.ConsultasResponder)]
    public void Vendedor_puede_recibir_los_permisos_de_su_matriz(string permiso)
    {
        Assert.True(PermissionRolePolicy.CanRoleReceivePermission(AppRoles.Vendedor, permiso));
    }

    [Theory]
    [InlineData(PermissionCodes.ReportesVer)]
    [InlineData(PermissionCodes.EstadisticasVer)]
    [InlineData(PermissionCodes.BitacoraVer)]
    [InlineData(PermissionCodes.UsuariosVer)]
    [InlineData(PermissionCodes.UsuariosCrear)]
    [InlineData(PermissionCodes.UsuariosActualizar)]
    [InlineData(PermissionCodes.UsuariosEliminar)]
    [InlineData(PermissionCodes.RolesVer)]
    [InlineData(PermissionCodes.PermisosGestionar)]
    [InlineData(PermissionCodes.EmpresaGestionar)]
    [InlineData(PermissionCodes.PedidosVer)]
    [InlineData(PermissionCodes.PedidosActualizar)]
    [InlineData(PermissionCodes.PedidosCancelar)]
    public void Vendedor_no_puede_recibir_los_permisos_restringidos(string permiso)
    {
        Assert.False(PermissionRolePolicy.CanRoleReceivePermission(AppRoles.Vendedor, permiso));
    }

    [Theory]
    [InlineData(PermissionCodes.ReportesVer)]
    [InlineData(PermissionCodes.UsuariosEliminar)]
    [InlineData(PermissionCodes.ConsultasResponder)]
    [InlineData(PermissionCodes.ProductosCrear)]
    public void Administrador_conserva_acceso_completo(string permiso)
    {
        Assert.True(PermissionRolePolicy.CanRoleReceivePermission(AppRoles.Administrador, permiso));
    }

    [Theory]
    [InlineData(AppRoles.Cliente)]
    [InlineData(AppRoles.Inactivo)]
    public void Cliente_e_inactivo_no_reciben_permisos_administrativos(int rol)
    {
        Assert.False(PermissionRolePolicy.CanRoleReceivePermission(rol, PermissionCodes.ProductosCrear));
        Assert.False(PermissionRolePolicy.CanRoleReceivePermission(rol, PermissionCodes.ConsultasVer));
        Assert.False(PermissionRolePolicy.CanRoleReceivePermission(rol, PermissionCodes.ReportesVer));
    }

    [Fact]
    public void Un_permiso_desconocido_nunca_se_concede()
    {
        Assert.False(PermissionRolePolicy.CanRoleReceivePermission(AppRoles.Vendedor, "modulo.inexistente"));
        Assert.False(PermissionRolePolicy.CanRoleReceivePermission(AppRoles.Vendedor, string.Empty));
    }
}

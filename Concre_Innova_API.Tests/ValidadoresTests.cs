using Concre_Innova_API.Application.DTOs.Requests;
using Concre_Innova_API.Application.Validators;
using Concre_Innova_API.Domain.Constants;
using Concre_Innova_API.Shared.Helpers;
using Xunit;

namespace Concre_Innova_API.Tests;

public class PhoneNumberValidatorTests
{
    [Theory]
    [InlineData("8888-8888")]
    [InlineData("+506 8888 8888")]
    [InlineData("(506) 2222-3333")]
    [InlineData("88888888")]
    public void Acepta_formatos_legitimos(string telefono)
    {
        Assert.True(PhoneNumberValidator.IsValid(telefono));
    }

    [Theory]
    [InlineData("abcdefgh")]
    [InlineData("hyhwjwuhehudjdhj")]
    [InlineData("---")]
    [InlineData("123")]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData("8888-8888<script>")]
    [InlineData("1234567890123456789")]
    public void Rechaza_valores_invalidos(string telefono)
    {
        Assert.False(PhoneNumberValidator.IsValid(telefono));
    }

    [Fact]
    public void El_telefono_opcional_admite_valor_vacio()
    {
        Assert.True(PhoneNumberValidator.IsValidOrEmpty(null));
        Assert.True(PhoneNumberValidator.IsValidOrEmpty("   "));
        Assert.False(PhoneNumberValidator.IsValidOrEmpty("abcdefgh"));
    }
}

public class ProductoRequestValidatorTests
{
    private readonly ProductoRequestValidator _validator = new();

    private static CreateProductoRequest ProductoValido() => new()
    {
        Nombre = "Maceta de prueba",
        Descripcion = "Descripcion",
        Precio = 1000m,
        Imagen = "maceta.jpg",
        IdCategoria = 1,
        Tamano = "Mediano",
        Material = "Ceramica",
        Caracteristicas = string.Empty,
        CantidadDisponible = 5,
        CantidadMinima = 1
    };

    [Fact]
    public void Acepta_un_producto_valido()
    {
        Assert.Null(_validator.ValidateCreate(ProductoValido()));
    }

    [Fact]
    public void Rechaza_precio_negativo_o_cero()
    {
        var producto = ProductoValido();
        producto.Precio = -50m;
        Assert.NotNull(_validator.ValidateCreate(producto));

        producto.Precio = 0m;
        Assert.NotNull(_validator.ValidateCreate(producto));
    }

    [Fact]
    public void Rechaza_precio_por_encima_del_maximo_de_la_columna()
    {
        var producto = ProductoValido();
        producto.Precio = 99999999999999m;

        var mensaje = _validator.ValidateCreate(producto);

        Assert.NotNull(mensaje);
        Assert.Contains("máximo", mensaje, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Acepta_el_precio_maximo_de_la_columna()
    {
        var producto = ProductoValido();
        producto.Precio = 99999999.99m;

        Assert.Null(_validator.ValidateCreate(producto));
    }

    [Fact]
    public void Rechaza_nombre_en_blanco()
    {
        var producto = ProductoValido();
        producto.Nombre = "   ";

        Assert.NotNull(_validator.ValidateCreate(producto));
    }

    [Fact]
    public void Rechaza_cantidades_negativas()
    {
        var producto = ProductoValido();
        producto.CantidadDisponible = -10;
        Assert.NotNull(_validator.ValidateCreate(producto));

        producto = ProductoValido();
        producto.CantidadMinima = -1;
        Assert.NotNull(_validator.ValidateCreate(producto));
    }

    [Theory]
    [InlineData("Activo")]
    [InlineData("Inactivo")]
    [InlineData("Borrador")]
    public void Acepta_los_estados_del_catalogo(string estado)
    {
        var producto = new UpdateProductoRequest
        {
            IdProducto = 1,
            Nombre = "Maceta de prueba",
            Descripcion = "Descripcion",
            Precio = 1000m,
            Imagen = "maceta.jpg",
            IdCategoria = 1,
            Tamano = "Mediano",
            Material = "Ceramica",
            Caracteristicas = string.Empty,
            CantidadDisponible = 5,
            CantidadMinima = 1,
            Estado = estado
        };

        Assert.Null(_validator.ValidateUpdate(producto));
    }

    [Fact]
    public void Rechaza_un_estado_desconocido()
    {
        var producto = new UpdateProductoRequest
        {
            IdProducto = 1,
            Nombre = "Maceta de prueba",
            Descripcion = "Descripcion",
            Precio = 1000m,
            Imagen = "maceta.jpg",
            IdCategoria = 1,
            Tamano = "Mediano",
            Material = "Ceramica",
            Caracteristicas = string.Empty,
            CantidadDisponible = 5,
            CantidadMinima = 1,
            Estado = "Publicado"
        };

        Assert.NotNull(_validator.ValidateUpdate(producto));
    }
}

public class UserRequestValidatorTests
{
    private readonly UserRequestValidator _validator = new();

    [Fact]
    public void Rechaza_telefono_con_letras_al_crear_usuario()
    {
        var solicitud = new CreateUserRequest
        {
            Nombre = "Ana",
            Apellido = "Rojas",
            Correo = "ana.rojas@example.com",
            Contrasena = "Aa1!aaaa",
            Telefono = "hyhwjwuhehudjdhj",
            IdRol = 3
        };

        var mensaje = _validator.ValidateCreate(solicitud);

        Assert.NotNull(mensaje);
        Assert.Contains("teléfono", mensaje, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Acepta_un_usuario_con_telefono_valido()
    {
        var solicitud = new CreateUserRequest
        {
            Nombre = "Ana",
            Apellido = "Rojas",
            Correo = "ana.rojas@example.com",
            Contrasena = "Aa1!aaaa",
            Telefono = "8888-8888",
            IdRol = 3
        };

        Assert.Null(_validator.ValidateCreate(solicitud));
    }
}

public class AuthRequestValidatorTests
{
    private readonly AuthRequestValidator _validator = new();

    private static RegisterClientRequest SolicitudValida() => new()
    {
        Nombre = "Ana",
        Apellido = "Rojas",
        Correo = "ana.rojas@example.com",
        Telefono = "8888-8888",
        Direccion = "San Jose, Curridabat, 200m sur de la iglesia",
        Contrasena = "Aa1!aaaa"
    };

    [Fact]
    public void Acepta_un_registro_completo()
    {
        Assert.Null(_validator.ValidateClientRegistration(SolicitudValida()));
    }

    [Fact]
    public void Exige_el_apellido()
    {
        var solicitud = SolicitudValida();
        solicitud.Apellido = "   ";

        var mensaje = _validator.ValidateClientRegistration(solicitud);

        Assert.NotNull(mensaje);
        Assert.Contains("apellido", mensaje, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Exige_la_direccion_de_entrega()
    {
        var solicitud = SolicitudValida();
        solicitud.Direccion = null;

        var mensaje = _validator.ValidateClientRegistration(solicitud);

        Assert.NotNull(mensaje);
        Assert.Contains("dirección", mensaje, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Rechaza_una_direccion_demasiado_larga()
    {
        var solicitud = SolicitudValida();
        solicitud.Direccion = new string('a', 256);

        var mensaje = _validator.ValidateClientRegistration(solicitud);

        Assert.NotNull(mensaje);
        Assert.Contains("255", mensaje);
    }

    [Fact]
    public void Rechaza_un_telefono_invalido()
    {
        var solicitud = SolicitudValida();
        solicitud.Telefono = "abcdefgh";

        var mensaje = _validator.ValidateClientRegistration(solicitud);

        Assert.NotNull(mensaje);
        Assert.Contains("teléfono", mensaje, StringComparison.OrdinalIgnoreCase);
    }
}

public class NombreCatalogoNormalizerTests
{
    [Theory]
    [InlineData("  Macetas Interior  ", "Macetas Interior")]
    [InlineData("Macetas  Interior", "Macetas Interior")]
    [InlineData("Macetas\tInterior", "Macetas Interior")]
    [InlineData("Macetas   de    Concreto", "Macetas de Concreto")]
    public void Colapsa_los_espacios_repetidos(string entrada, string esperado)
    {
        Assert.Equal(esperado, NombreCatalogoNormalizer.Normalizar(entrada));
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("    ")]
    public void Devuelve_vacio_cuando_no_hay_nombre(string? entrada)
    {
        Assert.Equal(string.Empty, NombreCatalogoNormalizer.Normalizar(entrada));
    }

    [Fact]
    public void Dos_formas_de_teclear_el_mismo_nombre_coinciden()
    {
        Assert.Equal(
            NombreCatalogoNormalizer.Normalizar("Macetas Interior"),
            NombreCatalogoNormalizer.Normalizar("  Macetas   Interior "));
    }
}

public class InventarioRulesTests
{
    [Theory]
    [InlineData("disponible")]
    [InlineData("BAJO")]
    [InlineData("  agotado  ")]
    public void Acepta_los_estados_conocidos(string estado)
    {
        Assert.True(InventarioRules.EsEstadoValido(estado));
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("pendiente")]
    [InlineData("'; DROP TABLE Inventario; --")]
    public void Rechaza_cualquier_otro_estado(string? estado)
    {
        Assert.False(InventarioRules.EsEstadoValido(estado));
    }
}

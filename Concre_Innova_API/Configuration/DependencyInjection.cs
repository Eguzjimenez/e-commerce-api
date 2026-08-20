using Concre_Innova_API.Configuration.Settings;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Application.Services;
using Concre_Innova_API.Application.Validators;
using Concre_Innova_API.Infrastructure.Audit;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Infrastructure.Email;
using Concre_Innova_API.Infrastructure.Files;
using Concre_Innova_API.Infrastructure.Repositories.Asesor;
using Concre_Innova_API.Infrastructure.Repositories.Bitacora;
using Concre_Innova_API.Infrastructure.Repositories.Carrito;
using Concre_Innova_API.Infrastructure.Repositories.Catalogo;
using Concre_Innova_API.Infrastructure.Repositories.Chat;
using Concre_Innova_API.Infrastructure.Repositories.Cotizaciones;
using Concre_Innova_API.Infrastructure.Repositories.Empresa;
using Concre_Innova_API.Infrastructure.Repositories.Facturas;
using Concre_Innova_API.Infrastructure.Repositories.Inventario;
using Concre_Innova_API.Infrastructure.Repositories.Notificaciones;
using Concre_Innova_API.Infrastructure.Repositories.Pagos;
using Concre_Innova_API.Infrastructure.Repositories.Preferencias;
using Concre_Innova_API.Infrastructure.Repositories.Reportes;
using Concre_Innova_API.Infrastructure.Repositories.Favorites;
using Concre_Innova_API.Infrastructure.Repositories.Estadisticas;
using Concre_Innova_API.Infrastructure.Repositories.Login;
using Concre_Innova_API.Infrastructure.Repositories.Pedidos;
using Concre_Innova_API.Infrastructure.Repositories.Permissions;
using Concre_Innova_API.Infrastructure.Repositories.Roles;
using Concre_Innova_API.Infrastructure.Repositories.Users;
using Concre_Innova_API.Infrastructure.Repositories.Visualizaciones;
using Concre_Innova_API.Infrastructure.Security;
using Concre_Innova_API.Shared.Constants;

namespace Concre_Innova_API.Configuration
{
    public static class DependencyInjection
    {
        public static IServiceCollection AddApplicationServices(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            services.Configure<EmailSettings>(
                configuration.GetSection(ConfigurationKeys.EmailSettings));

            services.AddSingleton(
                configuration.GetSection(ConfigurationKeys.Jwt).Get<JwtSettings>() ?? new JwtSettings());
            services.AddSingleton(
                configuration.GetSection(ConfigurationKeys.SoporteHumano).Get<SoporteHumanoSettings>()
                    ?? new SoporteHumanoSettings());
            services.AddSingleton<ISqlConnectionFactory, SqlConnectionFactory>();

            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<ILoginRepository, LoginRepository>();
            services.AddScoped<IRecoveryRepository, RecoveryRepository>();
            services.AddScoped<IPasswordResetRepository, PasswordResetRepository>();
            services.AddScoped<IRoleRepository, RoleRepository>();
            services.AddScoped<IBitacoraRepository, BitacoraRepository>();
            services.AddScoped<ICatalogoRepository, CatalogoRepository>();
            services.AddScoped<IPermissionRepository, PermissionRepository>();
            services.AddScoped<IFavoriteRepository, FavoriteRepository>();
            services.AddScoped<ICarritoRepository, CarritoRepository>();
            services.AddScoped<ICotizacionRepository, CotizacionRepository>();
            services.AddScoped<
                ICotizacionNotificationRepository,
                CotizacionNotificationRepository>();
            services.AddScoped<IPedidoAdminRepository, PedidoAdminRepository>();
            services.AddScoped<IEstadisticasRepository, EstadisticasRepository>();
            services.AddScoped<IReporteRepository, ReporteRepository>();
            services.AddScoped<IEmpresaRepository, EmpresaRepository>();
            services.AddScoped<IPreferenciasRepository, PreferenciasRepository>();
            services.AddScoped<INotificacionRepository, NotificacionRepository>();
            services.AddScoped<IPagoRepository, PagoRepository>();
            services.AddScoped<IInventarioRepository, InventarioRepository>();
            services.AddScoped<IFacturaRepository, FacturaRepository>();
            services.AddScoped<IAsesorRepository, AsesorRepository>();
            services.AddScoped<IChatRepository, ChatRepository>();
            services.AddScoped<IChatBotRepository, ChatBotRepository>();
            services.AddScoped<IVisualizacionRepository, VisualizacionRepository>();

            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IRoleService, RoleService>();
            services.AddScoped<IBitacoraService, BitacoraService>();
            services.AddScoped<ICatalogoService, CatalogoService>();
            services.AddScoped<IPermissionService, PermissionService>();
            services.AddScoped<IFavoriteService, FavoriteService>();
            services.AddScoped<ICarritoService, CarritoService>();
            services.AddScoped<ICotizacionService, CotizacionService>();
            services.AddScoped<
                ICotizacionNotificationService,
                CotizacionNotificationService>();
            services.AddScoped<IAlmacenamientoImagenCotizacion, AlmacenamientoImagenCotizacion>();
            services.AddScoped<IAlmacenamientoImagenEspacio, AlmacenamientoImagenEspacio>();
            services.AddScoped<IVisualizacionService, VisualizacionService>();
            services.AddScoped<IPedidoAdminService, PedidoAdminService>();
            services.AddScoped<IEstadisticasService, EstadisticasService>();
            services.AddScoped<IReporteService, ReporteService>();
            services.AddScoped<IEmpresaService, EmpresaService>();
            services.AddScoped<IConsultaService, ConsultaService>();
            services.AddScoped<IPreferenciasService, PreferenciasService>();
            services.AddScoped<INotificacionService, NotificacionService>();
            services.AddScoped<IPagoService, PagoService>();
            services.AddScoped<IInventarioService, InventarioService>();
            services.AddScoped<IFacturaService, FacturaService>();
            services.AddScoped<IAlmacenamientoComprobantePago, AlmacenamientoComprobantePago>();
            services.AddScoped<INotificacionEventoService, NotificacionEventoService>();
            services.AddScoped<IAsesorService, AsesorService>();
            services.AddScoped<IChatBotService, ChatBotService>();
            services.AddScoped<IChatService, ChatService>();
            services.AddScoped<IChatAdminService, ChatAdminService>();
            services.AddScoped<IRequestUserContextService, RequestUserContextService>();
            services.AddScoped<IAuditService, AuditService>();
            services.AddScoped<IEmailService, EmailService>();
            services.AddScoped<ITokenService, TokenService>();
            services.AddSingleton<ILoginAttemptService, LoginAttemptService>();
            services.AddScoped<IAuthRequestValidator, AuthRequestValidator>();
            services.AddScoped<IUserRequestValidator, UserRequestValidator>();
            services.AddScoped<IProductoRequestValidator, ProductoRequestValidator>();
            services.AddScoped<ICategoriaRequestValidator, CategoriaRequestValidator>();
            services.AddScoped<ITipoProductoRequestValidator, TipoProductoRequestValidator>();
            services.AddScoped<IAsesorRequestValidator, AsesorRequestValidator>();
            services.AddScoped<IChatRequestValidator, ChatRequestValidator>();
            services.AddScoped<IVisualizacionRequestValidator, VisualizacionRequestValidator>();

            return services;
        }
    }
}

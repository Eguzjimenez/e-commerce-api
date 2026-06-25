using Concre_Innova_API.Configuration.Settings;
using Concre_Innova_API.Application.Interfaces.Repositories;
using Concre_Innova_API.Application.Interfaces.Services;
using Concre_Innova_API.Application.Interfaces.Validators;
using Concre_Innova_API.Application.Services;
using Concre_Innova_API.Application.Validators;
using Concre_Innova_API.Infrastructure.Audit;
using Concre_Innova_API.Infrastructure.Data;
using Concre_Innova_API.Infrastructure.Email;
using Concre_Innova_API.Infrastructure.Repositories.Bitacora;
using Concre_Innova_API.Infrastructure.Repositories.Catalogo;
using Concre_Innova_API.Infrastructure.Repositories.Login;
using Concre_Innova_API.Infrastructure.Repositories.Roles;
using Concre_Innova_API.Infrastructure.Repositories.Users;
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

            services.AddSingleton<ISqlConnectionFactory, SqlConnectionFactory>();

            services.AddScoped<IUserRepository, UserRepository>();
            services.AddScoped<ILoginRepository, LoginRepository>();
            services.AddScoped<IRecoveryRepository, RecoveryRepository>();
            services.AddScoped<IPasswordResetRepository, PasswordResetRepository>();
            services.AddScoped<IRoleRepository, RoleRepository>();
            services.AddScoped<IBitacoraRepository, BitacoraRepository>();
            services.AddScoped<ICatalogoRepository, CatalogoRepository>();

            services.AddScoped<IUserService, UserService>();
            services.AddScoped<IRoleService, RoleService>();
            services.AddScoped<IBitacoraService, BitacoraService>();
            services.AddScoped<ICatalogoService, CatalogoService>();
            services.AddScoped<IRequestUserContextService, RequestUserContextService>();
            services.AddScoped<IAuditService, AuditService>();
            services.AddScoped<IEmailService, EmailService>();
            services.AddScoped<IAuthRequestValidator, AuthRequestValidator>();
            services.AddScoped<IUserRequestValidator, UserRequestValidator>();
            services.AddScoped<IProductoRequestValidator, ProductoRequestValidator>();
            services.AddScoped<ICategoriaRequestValidator, CategoriaRequestValidator>();
            services.AddScoped<ITipoProductoRequestValidator, TipoProductoRequestValidator>();

            return services;
        }
    }
}

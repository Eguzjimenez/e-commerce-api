using Concre_Innova_API.Repositories.Login;
using Concre_Innova_API.Services.Audit;
using Concre_Innova_API.Services.Email;
using Concre_Innova_API.Services.Security;
using Concre_Innova_API.Services;
using Concre_Innova_API.Repositories.Bitacora;
using Concre_Innova_API.Services.Bitacora;
using Concre_Innova_API.Models;

var builder = WebApplication.CreateBuilder(args);

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactLocal", policy =>
        policy
            .SetIsOriginAllowed(origin =>
            {
                if (!Uri.TryCreate(origin, UriKind.Absolute, out var uri))
                    return false;

                if (!builder.Environment.IsDevelopment())
                    return origin == "http://localhost:3000";

                return uri.Host == "localhost" ||
                       uri.Host == "127.0.0.1" ||
                       uri.Host == "::1";
            })
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});


// Controllers
builder.Services.AddControllers();

builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));
builder.Services.AddScoped<Concre_Innova_API.Repositories.Users.IUserRepository, Concre_Innova_API.Repositories.Users.UserRepository>();
builder.Services.AddScoped<ILoginRepository, LoginRepository>();
builder.Services.AddScoped<IRecoveryRepository, RecoveryRepository>();
builder.Services.AddScoped<Concre_Innova_API.Services.IUserService, Concre_Innova_API.Services.UserService>();
builder.Services.AddScoped<IPasswordResetRepository, PasswordResetRepository>();
builder.Services.AddScoped<Concre_Innova_API.Repositories.Roles.IRoleRepository, Concre_Innova_API.Repositories.Roles.RoleRepository>();
builder.Services.AddScoped<Concre_Innova_API.Services.Role.IRoleService, Concre_Innova_API.Services.Role.RoleService>();
builder.Services.AddScoped<IRequestUserContextService, RequestUserContextService>();
builder.Services.AddScoped<IAuditService, AuditService>();
builder.Services.AddScoped<IEmailService, EmailService>();

// Bitacora
builder.Services.AddScoped<IBitacoraRepository, BitacoraRepository>();
builder.Services.AddScoped<IBitacoraService, BitacoraService>();
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("AllowReactLocal");
app.MapControllers();

app.Run();

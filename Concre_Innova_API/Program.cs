using Concre_Innova_API.Configuration;
using Concre_Innova_API.Configuration.Settings;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Falla el arranque si la clave de firma no esta configurada por entorno.
var jwtSettings = builder.Configuration.ObtenerJwtSettingsValidados();
var jwtKey = Encoding.UTF8.GetBytes(jwtSettings.Key!);

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(jwtKey),
            ValidateIssuer = !string.IsNullOrWhiteSpace(jwtSettings.Issuer),
            ValidIssuer = jwtSettings.Issuer,
            ValidateAudience = !string.IsNullOrWhiteSpace(jwtSettings.Audience),
            ValidAudience = jwtSettings.Audience,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddMemoryCache();

// CORS
var allowedOrigins = builder.Configuration
    .GetSection("AllowedOrigins")
    .Get<string[]>() ?? [];

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactLocal", policy =>
        policy
            .SetIsOriginAllowed(origin =>
            {
                if (!Uri.TryCreate(origin, UriKind.Absolute, out var uri))
                    return false;

                if (allowedOrigins.Contains(origin, StringComparer.OrdinalIgnoreCase))
                    return true;

                if (!builder.Environment.IsDevelopment())
                    return false;

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
builder.Services.AddApplicationServices(builder.Configuration);
Directory.CreateDirectory(Path.Combine(builder.Environment.ContentRootPath, "wwwroot"));
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

app.UseManejoDeErrores();
app.UseCors("AllowReactLocal");
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();

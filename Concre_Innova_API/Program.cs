using Concre_Innova_API.Repositories.Login;
using Concre_Innova_API.Services;

var builder = WebApplication.CreateBuilder(args);

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactLocal", policy =>
        policy
            .WithOrigins("http://localhost:3000")
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});


// Controllers
builder.Services.AddControllers();

builder.Services.AddScoped<Concre_Innova_API.Repositories.Users.IUserRepository, Concre_Innova_API.Repositories.Users.UserRepository>();
builder.Services.AddScoped<ILoginRepository, LoginRepository>();
builder.Services.AddScoped<IRecoveryRepository, RecoveryRepository>();
builder.Services.AddScoped<Concre_Innova_API.Services.IUserService, Concre_Innova_API.Services.UserService>();
builder.Services.AddScoped<IPasswordResetRepository, PasswordResetRepository>();
builder.Services.AddScoped<Concre_Innova_API.Repositories.Roles.IRoleRepository, Concre_Innova_API.Repositories.Roles.RoleRepository>();
builder.Services.AddScoped<Concre_Innova_API.Services.Role.IRoleService, Concre_Innova_API.Services.Role.RoleService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowReactLocal");
app.MapControllers();

app.Run();

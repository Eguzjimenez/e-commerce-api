using Concre_Innova_API.Repositories.Users;
using Concre_Innova_API.Services;

var builder = WebApplication.CreateBuilder(args);

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Controllers
builder.Services.AddControllers();

builder.Services.AddScoped<Concre_Innova_API.Repositories.Users.IUserRepository, Concre_Innova_API.Repositories.Users.UserRepository>();
builder.Services.AddScoped<Concre_Innova_API.Services.IUserService, Concre_Innova_API.Services.UserService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapControllers();

app.Run();

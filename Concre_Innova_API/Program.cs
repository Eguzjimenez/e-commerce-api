using Concre_Innova_API.Configuration;

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
builder.Services.AddApplicationServices(builder.Configuration);
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

using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors.Infrastructure;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Logging;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Prodot.Patterns.Cqrs;
using Prodot.Patterns.Cqrs.MicrosoftExtensionsDependencyInjection;
using RPGTableHelper.BusinessLayer;
using RPGTableHelper.BusinessLayer.Encryption;
using RPGTableHelper.BusinessLayer.Encryption.Contracts.Options;
using RPGTableHelper.DataLayer;
using RPGTableHelper.DataLayer.Contracts.Models.Auth;
using RPGTableHelper.DataLayer.Contracts.Queries.Users;
using RPGTableHelper.DataLayer.EfCore;
using RPGTableHelper.DataLayer.SendGrid;
using RPGTableHelper.DataLayer.SendGrid.Options;
using RPGTableHelper.Shared.Auth;
using RPGTableHelper.Shared.Options;
using RPGTableHelper.Shared.Services;
using RPGTableHelper.WebApi.Dtos;
using RPGTableHelper.WebApi.Options;
using RPGTableHelper.WebApi.Services;
using RPGTableHelper.WebApi.Swagger;

namespace RPGTableHelper.WebApi;

public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    // This method gets called by the runtime. Use this method to add services to the container.
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddHttpContextAccessor();
        services.AddTransient<IUserContext, UserContextProvider>();

        services.AddSingleton<IJWTTokenGenerator, JWTTokenGenerator>();
        services.AddSingleton<IAppleClientSecretGenerator, AppleClientSecretGenerator>();

        services.AddTransient(provider =>
        {
            var loggerFactory = provider.GetRequiredService<ILoggerFactory>();
            const string categoryName = "Any";
            return loggerFactory.CreateLogger(categoryName);
        });

        services
            .AddSignalR(signalR =>
            {
                signalR.MaximumReceiveMessageSize = long.MaxValue;
            })
            .AddMessagePackProtocol();

        AddCqrs(services);

        AddServiceOptions(services);

        services
            .AddAuthentication(options =>
            {
                // options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                // options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(o =>
            {
                o.Events = new JwtBearerEvents
                {
                    OnTokenValidated = context =>
                    {
                        // Custom token validation logic
                        var token = context.SecurityToken as Microsoft.IdentityModel.JsonWebTokens.JsonWebToken;
                        var tokenIdentifier = token?.Claims;

                        var identityProviderClaim = token?.Claims.FirstOrDefault(c => c.Type == "identityproviderid");
                        if (identityProviderClaim == null)
                        {
                            context.Fail("Token does not contain 'identityproviderid' claim.");
                            return Task.CompletedTask;
                        }

                        var identityProviderId = identityProviderClaim.Value;

                        // Access the service provider
                        var serviceProvider = context.HttpContext.RequestServices;

                        // Retrieve a service from the service provider
                        var queryProcessor = serviceProvider.GetRequiredService<IQueryProcessor>();
                        var cancellationToken = context.HttpContext.RequestAborted;

                        return Task.CompletedTask;
                    },
                    OnAuthenticationFailed = jwtContext =>
                    {
                        var accessToken = jwtContext.Principal;
                        return Task.CompletedTask;
                    },
                    OnChallenge = jwtContext =>
                    {
                        return Task.CompletedTask;
                    },
                    OnForbidden = jwtContext =>
                    {
                        return Task.CompletedTask;
                    },
                    OnMessageReceived = jwtContext =>
                    {
                        return Task.CompletedTask;
                    },
                };
                var jwtOptions = Configuration.GetSection("Jwt").Get<JwtOptions>();

                o.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidIssuer = jwtOptions?.Issuer ?? "api",
                    ValidAudience = jwtOptions?.Audience ?? "api",
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(
                            jwtOptions?.Key ?? string.Join(string.Empty, Enumerable.Repeat("asdfasdf", 200))
                        )
                    ),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                };
            });

        services.AddAuthorization(options =>
        {
            options.DefaultPolicy = new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser()
                .AddAuthenticationSchemes("Bearer")
                .Build();
        });

        services
            .AddControllers()
            .AddNewtonsoftJson(j =>
            {
                j.SerializerSettings.TypeNameHandling = Newtonsoft.Json.TypeNameHandling.None;
                j.SerializerSettings.Converters.Add(new Newtonsoft.Json.Converters.StringEnumConverter());
            });

        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(c =>
        {
            // enforce publishing dtos even when models not directly exposed via endpoints
            c.DocumentFilter<CustomModelDocumentFilter<RegisterWithApiKeyDto>>();
            c.DocumentFilter<CustomModelDocumentFilter<RegisterWithUsernamePasswordDto>>();

            c.SchemaFilter<EnumSchemaFilter>();

            c.SwaggerDoc("v1.0", new OpenApiInfo { Title = "Main API v1.0", Version = "v1.0" });

            // Set the comments path for the Swagger JSON and UI.
            var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
            var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
            c.IncludeXmlComments(xmlPath);

            c.AddSecurityDefinition(
                "Bearer",
                new OpenApiSecurityScheme
                {
                    Name = "Authorization",
                    Type = SecuritySchemeType.ApiKey,
                    Scheme = "Bearer",
                    BearerFormat = "JWT",
                    In = ParameterLocation.Header,
                    Description =
                        "JWT Authorization header using the Bearer scheme. \r\n\r\n Enter 'Bearer' [space] and then your token in the text input below.\r\n\r\nExample: \"Bearer 1safsfsdfdfd\"",
                }
            );
            c.AddSecurityRequirement(
                new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" },
                        },
                        new string[] { }
                    },
                }
            );
            // c.GeneratePolymorphicSchemas();
        });

        services.AddCors(options =>
            options.AddPolicy(
                "CorsPolicy",
                builder =>
                {
                    builder.AllowAnyHeader().AllowAnyMethod().SetIsOriginAllowed((host) => true).AllowCredentials();
                }
            )
        );
        services.AddMemoryCache();
        services.AddHttpClient();

        services.AddAutoMapper(typeof(DataLayerEntitiesMapperProfile), typeof(SharedMapperProfile));

        // services.AddSingleton<ITypedMemoryCache<AzureBlobStorageOptions>>(
        //     new TypedMemoryCache<AzureBlobStorageOptions>(cache, memoryCacheSize)
        // );
    }

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();

            app.UseExceptionHandler(errorApp =>
            {
                errorApp.Run(async context =>
                {
                    var exceptionHandlerPathFeature = context.Features.Get<IExceptionHandlerPathFeature>();

                    var exception = exceptionHandlerPathFeature?.Error;

                    // Log the exception
                    context.Response.StatusCode = 500;
                    Console.WriteLine(exception);
                    await context.Response.WriteAsync("An internal server error occurred.\n" + exception?.ToString());
                });
            });
        }
        else
        {
            app.UseExceptionHandler("/Error");
            app.UseHsts();
        }

        if (env.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1.0/swagger.json", "Versioned API v1.0");
            });
            IdentityModelEventSource.ShowPII = true;
        }

        app.UseHttpsRedirection();
        app.UseDefaultFiles();
        app.UseStaticFiles();
        app.UseCookiePolicy();
        app.UseCors("CorsPolicy");

        app.UseRouting();

        app.UseAuthentication();
        app.UseAuthorization();
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapHub<RpgServerHub>("/Chat", (options) => { });
            endpoints.MapControllers();
        });
    }

    private static void AddCqrs(IServiceCollection services)
    {
        services.AddProdotPatternsCqrs(options =>
            options
                .WithQueryHandlersFrom(
                    typeof(BusinessLayerPipelineProfile).Assembly,
                    typeof(BusinessLayerEncryptionPipelineProfile).Assembly,
                    typeof(DataLayerPipelineProfile).Assembly,
                    typeof(DataLayerSendGridPipelineProfile).Assembly
                )
                .WithQueryHandlerPipelineConfiguration(config =>
                    config
                        .WithPipelineAutoRegistration() // using this, we can skip registration if there is an unambiguous mapping between query and handler
                        .AddProfiles(
                            typeof(BusinessLayerPipelineProfile).Assembly,
                            typeof(BusinessLayerEncryptionPipelineProfile).Assembly,
                            typeof(DataLayerPipelineProfile).Assembly,
                            typeof(DataLayerSendGridPipelineProfile).Assembly
                        )
                )
        );
    }

    private void AddServiceOptions(IServiceCollection services)
    {
        var sendGridOptions = Configuration.GetSection("SendGrid").Get<SendGridOptions>();
        if (sendGridOptions != null)
        {
            services.AddSingleton(sendGridOptions);
        }

        var jwtOptions = Configuration.GetSection("Jwt").Get<JwtOptions>();
        if (jwtOptions != null)
        {
            services.AddSingleton(jwtOptions);
        }

        var sqlOptions = Configuration.GetSection("Sql").Get<SqlServerOptions>();
        if (sqlOptions != null)
        {
            services.AddSingleton(sqlOptions!);
        }

        services.AddDbContextFactory<RpgDbContext>(options =>
        {
            options.UseSqlite($"DataSource=file:maindb1");
        });

        services.AddSingleton<ISystemClock, RealSystemClock>();

        var appleOptions = Configuration.GetSection("Apple").Get<AppleAuthOptions>();
        if (appleOptions != null)
        {
            services.AddSingleton(appleOptions!);
        }

        var rsaOptions = Configuration.GetSection("RSA").Get<RSAOptions>();
        if (rsaOptions != null)
        {
            services.AddSingleton(rsaOptions!);
        }
    }
}

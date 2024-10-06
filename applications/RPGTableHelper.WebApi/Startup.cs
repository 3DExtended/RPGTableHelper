using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
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
using RPGTableHelper.DataLayer.SendGrid;
using RPGTableHelper.DataLayer.SendGrid.Options;
using RPGTableHelper.Shared.Auth;
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
                    OnTokenValidated = async context =>
                    {
                        // Custom token validation logic
                        var token =
                            context.SecurityToken
                            as Microsoft.IdentityModel.JsonWebTokens.JsonWebToken;
                        var tokenIdentifier = token?.Claims;
                        var identityProviderId = token
                            ?.Claims.Single(c => c.Type == "identityproviderid")
                            .Value;

                        // Access the service provider
                        var serviceProvider = context.HttpContext.RequestServices;

                        // Retrieve a service from the service provider
                        var queryProcessor = serviceProvider.GetRequiredService<IQueryProcessor>();
                        var cancellationToken = context.HttpContext.RequestAborted;

                        // Check if the token is revoked
                        var isTokenRevoked = await new UserIsDeletedQuery
                        {
                            UserIdentifier = User.UserIdentifier.From(
                                Guid.Parse(identityProviderId)
                            ),
                        }
                            .RunAsync(queryProcessor, cancellationToken)
                            .ConfigureAwait(false);

                        // Implement logic to check if tokenIdentifier exists in revoked tokens list

                        if (isTokenRevoked.IsNone || isTokenRevoked.Get() == true)
                        {
                            context.Fail("Token has been revoked.");
                        }
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

                o.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidIssuer = Configuration.GetSection("Jwt")["Issuer"],
                    ValidAudience = Configuration.GetSection("Jwt")["Audience"],
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(Configuration.GetSection("Jwt")["Key"])
                    ),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = false,
                    ValidateIssuerSigningKey = true,
                };
            });

        services.AddAuthorization(options =>
        {
            options.DefaultPolicy = new AuthorizationPolicyBuilder()
                .RequireAuthenticatedUser()
                .AddAuthenticationSchemes("Bearer") //, "Apple")
                .Build();
        });

        services
            .AddControllers()
            .AddNewtonsoftJson(j =>
            {
                j.SerializerSettings.TypeNameHandling = Newtonsoft.Json.TypeNameHandling.None;
                j.SerializerSettings.Converters.Add(
                    new Newtonsoft.Json.Converters.StringEnumConverter()
                );
            });

        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen(c =>
        {
            c.SchemaFilter<EnumSchemaFilter>();

            c.SwaggerDoc("v1.0", new OpenApiInfo { Title = "Main API v1.0", Version = "v1.0" });
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
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer",
                            },
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
                    builder
                        .AllowAnyHeader()
                        .AllowAnyMethod()
                        .SetIsOriginAllowed((host) => true)
                        .AllowCredentials();
                }
            )
        );
    }

    private void AddServiceOptions(IServiceCollection services)
    {
        var sendGridOptions = Configuration.GetSection("SendGrid").Get<SendGridOptions>();
        services.AddSingleton<SendGridOptions>(sendGridOptions!);

        var sqlOptions = Configuration.GetSection("Sql").Get<SqlServerOptions>();
        services.AddSingleton<SqlServerOptions>(sqlOptions!);

        var appleOptions = Configuration.GetSection("Apple").Get<AppleAuthOptions>();
        services.AddSingleton<AppleAuthOptions>(appleOptions!);

        var rsaOptions = Configuration.GetSection("Rsa").Get<RSAOptions>();
        services.AddSingleton<RSAOptions>(rsaOptions!);
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

    // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }
        else
        {
            app.UseExceptionHandler("/Error");
            app.UseHsts();
        }

        app.UseHttpsRedirection();
        app.UseDefaultFiles();
        app.UseStaticFiles();
        app.UseCookiePolicy();
        app.UseCors("CorsPolicy");

        app.UseRouting();

        app.UseAuthorization();
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapHub<RpgServerHub>("/Chat");
        });
    }
}

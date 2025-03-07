using Prodot.Patterns.Cqrs;

namespace RPGTableHelper.WebApi;

public class Program
{
    public static void Main(string[] args)
    {
        CreateHostBuilder(args).Build().Run();
    }

    private static IHostBuilder CreateHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureAppConfiguration(
                (context, config) =>
                {
                    var env = context.HostingEnvironment;
                    // Use user secrets only if not in test environment
                    if (env.IsEnvironment("E2ETest"))
                    {
                        var indexOfUserSecretsSource = config
                            .Sources.Select((source, index) => new { source, index })
                            .Where(
                                (t) =>
                                    t.source
                                        is Microsoft.Extensions.Configuration.Json.JsonConfigurationSource jsonconfigsource
                                    && jsonconfigsource.Path != null
                                    && jsonconfigsource.Path.Contains("secrets.json")
                            )
                            .FirstOptional();

                        if (indexOfUserSecretsSource.IsSome)
                        {
                            config.Sources.RemoveAt(indexOfUserSecretsSource.Get().index);
                        }
                    }
                }
            )
        .ConfigureLogging(
            opt =>
            {
                opt.AddConsole(options =>
                {
                    options.TimestampFormat = "dd.MM.yyyy HH:mm:ss ";
                });
            })
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>().UseUrls(urls: "http://*:5012");
            });
}

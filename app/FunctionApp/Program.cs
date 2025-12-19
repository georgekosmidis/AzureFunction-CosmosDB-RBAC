using FunctionApp.CosmosDb;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

const string COSMOSDB_ENDPOINT = "COSMOSDB_ENDPOINT";
const string COSMOSDB_KEY = "COSMOSDB_KEY";
var builder = new HostBuilder();

// Connect to an Azure App Configuration
//app.ConfigureAppConfiguration(builder =>
//{
//    string cs = Environment.GetEnvironmentVariable("ConnectionString");
//    builder.AddAzureAppConfiguration(cs);
//})

builder.ConfigureFunctionsWorkerDefaults();

builder.ConfigureServices(services =>
{
    //Read from config stores
    services.AddAzureAppConfiguration();

    services.AddLogging(loggingBuilder =>
    {
        loggingBuilder.AddFilter(level => true);
    });

    if (Environment.GetEnvironmentVariable(COSMOSDB_ENDPOINT) is null)
    {
        throw new NullReferenceException($"Environment variable {COSMOSDB_ENDPOINT} is null");
    }

    if (Environment.GetEnvironmentVariable(COSMOSDB_KEY) is not null)
    {
        services.AddLifeOnEarthServices(
            Environment.GetEnvironmentVariable(COSMOSDB_ENDPOINT)!,
            Environment.GetEnvironmentVariable(COSMOSDB_KEY)!
        );
    }
    else
    {
        services.AddLifeOnEarthServices(
            Environment.GetEnvironmentVariable(COSMOSDB_ENDPOINT)!
        );
    }
});

var app = builder.Build();

app.Run();app.Run();
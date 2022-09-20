using Azure.Identity;
using FunctionApp.CosmosDb.LifeOnEarthDatabase.HumansContainer;
using FunctionApp.CosmosDb.Services;
using Microsoft.Azure.Cosmos.Fluent;
using Microsoft.Extensions.DependencyInjection;

namespace FunctionApp.CosmosDb;

public static class DependencyInjection
{
    public static IServiceCollection AddLifeOnEarthServices(this IServiceCollection services, string cosmosDbEndpoint)
    {
        var cosmosClientBuilder = new CosmosClientBuilder(
            cosmosDbEndpoint,
            new DefaultAzureCredential()
        );

        return services.RegisterServices(cosmosClientBuilder);
    }

    public static IServiceCollection AddLifeOnEarthServices(this IServiceCollection services, string cosmosDbEndpoint, string? cosmosDbKey)
    {
        var cosmosClientBuilder = new CosmosClientBuilder(
            cosmosDbEndpoint,
            cosmosDbKey
        );

        return services.RegisterServices(cosmosClientBuilder);
    }

    private static IServiceCollection RegisterServices(this IServiceCollection services, CosmosClientBuilder cosmosClientBuilder)
    {
        return services
            .AddSingleton(sp => cosmosClientBuilder
                 .WithConnectionModeDirect()
                 .Build())
            .AddSingleton<ICosmosDbService, CosmosDbService>()
            .AddSingleton<IHumansService, HumansService>();
    }
}
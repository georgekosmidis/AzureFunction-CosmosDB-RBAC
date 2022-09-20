using Microsoft.Azure.Cosmos;

namespace FunctionApp.CosmosDb.Services;

public interface ICosmosDbService
{
    Container Container(string databaseName, string containerName);
    Task<bool> IsHealthy();
}
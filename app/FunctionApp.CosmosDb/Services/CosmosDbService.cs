using Microsoft.Azure.Cosmos;

namespace FunctionApp.CosmosDb.Services;
public class CosmosDbService : ICosmosDbService, IDisposable
{
    private readonly CosmosClient _dbClient;

    public CosmosDbService(CosmosClient dbClient) => _dbClient = dbClient;

    public Container Container(string databaseName, string containerName)
    {
        return _dbClient.GetContainer(databaseName, containerName);
    }

    public async Task<bool> IsHealthy()
    {
        var account = await _dbClient.ReadAccountAsync();

        return account.ReadableRegions.Count() >= 1;
    }

    public void Dispose()
    {
        _dbClient.Dispose();
    }
}
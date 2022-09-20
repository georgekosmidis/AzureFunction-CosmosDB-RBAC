using FunctionApp.CosmosDb.Services;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Linq;

namespace FunctionApp.CosmosDb.LifeOnEarthDatabase.HumansContainer;
public class HumansService : IHumansService
{
    private readonly Container container;

    public HumansService(ICosmosDbService cosmosDbService) => container = cosmosDbService.Container("EarthDatabase", "HumansContainer");

    public async Task<IEnumerable<HumanDto>> Get(string location, CancellationToken cancellationToken)
    {

        var serializer = new CosmosLinqSerializerOptions()
        {
            PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase
        };

        var result = new List<HumanDto>();

        using (var setIterator = container.GetItemLinqQueryable<HumanDto>(linqSerializerOptions: serializer)
                     .Where(b => b.Location == location)
                     .ToFeedIterator())
        {
            while (setIterator.HasMoreResults)
            {
                var response = await setIterator.ReadNextAsync(cancellationToken);

                //In this example we just copy to a list,
                //for larger resultsets though, you need to use continuation tokens
                // Read more: https://learn.microsoft.com/en-us/azure/cosmos-db/sql/sql-query-pagination
                result.AddRange(response);

            }
        }

        return result;
    }
}

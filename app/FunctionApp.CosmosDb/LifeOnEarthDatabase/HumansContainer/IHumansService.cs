namespace FunctionApp.CosmosDb.LifeOnEarthDatabase.HumansContainer;

public interface IHumansService
{
    Task<IEnumerable<HumanDto>> Get(string location, CancellationToken cancellationToken);
}
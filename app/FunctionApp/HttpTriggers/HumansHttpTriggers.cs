using FunctionApp.CosmosDb.LifeOnEarthDatabase.HumansContainer;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace FunctionApp.HttpTriggers;

public class HumansHttpTriggers
{
    private readonly ILogger _logger;
    private readonly IHumansService _humansService;

    public HumansHttpTriggers(IHumansService humansService, ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<HumansHttpTriggers>();
        _humansService = humansService;
    }

    [Function($"{nameof(Humans)}/{{location:alpha}}")]
    public async Task<IEnumerable<HumanDto>> Humans(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req,
        //CancellationToken cancellationToken, //not supported for out-of-proc
        FunctionContext executionContext,
        string location
       )
    {
        var cancellationToken = default(CancellationToken);

        _logger.LogInformation($"HTTP Trigger '{nameof(Humans)}' got a request for '{location}'.");
        return await _humansService.Get(location, cancellationToken);
    }
}

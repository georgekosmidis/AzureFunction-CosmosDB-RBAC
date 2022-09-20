using FunctionApp.CosmosDb.Services;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System.Net;

namespace FunctionApp.HttpTriggers;

public class HealthHttpTriggers
{
    private readonly ILogger _logger;
    private readonly ICosmosDbService _cosmosDbService;

    public HealthHttpTriggers(ICosmosDbService cosmosDbService, ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<HealthHttpTriggers>();
        _cosmosDbService = cosmosDbService;
    }

    [Function(nameof(Ping))]
    public HttpResponseData Ping([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
    {
        _logger.LogInformation($"HTTP Trigger '{nameof(Ping)}' got a request.");

        var response = req.CreateResponse(HttpStatusCode.OK);
        response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
        response.WriteString(DateTime.Now.ToString());

        return response;
    }

    [Function(nameof(Health))]
    public async Task<HttpResponseData> Health([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequestData req)
    {
        return await _cosmosDbService.IsHealthy() ? req.CreateResponse(HttpStatusCode.OK) : req.CreateResponse(HttpStatusCode.InternalServerError);
    }
}

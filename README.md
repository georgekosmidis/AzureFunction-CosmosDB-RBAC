
![Azure Deploy Build](https://github.com/georgekosmidis/AzureFunction-CosmosDB-RBAC/actions/workflows/BuildAzureDeploy.yml/badge.svg) ![Azure Function Build](https://github.com/georgekosmidis/AzureFunction-CosmosDB-RBAC/actions/workflows/BuildAndDeployWebApp.yml/badge.svg)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgeorgekosmidis%2FAzureFunction-CosmosDB-RBAC%2Fmain%2Fazuredeploy.json)

# An Azure Function connecting to a CosmosDB using RBAC

The sample contains an out-of-proc function app written in C# (.NET 6) and the supporting IaC written in bicep. 

## Infrastructure

The infrastructure is using the [BuildAzureDeploy.yml](https://github.com/georgekosmidis/AzureFunction-CosmosDB-RBAC/blob/main/.github/workflows/BuildAzureDeploy.yml) action to compile the [azuredeploy.json](/georgekosmidis/AzureFunction-CosmosDB-RBAC/blob/main/azuredeploy.json) that is being used in the blue '**Deploy to Azure**' button. All resources are deployed in their most cost effective pricing model, se feel free to play around.

The namings of all the resources are using the Resource Group `name` as prefix (e.g. `ResourceGroupName-webapp`) and are deployed to the location of the Resource Group ([not all locations support Azure CosmosDB](https://learn.microsoft.com/en-us/cli/azure/cosmosdb/locations?view=azure-cli-latest#az-cosmosdb-locations-list). 

> Keep your Resource Group `name` small and unique. If you can't, just give custom names to each resource. 

After a succesful deployment, here is what you will end up with

1. An **Azure Function**,
   Windows, .NET 6, out-of-proc)
2. An **Azure Storage**,
   for the Azure Function
3. An **Azure KeyVault**,
   for the Azure Storage Keys 
4. A **CosmosDB** with 
     * one **SQL Database** named 'EarthDatabase' 
     * a **Container** named 'HumansContainer'
     * a **PartitionKey** named '/location'
5. A **CosmosDB SQL Role Assignment**,
   with the Azure Function Principal ID
6. **Analytics Workspace** and **Application Insights**.

## Application

The Azure Function was build using Visual Studio and .NET 6 Isolated (out-of-proc). It connects to CosmosDB endpoint `COSMOSDB_ENDPOINT` which can be found in the Application Setting. During development (or debugging) the Application Setting `COSMOSDB_KEY` can be used to switch the authentication to a traditional connection string. 

If you want to deploy it, besides getting the publishing profile from the Overview tab of your Azure Function, remember the Resource Group `name` you gave! Your functions' name would be `ResourceGroupName-webapp`, and you will need to supply it to the Github Action BuildAndDeploy.yml when you decide to deploy!

The Function App contains 3 endpoints:

1. `api/Ping`, 
   that returns the current time
2. `api/Health`, 
   that connects to CosmosDB and returns true if there is at least one readable region
3. `api/Humans/{location}`, 
   that supposingly returns a list of name for the selected location (it doesn't unless you add some data!)

> Here is an object that you can copy paste as data:
> `{ location: 'Germany' }`
> Yeap, you only need one field for the test



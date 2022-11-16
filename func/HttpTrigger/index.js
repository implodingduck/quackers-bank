const { ContainerServiceClient } = require("@azure/arm-containerservice");
const { DefaultAzureCredential } = require("@azure/identity");

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const clusterIdArr = process.env.get('CLUSTER_ID').split("/")
    
    const subscriptionId = clusterIdArr[2];
    const resourceGroupName = clusterIdArr[4];
    const resourceName = clusterIdArr[8];
    const credential = new DefaultAzureCredential();
    const client = new ContainerServiceClient(credential, subscriptionId);
    const result = await client.managedClusters.get(resourceGroupName, resourceName);
    context.res = {
        // status: 200, /* Defaults to 200 */
        body: result
    };
}
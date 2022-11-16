const { ContainerServiceClient } = require("@azure/arm-containerservice");
const { DefaultAzureCredential } = require("@azure/identity");

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const clusterIdArr = process.env.CLUSTER_ID.split("/")
    
    const subscriptionId = clusterIdArr[2];
    const resourceGroupName = clusterIdArr[4];
    const resourceName = clusterIdArr[8];
    const credential = new DefaultAzureCredential();
    const client = new ContainerServiceClient(credential, subscriptionId);
    let result = await client.managedClusters.get(resourceGroupName, resourceName);
    const powerstate = result.powerState.code
    context.log(powerstate);
    if ( powerstate == 'Running'){
        context.log("Stopping...");
        await client.managedClusters.beginStop(resourceGroupName, resourceName);
        result = "Stopping..."
    }else{
        context.log("Starting...");
        await client.managedClusters.beginStart(resourceGroupName, resourceName);
        result = "Starting..."
    }
    context.res = {
        // status: 200, /* Defaults to 200 */
        body: result
    };
}
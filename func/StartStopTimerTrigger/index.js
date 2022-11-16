const { ContainerServiceClient } = require("@azure/arm-containerservice");
const { DefaultAzureCredential } = require("@azure/identity");

module.exports = async function (context, myTimer) {
    var timeStamp = new Date().toISOString();
    
    if (myTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }

    const clusterIdArr = process.env.CLUSTER_ID.split("/")
    
    const subscriptionId = clusterIdArr[2];
    const resourceGroupName = clusterIdArr[4];
    const resourceName = clusterIdArr[8];
    const credential = new DefaultAzureCredential();
    const client = new ContainerServiceClient(credential, subscriptionId);
    const result = await client.managedClusters.get(resourceGroupName, resourceName);
    console.log(result);
    context.log('JavaScript timer trigger function ran!', timeStamp);  

};
const { ContainerAppsAPIClient } = require("@azure/arm-appcontainers");
const { DefaultAzureCredential } = require("@azure/identity");
const { SecretClient } = require("@azure/keyvault-secrets");


module.exports = async function (context, req) {

    context.log('JavaScript HTTP trigger function processed a request.');
    const clusterIdArr = process.env.CLUSTER_ID.split("/")
    const subscriptionId = clusterIdArr[2];
    const resourceGroupName = clusterIdArr[4];
    const credentials = new DefaultAzureCredential();
    const acaclient = new ContainerAppsAPIClient(credentials, subscriptionId);
    const vaultUrl = process.env.VAULT_URL;
    const kvclient = new SecretClient(vaultUrl, credentials);
    const secretsList = process.env.SECRET_LIST.split(",");

    context.log('Getting secrets...');
    const acaSecrets = []
    for (let k of secretsList){
        context.log(`Getting ${k}...`);
        let s = await kvclient.getSecret(k);
        acaSecrets.push({
            name: k.toLowerCase(),
            value: s.value
        })
    }
 
    const acaList = ["aca-accounts-api", "aca-frontend", "aca-transactions-api"]
    const result = []
    for (let a of acaList){
        context.log(`getting ${a}...`);
        let containerAppEnvelope = await acaclient.containerApps.get(
            resourceGroupName,
            a
        )
        context.log(`syncing ${a}...`);
        containerAppEnvelope.configuration.secrets = acaSecrets;
        let r = await acaclient.containerApps.beginUpdate(
            resourceGroupName,
            a,
            containerAppEnvelope
        );
        result.push(r);

    }
    
    console.log(result);

    context.res = {
        // status: 200, /* Defaults to 200 */
        body: result
    };
}
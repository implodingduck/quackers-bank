const { ContainerAppsAPIClient } = require("@azure/arm-appcontainers");
const { DefaultAzureCredential } = require("@azure/identity");
import { SecretClient } from "@azure/keyvault-secrets";

const clusterIdArr = process.env.CLUSTER_ID.split("/")
const subscriptionId = clusterIdArr[2];
const resourceGroupName = clusterIdArr[4];
const acaclient = new ContainerAppsAPIClient(new DefaultAzureCredential(), subscriptionId);
const vaultUrl = process.env.VAULT_URL;
const kvclient = new SecretClient(vaultUrl, credentials);
const secretsList = process.env.SECRET_LIST.split(",");
module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');
    const acaSecrets = []
    for (let k of secretsList){
        let v = await kvclient.getSecret(k);
        acaSecrets.push({
            name: k,
            value: v
        })
    }

    const containerAppEnvelop = {
        configuration: {
            secrets: acaSecrets
        }
    }
    const result = await acaclient.containerApps.beginUpdate(
        resourceGroupName,
        "aca-accounts-api",
        containerAppEnvelop
      );
    console.log(result);

    context.res = {
        // status: 200, /* Defaults to 200 */
        body: result
    };
}
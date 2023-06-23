const appInsights = require("applicationinsights");
appInsights.setup().start(); // assuming connection string in env var. start() can be omitted to disable any non-custom data
const client = appInsights.defaultClient;


module.exports = async function (context, eventHubMessages) {
    context.log(`JavaScript eventhub trigger function called for message array ${eventHubMessages}`);

    eventHubMessages.forEach((message, index) => {
        context.log(`Processed message ${message}`);
        jsonmessage = JSON.parse(message)
        client.trackEvent({name: "ehloggerevent", properties: jsonmessage});
        try{
            
            context.log(`${jsonmessage["Type"]} vs ${jsonmessage.Type}`)
            if (jsonmessage["Type"] == "response"){
                context.log("I got a response event! Let me track it!")
                let trackedRequest = {
                    id: jsonmessage["requestIdHeader"],
                    name: `${jsonmessage["RequestMethod"]} ${jsonmessage["ApiPath"]}${jsonmessage["OperationUrl"]}`,
                    url: `https://${jsonmessage["servicename"]}${jsonmessage["ApiPath"]}${jsonmessage["OperationUrl"]}`,
                    success: true,
                    resultCode: jsonmessage["ResponseStatusCode"],
                    duration: jsonmessage["Duration"],
                }
                context.log(`tracking: ${trackedRequest}`);
                client.trackRequest(trackedRequest)
            }
        }catch(e){
            context.log(`Error not in your favor: ${e}`);
        }
        
    });
};
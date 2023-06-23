const appInsights = require("applicationinsights");
appInsights.setup().start(); // assuming connection string in env var. start() can be omitted to disable any non-custom data
const client = appInsights.defaultClient;


module.exports = async function (context, eventHubMessages) {
    context.log(`JavaScript eventhub trigger function called for message array ${eventHubMessages}`);

    eventHubMessages.forEach((message, index) => {
        context.log(`Processed message ${message}`);
        client.trackEvent({name: "ehloggerevent", properties: JSON.parse(message)});
        try{
            context.log(`${message["Type"]} vs ${message.Type}`)
            if (message["Type"] == "response"){
                context.log("I got a response event! Let me track it!")
                let trackedRequest = {
                    id: message["requestIdHeader"],
                    name: `${message["RequestMethod"]} ${message["ApiPath"]}${message["OperationUrl"]}`,
                    url: `https://${message["servicename"]}${message["ApiPath"]}${message["OperationUrl"]}`,
                    success: true,
                    resultCode: message["ResponseStatusCode"],
                    duration: message["Duration"],
                }
                context.log(`tracking: ${trackedRequest}`);
                client.trackRequest(trackedRequest)
            }
        }catch(e){
            context.log(`Error not in your favor: ${e}`);
        }
        
    });
};
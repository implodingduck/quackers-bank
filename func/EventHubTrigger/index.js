const appInsights = require("applicationinsights");
appInsights.setup().start(); // assuming connection string in env var. start() can be omitted to disable any non-custom data
const client = appInsights.defaultClient;


module.exports = async function (context, eventHubMessages) {
    context.log(`JavaScript eventhub trigger function called for message array ${eventHubMessages}`);

    eventHubMessages.forEach((message, index) => {
        context.log(`Processed message ${message}`);
        client.trackEvent({name: "ehloggerevent", properties: JSON.parse(message)});
    });
};
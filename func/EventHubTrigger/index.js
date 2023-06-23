const appInsights = require("applicationinsights");
appInsights.setup()
    .setAutoDependencyCorrelation(true)
    .setAutoCollectRequests(false)
    .setAutoCollectPerformance(false, false)
    .setAutoCollectExceptions(false)
    .setAutoCollectDependencies(false)
    .setAutoCollectConsole(false, false)
    .setUseDiskRetryCaching(false)
    .setAutoCollectPreAggregatedMetrics(false)
    .setSendLiveMetrics(false)
    .setAutoCollectHeartbeat(false)
    .setAutoCollectIncomingRequestAzureFunctions(true)
    .setDistributedTracingMode(appInsights.DistributedTracingModes.AI_AND_W3C)
    .enableWebInstrumentation(false)
    .start(); // assuming connection string in env var. start() can be omitted to disable any non-custom data
const client = appInsights.defaultClient;

module.exports = async function (context, eventHubMessages) {
    context.log(`JavaScript eventhub trigger function called for message array ${eventHubMessages}`);

    rewriteContext = function ( envelope, aicontext ) {
        context.log(`Envelope... ${JSON.stringify(envelope)}`)
        context.log(`BaseType... ${envelope.data.baseType}`)
        if(envelope.data.baseType == "RequestData"){
            context.log(`This is the evelope ${JSON.stringify(envelope)}`);
            context.log(`This is the context ${JSON.stringify(aicontext)}`);
            let requestIdHeader = envelope.baseData.properties.requestIdHeader
            if (requestIdHeader != null && requestIdHeader != ""){
                let operationAndSpanId = requestIdHeader.split('|')[1].split('.')
                let operationId = operationAndSpanId[0]
                let spanId = operationAndSpanId[1]
                               
                aicontext.correlationContext.operation.id = operationId
                aicontext.correlationContext.operation.parentId = requestIdHeader
                aicontext.correlationContext.operation.traceparent.parentId = requestIdHeader
                aicontext.correlationContext.operation.traceparent.spanId = spanId
                aicontext.correlationContext.operation.traceparent.traceId = operationId

                envelope.tags["ai.operation.parentId"] == requestIdHeader
                envelope.tags["ai.operation.operation.id"] == operationId

                context.log(`This is the evelope after: ${JSON.stringify(envelope)}`);
                context.log(`This is the context after: ${JSON.stringify(aicontext)}`);
            }
            
        }
        
        return true;
    }
      
    client.addTelemetryProcessor(rewriteContext);

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
                    properties: jsonmessage
                }
                
                context.log(`tracking: ${JSON.stringify(trackedRequest)}`);
                client.trackRequest(trackedRequest)
            }
        }catch(e){
            context.log(`Error not in your favor: ${e}`);
        }
        
    });
};
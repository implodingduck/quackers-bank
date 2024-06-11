module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    const name = (req.query.name || (req.body && req.body.name));
    const delay = (req.query.delay || (req.body && req.body.delay));
    const delayMS = delay ? parseInt(delay) * 1000 : 1000
    if(isNaN(deplayMS)){
        context.res = {
            status: 400,
            body: "The delay parameter must be a number"
        };
        return;
    }
    const responseMessage = name
        ? "Hello, " + name + ". This HTTP triggered function executed successfully... with a delay of " + delayMS + " ms"
        : "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response... with a delay of " + delayMS + " ms";

    context.log('Starting the pause...');
    
    await new Promise(resolve => setTimeout(resolve, delayMS));
    context.log('Ending the pause...');
    context.res = {
        // status: 200, /* Defaults to 200 */
        body: responseMessage
    };
}
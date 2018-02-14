import ballerina.net.http;
import ballerina.log;

const string secret = "aqwsdfertg1248sjn"; //hardcoded for demonstration

function main (string [] args)  {
    //where args[0] = the hub URL identified in discovery, args[1] = the topic URL identified in discovery,
    // args[2] = the callback URL you want to receive notifications at
    string[] subscriptionParams = [args[0], "subscribe", args[1], args[2]];
    subscribe(subscriptionParams);
}

function subscribe (string[] subscriptionParams) {
    endpoint<http:HttpClient> hubEP {
        create http:HttpClient(subscriptionParams[0], {});
    }
    http:OutRequest request = {};
    http:InResponse response = {};
    http:HttpConnectorError err;
    string body = "hub.mode=" + subscriptionParams[1]
                  + "&hub.topic=" + subscriptionParams[2]
                  + "&hub.callback=" + subscriptionParams[3]
                  + "&hub.secret=" + secret;
    request.setStringPayload(body);
    request.setHeader("Content-Type", "application/x-www-form-urlencoded");
    response, err = hubEP.post("/", request);

    string payload = response.getStringPayload();
    if (response.statusCode != 202) {
        log:printError("Error occurred subscribing " + payload);
    } else {
        log:printInfo("Subscription successful!");
    }
}

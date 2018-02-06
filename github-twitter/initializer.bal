import ballerina.net.http;

function main (string[] args) {
    endpoint<http:HttpClient> githubTwitterWebhookEndpoint {
        create http:HttpClient("http://localhost:9090/githubTwitterWebhook", {});
    }
    http:Response resp = {};

    http:Request initializeRequest = {};
    initializeRequest.setJsonPayload({consumerKey:args[0], consumerSecret:args[1], accessToken:args[2], accessTokenSecret:args[3]});
    resp, _ = githubTwitterWebhookEndpoint.post("/initialize", initializeRequest);
}

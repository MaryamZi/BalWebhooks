import ballerina.net.http;
import ballerina.log;
import ballerina.security.crypto;

const string secret = "aqwsdfertg1248sjn";
const string X_HUB_UUID = "X-GitHub-Event";
const string X_HUB_TOPIC = "X-GitHub-Delivery";
const string X_HUB_SIGNATURE = "X-Hub-Signature";

@http:configuration {basePath:"/githubWebhook"}
service<http> githubWebhook {

    @http:resourceConfig {
        methods:["POST"],
        path:"/listener"
    }
    resource webhookListener (http:Connection connection, http:InRequest request) {
        println("HEADER: X-GitHub-Event --> " + request.getHeader("X-GitHub-Event"));
        println("HEADER: X-GitHub-Delivery --> " + request.getHeader("X-GitHub-Delivery"));
        if (request.getHeader("X-Hub-Signature") != null) {
            println("HEADER: X-Hub-Signature --> " + request.getHeader("X-Hub-Signature"));
        }
        boolean successful;
        ParsedRequest parsedRequest;
        successful, parsedRequest = parseWebhookRequest(request);
        if (successful) {
            log:printInfo("Webhook Listener received payload: " + parsedRequest.payload.toString());
        } else {
            log:printError("Error parsing Webhook request");
        }
        json jsonMsg = request.getJsonPayload();
        println(jsonMsg);
        http:OutResponse res = {};
        res.statusCode = 202;
        _ = connection.respond(res);
    }

}

function parseWebhookRequest(http:InRequest request) (boolean, ParsedRequest) {
    ParsedRequest parsedRequest = {};
    string signature;
    json jsonPayload;
    if (secret != null && request.getHeader(X_HUB_SIGNATURE) == null) {
        log:printError(X_HUB_SIGNATURE + " header not present for subscription added specifying hub.secret");
        return false, parsedRequest;
    } else if (secret == null) {
        if (request.getHeader(X_HUB_SIGNATURE) != null) {
            log:printWarn("Ignoring " + X_HUB_SIGNATURE + " value since secret is not specified.");
        }
    } else {
        string xHubSignature = (string) request.getHeader(X_HUB_SIGNATURE);
        string[] splitSignature = xHubSignature.split("=");
        string method;
        method = splitSignature[0];
        signature = xHubSignature.replace(method + "=", "");
        string generatedSignature = null;
        //Assumes JSON payload - needs to be changed if other content types allowed
        jsonPayload = request.getJsonPayload();
        //Converted to string for HMAC computation
        string stringPayload = jsonPayload.toString();
        string sha1 = "SHA1";
        string sha256 = "SHA256";
        string md5 = "MD5";
        if (sha1.equalsIgnoreCase(method)) { //not recommended
            generatedSignature = crypto:getHmac(stringPayload, secret, crypto:Algorithm.SHA1);
        } else if (sha256.equalsIgnoreCase(method)) {
            generatedSignature = crypto:getHmac(stringPayload, secret, crypto:Algorithm.SHA256);
        } else if (md5.equalsIgnoreCase(method)) {
            generatedSignature = crypto:getHmac(stringPayload, secret, crypto:Algorithm.MD5);
        } else {
            log:printError("Unsupported signature method: " + method);
            return false, parsedRequest;
        }
        if (!signature.equalsIgnoreCase(generatedSignature)) {
            println("Signature: " + signature);
            println("Generated Signature: " + generatedSignature);
            log:printError("Signature verification failed.");
            return false, parsedRequest;
        }
    }
    WebhookHeaders webhookHeaders = {xHubUuid:(string) request.getHeader(X_HUB_UUID),
                                        xHubTopic:request.getHeader(X_HUB_TOPIC), xHubSignature:signature};
    parsedRequest = {webhookHeaders:webhookHeaders, payload:jsonPayload};
    return true, parsedRequest;
}

struct ParsedRequest {
    WebhookHeaders webhookHeaders;
    json payload;
}

struct WebhookHeaders {
    string xHubUuid;
    string xHubTopic;
    string xHubSignature;
}
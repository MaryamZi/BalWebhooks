import ballerina.log;
import ballerina.net.http;
import ballerina.security.crypto;

const string secret = "aqwsdfertg1248sjn"; //Hard coded for demonstration
const string X_HUB_UUID = "X-Hub-Uuid";
const string X_HUB_TOPIC = "X-Hub-Topic";
const string X_HUB_SIGNATURE = "X-Hub-Signature";

@http:configuration {
    basePath:"/subscriber",
    port:9090
}
service<http> webhookListener {

    @http:resourceConfig {
        methods:["POST", "GET"],
        path:"/listener"
    }
    resource webhookListener (http:Connection connection, http:InRequest request) {
        http:OutResponse response = {};
        map params = request.getQueryParams();
        var challenge, _ = (string) params["hub.challenge"];

        if (challenge != null) {
            response = verifyIntent(request);
        } else {
            boolean successful;
            ParsedRequest parsedRequest;
            successful, parsedRequest = parseWebhookRequest(request);
            if (successful) {
                response.statusCode = 202;
                log:printInfo("Webhook Listener received payload: " + parsedRequest.payload.toString());
            } else {
                //set an error code
                response.statusCode = 400;
                log:printError("Error parsing Webhook request");
            }
        }
        _ = connection.respond(response);
    }
}

function verifyIntent(http:InRequest request) (http:OutResponse) {
    http:OutResponse response = {};
    boolean verified = false;
    map params = request.getQueryParams();
    var challenge, _ = (string) params["hub.challenge"];
    var mode, _ = (string) params["hub.mode"];
    if (mode == null) {
        verified = false;
    } else {
        //TODO: We need to check against pending subscription requests first
        verified = true;
    }

    if (verified) {
        string body = challenge;
        response.setStringPayload(body);
        response.statusCode = 202;
    } else {
        response.statusCode = 404;
    }
    return response;
}

function parseWebhookRequest(http:InRequest request) (boolean, ParsedRequest) {
    ParsedRequest parsedRequest = {};
    string signature;
    json jsonPayload; //assumes content type to be json
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
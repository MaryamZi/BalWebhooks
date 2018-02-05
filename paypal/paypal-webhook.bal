import ballerina.net.http;

@http:configuration {basePath:"/paypalWebhook"}
service<http> paypalWebhook {

    @http:resourceConfig {
        methods:["POST"],
        path:"/listener"
    }
    resource webhookListener (http:Connection connection, http:InRequest request) {
        if (request.getHeader("PAYPAL-CERT-URL") == null) {
            error err = {msg:"Request supposedly from PayPal does not contain PAYPAL-CERT-URL"};
            throw err;
        }
        json jsonMsg = request.getJsonPayload();
        println(jsonMsg);
        http:OutResponse res = {};
        res.statusCode = 202;
        _ = connection.respond(res);
    }

}

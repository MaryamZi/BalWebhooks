import ballerina.net.http;

@http:configuration {
    basePath:"/vehicleRegWebhook",
    port:9091
}
service<http> vehicleRegistrationWebhookListener {

    @http:resourceConfig {
        methods:["POST"],
        path:"/listener"
    }
    resource webhookListener (http:Connection connection, http:InRequest request) {
        json jsonMsg = request.getJsonPayload();
        println("Webhook Listener received notification");
        println(jsonMsg);
        http:OutResponse res = {};
        res.statusCode = 202;
        _ = connection.respond(res);
    }

}

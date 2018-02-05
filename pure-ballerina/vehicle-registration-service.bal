import ballerina.net.http;

@http:configuration {
    basePath:"/vehicleReg",
    port:9090
}
service<http> vehicleRegistrationService {

    int webhookUrlIndex = 0;
    string[] webhookUrls = [];

    @http:resourceConfig {
        methods:["POST"],
        path:"/registerWebhook"
    }
    resource registerWebhook (http:Connection connection, http:InRequest request) {
        json jsonMsg = request.getJsonPayload();
        println(jsonMsg);
        webhookUrls[webhookUrlIndex], _ = (string) jsonMsg["url"];
        webhookUrlIndex = webhookUrlIndex + 1;
        http:OutResponse res = {};
        res.statusCode = 202;
        _ = connection.respond(res);
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/registerVehicle"
    }
    resource registerVehicle (http:Connection connection, http:InRequest request) {
        endpoint<http:HttpClient> httpEndpoint {
            create http:HttpClient("http://localhost:", {});
        }
        json jsonMsg = {event:"Registered Vehicle", payload:request.getStringPayload()};
        println(jsonMsg);

        http:OutRequest req = {};
        http:InResponse resp = {};
        req.setJsonPayload(jsonMsg);

        foreach url in webhookUrls {
            resp, _ = httpEndpoint.post(url, req);
            if(resp.statusCode != 202) {
                println("Error occured for Webhook URL: " + url + " - " + resp.statusCode);
            }
        }
        http:OutResponse res = {};
        res.statusCode = 202;
        _ = connection.respond(res);
    }
}

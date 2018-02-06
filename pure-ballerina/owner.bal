import ballerina.net.http;

function main(string[] args) {
    endpoint<http:HttpClient> vehicleRegEndpoint {
        create http:HttpClient("http://localhost:9090/vehicleReg", {});
    }
    http:InResponse resp = {};

    http:OutRequest regRequest = {};
    regRequest.setJsonPayload({url:"9091/vehicleRegWebhook/listener"});
    resp, _ = vehicleRegEndpoint.post("/registerWebhook", regRequest);
    regRequest.setJsonPayload({url:"9091/vehicleRegWebhookInvalid/listener"});
    resp, _ = vehicleRegEndpoint.post("/registerWebhook", regRequest);

    string vehicleNumber = "0123";
    http:OutRequest req = {};
    req.setStringPayload("Register Vehicle: " + vehicleNumber);
    resp, _ = vehicleRegEndpoint.post("/registerVehicle", req);
}
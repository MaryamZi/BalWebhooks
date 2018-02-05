import ballerina.net.http;

@http:configuration {basePath:"/githubWebhook"}
service<http> githubWebhook {

    @http:resourceConfig {
        methods:["POST"],
        path:"/listener"
    }
    resource webhookListener (http:Connection connection, http:InRequest request) {
        println("HEADER: X-GitHub-Event --> " + request.getHeader("X-GitHub-Event").value);
        println("HEADER: X-GitHub-Delivery --> " + request.getHeader("X-GitHub-Delivery").value);
        if (request.getHeader("X-Hub-Signature") != null) {
            println("HEADER: X-Hub-Signature --> " + request.getHeader("X-Hub-Signature").value);
        }
        json jsonMsg = request.getJsonPayload();
        println(jsonMsg);
        http:OutResponse res = {};
        res.statusCode = 202;
        _ = connection.respond(res);
    }

}
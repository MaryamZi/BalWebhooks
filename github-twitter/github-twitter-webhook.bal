import org.wso2.ballerina.connectors.twitter;
import ballerina.net.http;

@http:configuration {basePath:"/githubTwitterWebhook"}
service<http> githubWebhook {

    string consumerKey;
    string consumerSecret;
    string accessToken;
    string accessTokenSecret;

    @http:resourceConfig {
        methods:["POST"],
        path:"/initialize"
    }
    resource initialize (http:Request request, http:Response response) {
        json jsonMsg = request.getJsonPayload();
        consumerKey, _ = (string) jsonMsg["consumerKey"];
        consumerSecret, _ = (string) jsonMsg["consumerSecret"];
        accessToken, _ = (string) jsonMsg["accessToken"];
        accessTokenSecret, _ = (string) jsonMsg["accessTokenSecret"];
        _ = response.send();
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/listener"
    }
    resource webhookListener (http:Request request, http:Response response) {
        endpoint<twitter:ClientConnector> twitterConnector {
            create twitter:ClientConnector(consumerKey, consumerSecret, accessToken, accessTokenSecret);
        }
        json jsonGithubMsg = request.getJsonPayload();
        println(jsonGithubMsg);
        string issueTitle;
        issueTitle, _ = (string) jsonGithubMsg["issue"]["title"];

        http:Response tweetResponse = {};
        http:HttpConnectorError e;
        json tweetJSONResponse;
        tweetResponse, e = twitterConnector.tweet(issueTitle);
        if(e == null) {
            tweetJSONResponse = tweetResponse.getJsonPayload();
            println(tweetJSONResponse.toString());
        } else {
            println(e);
        }
        response.setStatusCode(202);
        _ = response.send();
    }

}

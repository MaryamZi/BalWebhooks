import ballerina.data.sql;
import ballerina.log;
import ballerina.net.http;
import ballerina.util;

const string MODE_SUBSCRIBE = "subscribe";
const string MODE_UNSUBSCRIBE = "unsubscribe";
const int DEFAULT_LEASE_SECONDS_VALUE = 86400;

map pendingSubscriptionRequests = {};
map pendingUnsubscriptionRequests = {};

@http:configuration {
    basePath:"/hub",
    port:9092
}
service<http> hub {

    @http:resourceConfig {
        methods:["POST"],
        path:"/changeSubscription"
    }
    resource subscribe (http:Connection connection, http:InRequest request) {
        map params = request.getFormParams();
        boolean validSubscriptionRequest = validateSubscriptionRequest(params);

        http:OutResponse response = {};
        if (!validSubscriptionRequest) {
            response.statusCode = 400;
        } else {
            response.statusCode = 202;
        }
        _ = connection.respond(response);
        if (validSubscriptionRequest) {
            var callbackUrl, _ = (string) params["hub.callback"];
            verifySubscription(callbackUrl, params);
        }
    }


}

struct PendingSubscription {
    string topic;
    string callback;
}

function validateSubscriptionRequest(map params) (boolean) {
    var mode, _ = (string) params["hub.mode"];
    var topic, _ = (string) params["hub.topic"];
    var callbackUrl, _ = (string) params["hub.callback"];

    if (mode == MODE_SUBSCRIBE || mode == MODE_UNSUBSCRIBE) {
        if (topic != null && callbackUrl != null) {
            PendingSubscription pendingSubscription = { topic : topic, callback : callbackUrl };
            if (mode == MODE_SUBSCRIBE) {
                pendingSubscriptionRequests[topic + callbackUrl] = pendingSubscription;
            } else {
                pendingUnsubscriptionRequests[topic + callbackUrl] = pendingSubscription;
            }
            return true;
        }
    }
    return false;
}

function verifySubscription(string  callbackUrl, map params) {
    endpoint<http:HttpClient> callbackEP {
        create http:HttpClient(callbackUrl, {});
    }
    endpoint<sql:ClientConnector> subscriptionDB {
        create sql:ClientConnector(
        sql:DB.MYSQL, "localhost", 3306, "subscriptiondb", "wso2", "wso2", {maximumPoolSize:5});
    }

    var mode, _ = (string) params["hub.mode"];
    var topic, _ = (string) params["hub.topic"];
    var secret, _ = (string) params["hub.secret"];
    var leaseSeconds, _ = (int) params["hub.lease_seconds"];

    //measured from the time the verification request was made from the hub to the subscriber from the recommendation
    int createdAt = currentTime().time;

    if (!(leaseSeconds > 0)) {
        leaseSeconds = DEFAULT_LEASE_SECONDS_VALUE;
    }
    string challenge = util:uuid();

    http:OutRequest request = {};
    http:InResponse response = {};
    string queryParams = "hub.mode=" + mode
                  + "&hub.topic=" + topic
                  + "&hub.challenge=" + challenge
                  + "&hub.lease_seconds=" + leaseSeconds;

    response, _ = callbackEP.get("?" + queryParams, request);

    string payload = response.getStringPayload();
    string key = topic + callbackUrl;
    if (payload != challenge) {
        log:printInfo("Intent verification failed for mode: [" + mode + "], for callback URL: [" + callbackUrl
                      + "]");
    } else {
        sql:Parameter[] sqlParams = [];
        sql:Parameter para1 = {sqlType:sql:Type.VARCHAR, value:topic};
        sql:Parameter para2 = {sqlType:sql:Type.VARCHAR, value:callbackUrl};
        sql:Parameter para3 = {sqlType:sql:Type.VARCHAR, value:secret};
        sql:Parameter para4 = {sqlType:sql:Type.BIGINT, value:leaseSeconds};
        sql:Parameter para5 = {sqlType:sql:Type.BIGINT, value:createdAt};

        int ret; //TODO: take action based on ret value
        sqlParams = [para1, para2, para3, para4, para5, para3, para4, para5];
        if (mode == MODE_SUBSCRIBE) {
            ret = subscriptionDB.update("INSERT INTO subscriptions (topic,callback,secret,lease_seconds,created_at) "
                                        + "VALUES (?,?,?,?,?) ON DUPLICATE KEY UPDATE secret=?, lease_seconds=?,"
                                          + "created_at=?", sqlParams);
        } else {
            ret = subscriptionDB.update("DELETE FROM subscriptions WHERE topic=? AND callback=?", sqlParams);
        }
        log:printInfo("Intent verification successful for mode: [" + mode + "], for callback URL: ["
                      + callbackUrl + "]");
    }
    if (mode == MODE_SUBSCRIBE) {
        pendingSubscriptionRequests.remove(key);
    } else {
        pendingUnsubscriptionRequests.remove(key);
    }

}
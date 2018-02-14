1. GET/HEAD the publisher of the interested resource to identify the hub and topic URL
For example
 ```html
Link: <HUB_URL>; rel="hub", <TOPIC_URL>; rel="self"
```

2. Start up the [webhook-listener](webhook-listener.bal) service
```cmd
$ ballerina run webhook-listener.bal
ballerina: deploying service(s) in 'webhook-listener.bal'
ballerina: started HTTP/WS server connector 0.0.0.0:9090
```

3. Install [ngrok](https://ngrok.com/download) and expose the service running on localhost to the internet:
```cmd
$ ./ngrok http 9090
```
Identify the webhook listener URL: <ngrok_url>/subscriber/listener

4. Subscribe by running the [subscribe](subscribe.bal) Ballerina program, specifying the hub URL and topic URLs 
identified in discovery in 1 and the callback URL identified in 2 above.
```cmd
$ ballerina run subscribe.bal <HUB_URL> <TOPIC_URL> <CALLBACK_URL>
2018-02-13 22:43:06,046 INFO  [] - Subscription successful! 
```
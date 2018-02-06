This sample looks at a pure Ballerina usecase for webhooks.

**Note:** 
 * This sample does not allow specifying what event(s) to subscribe to (only has a single event for which notification 
 will be done to all registered webhook listeners)
 * Notification is not done asynchronously 

For demonstration purposes two services are introduced:
* [vehicle-registration-service](vehicle-registration-service.bal) - exposed on port 9090, a mock vehicle registration 
service which allows two functions, namely registering vehicles and registering webhooks
* [vehicle-registration-webhook-listener](vehicle-registration-webhook-listener.bal) - exposed on port 9091, a mock 
webhook endpoint/listener, with a resource whose URL will be specified as the URL for a webhook registered for the 
vehicle registration service

A helper Ballerina program, [owner](owner.bal) is also introduced to initially register two webhooks, one with a valid 
URL and the other with an invalid URL, after which a vehicle is registered, which should result in a POST request to the 
 URLs specified when registering the webhooks.

*Notification to the valid URL should be successful, while the notification to the invalid URL should fail*


1. Run the vehicle-registration-service.bal program
```cmd
$ ballerina run vehicle-registration-service.bal
ballerina: deploying service(s) in 'vehicle-registration-service.bal'
ballerina: started HTTP/WS server connector 0.0.0.0:9090
```

2. Run the vehicle-registration-webhook-listener.bal program
```cmd
$ ballerina run vehicle-registration-webhook-listener.bal
ballerina: deploying service(s) in 'vehicle-registration-webhook-listener.bal'
ballerina: started HTTP/WS server connector 0.0.0.0:9091
```

3. Run the owner.bal program to register the webhook and then register a vehicle.
 
The following output should be observed:

i. for vehicle-registration-service
```cmd
{"url":"9091/vehicleRegWebhook/listener"}
{"url":"9091/vehicleRegWebhookInvalid/listener"}
{"event":"Registered Vehicle","payload":"Register Vehicle: 0123"}
Error occured for Webhook URL: 9091/vehicleRegWebhookInvalid/listener - 404
```

ii. for vehicle-registration-webhook-listener
```cmd
Webhook Listener received notification
{"event":"Registered Vehicle","payload":"Register Vehicle: 0123"}
no matching service found for path : /vehicleRegWebhookInvalid/listener
```
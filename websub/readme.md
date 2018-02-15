1. GET/HEAD the publisher of the interested resource to identify the hub and topic URL
For example
 ```html
Link: <HUB_URL>; rel="hub", <TOPIC_URL>; rel="self"
```

To test/check the subscription process locally the simple [webhook-manager](webhook-manager.bal) can be used
```cmd
$ ballerina run webhook-manager.bal
ballerina: deploying service(s) in 'webhook-manager.bal'
ballerina: started HTTP/WS server connector 0.0.0.0:9092
```
The HUB_URL would then be - http://0.0.0.0:9092/hub/changeSubscription
Since the hub uses a MySQL database you would have to:
 - Copy the MySQL JDBC Driver to the BALLERINA_HOME/bre/lib folder
 - Create the database and required tables
```mysql-psql
create database subscriptiondb;
use subscriptiondb;
create table subscriptions(topic varchar(255) not null, callback varchar(255) not null, secret varchar(255) not null, 
lease_seconds bigint not null, created_at bigint not null, primary key (topic, callback));
grant all on subscriptiondb to 'wso2'@localhost identified by 'wso2';
```

2. Start up the [webhook-listener](webhook-listener.bal)
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

This step can be skipped if the subscription process is being tested locally.
The webhook listener URL would simply be: http://0.0.0.0:9090/subscriber/listener

4. Subscribe by running the [subscribe](subscribe.bal) Ballerina program, specifying the hub URL and topic URLs 
identified in discovery in 1 and the callback URL identified in 2 above.
```cmd
$ ballerina run subscribe.bal <HUB_URL> <TOPIC_URL> <CALLBACK_URL>
2018-02-13 22:43:06,046 INFO  [] - Subscription successful! 
```
The webhook-listener should receive an intent verification request from the hub.
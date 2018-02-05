1. Run the program
```cmd
$ ballerina run paypal-webhook.bal
ballerina: deploying service(s) in 'paypal-webhook.bal'
ballerina: started HTTP/WS server connector 0.0.0.0:9090
```

2. Install [ngrok](https://ngrok.com/download) and expose the service running on localhost to the internet:
```cmd
$ ./ngrok http 9090
```

3. [Add a PayPal webhook](https://developer.paypal.com/docs/integration/direct/webhooks/rest-webhooks/#configure-a-webhook-listener) pointing to the particular URL:
```
Payload URL: <ngrok_url>/githubWebhook/listener
```

4. You can now test the webhook by simulating webhook events. In this sample we confirm that the `PAYPAL-CERT-URL` header 
 exists for requests originating from PayPal, prior to logging the payload.
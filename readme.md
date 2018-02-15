This project contains the following samples written in Ballerina for webhooks:

1. [github](github) - this sample demonstrates a simple webhook listener in Ballerina which prints the special webhook 
headers and the payload, on webhook notifications from GitHub, for issue creation or comments on issues

2. [paypal](paypal) - this sample, similar to the [github](github) sample, verifies that the payload is from PayPal by 
checking for a particular PayPal header (for demonstration purposes), prior to printing the payload


3. [github-twitter](github-twitter) - this sample demonstrates a simple integration of GitHub webhooks and Twitter using 
Ballerina, where a Ballerina webhook listener uses the Ballerina twitter-connector to tweet the issue title on 
notification for the webhook that an issue is created or a comment is added to an issue, in the repository the webhook 
was added for

4. [pure-ballerina](pure-ballerina) - this sample looks at a pure Ballerina usecase where the "webhook" is registered 
for a Ballerina service, and the "webhook listener" is also a Ballerina service

5. [websub](websub) - this sample looks at a WebSub subscription/subscriber in Ballerina along with a simple webhook-manager 
(hub) which accepts subscription requests and does the verification of intent for pending subscription requests.
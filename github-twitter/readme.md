This sample looks at a scenario where we tweet out the issue title on all new issue creations or comments on issues on a
 particular GitHub repository.

**Note:** 
 * This sample is based on ballerina 0.95.3 and the [ballerina twitter-connector](https://github.com/ballerina-lang/connector-twitter) 0.95.0 and will 
 be updated to the latest versions as and when available.
 * Currently the tweet is the issue title and would need to be tested with different issues when re-testing since the 
 same content cannot be tweeted consecutively
 
This sample consists of two Ballerina programs:

i. [github-twitter-webhook](github-twitter-webhook.bal) - a service exposed on port 9090 which allows initializing the 
parameters required for the Twitter connector and also introduces a webhook listener resource whose URL needs to be 
specified when registering the webhook

ii. [initializer](initializer.bal) which uses specified command line arguments and sets required values for the Twitter 
connector


1. Create a [Twitter app](https://apps.twitter.com/) and generate the following parameters:
   * Consumer Key
   * Consumer Secret
   * Access Token
   * Access Token Secret

2. Run github-twitter-webhook
```cmd
$ ballerina run github-twitter-webhook.bal
ballerina: deploying service(s) in 'github-twitter-webhook.bal'
ballerina: started HTTP/WS server connector 0.0.0.0:9090
```

3. Run initializer with required parameter
```cmd
./ballerina run initializer.bal <consumerKey> <consumerSecret> <accessToken> <accessTokenSecret>
```

4. Install [ngrok](https://ngrok.com/download) and expose the service running on localhost to the internet:
```cmd
$ ./ngrok http 9090
```

5. [Add a webhook](https://developer.github.com/webhooks/creating/_) to a GitHub repository, which you have admin access
 to.
 
     <GITHUB_REPO> → Settings → Webhooks → Add webhook and specify:
     
    i. Payload URL: <ngrok_url>/githubWebhook/listener
    
    ii.  Content type: application/json
    
    iii. Select “Which events would you like to trigger this webhook?”
     * For example select “Let me select individual events.”
     * Select “Issues” and “Issue Comments”
     * Tick “Active” to mark the webhook as active
     * Add webhook

6. You can now test the webhook by creating an issue, and adding comments on the issue. 
You should observe:
 * a tweet sent out "<Issue_Title>"
 * payload from Twitter or the error, if an error occurred, will be logged
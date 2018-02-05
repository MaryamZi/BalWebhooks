1. Run the program
```cmd
$ ballerina run github-webhook.bal
ballerina: deploying service(s) in 'github-webhook.bal'
ballerina: started HTTP/WS server connector 0.0.0.0:9090
```

2. Install [ngrok](https://ngrok.com/download) and expose the service running on localhost to the internet:
```cmd
$ ./ngrok http 9090
```

3. [Add a webhook](https://developer.github.com/webhooks/creating/_) to a GitHub repository, which you have admin access
 to.
 
     <GITHUB_REPO> → Settings → Webhooks → Add webhook and specify:
     
    i. Payload URL: <ngrok_url>/githubWebhook/listener
    
    ii.  Content type: application/json
    
    iii. Select “Which events would you like to trigger this webhook?”
     * For example select “Let me select individual events.”
     * Select “Issues” and “Issue Comments”
     * Tick “Active” to mark the webhook as active
     * Add webhook

4. You can now test the webhook by creating an issue, and adding comments on the issue. (In this example the entire 
payload is printed in addition to the headers)
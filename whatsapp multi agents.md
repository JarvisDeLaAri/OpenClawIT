after connecting the whatsapp channel the default should be all messages to main agent.

BUT sometimes we want our OPENCLAW INSTANCE to be connected to device X with number Y, and let multiple people to chat from their devices with number Y, each talking to another agent.

that is why we need bindings like that. note that in this example agent `wa-listener-general-bot` is a default bot to accept all other messages, but is not nessecary

```
  "bindings": [
    {
      "agentId": "main",
      "match": {
        "channel": "whatsapp",
        "peer": {
          "kind": "direct",
          "id": "+9725545451"
        }
      }
    },
    {
      "agentId": "anotherbot",
      "match": {
        "channel": "whatsapp",
        "peer": {
          "kind": "direct",
          "id": "+97295495491"
        }
      }
    },
    {
      "agentId": "wa-listener-general-bot",
      "match": {
        "channel": "whatsapp",
        "accountId": "*"
      }
    }
  ],
```

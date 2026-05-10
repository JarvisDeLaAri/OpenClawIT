# data and metadata from openclaw life cycle event


tested with Whatsapp & openclaw-control-ui (web dashboard GUI)

## main conclusion

messages from GUI chat always has `event.senderId` and `ctx.senderId` equal to `openclaw-control-ui`.

```
const VIP_PHONES = ["+972542634114"];
const VIP_AGENTS: string[] = ["main"];

function isVIP(event: unknown): boolean {
    const e = event as any;
    if (e?.senderId && VIP_PHONES.includes(e.senderId)) return true;
    if (typeof e?.sessionKey === "string") {
        const match = e.sessionKey.match(/^agent:(.+)/);
        if (match && VIP_AGENTS.includes(match[1])) return true;
    }
    return false;
}
```


## session start
only at start of a session

```
event:{
  sessionId: 'c774f9e8-f2d9-44b4-a5e1-f8e8a3ff0120',
  sessionKey: 'agent:maximus:main',
  resumedFrom: '66a924fc-a30a-451c-b117-d735f801481b'
}
```

```
ctx:{
  sessionId: 'c774f9e8-f2d9-44b4-a5e1-f8e8a3ff0120',
  sessionKey: 'agent:maximus:main',
  agentId: 'maximus'
}
```



# WHATSAPP

## message_received

`api.on("message_received", (event, ctx) => {`...

```
event: {
  //full sender phone number
  from: '+972542634114',
  senderId: '+972542634114',

  //standard openclaw full session key 
  sessionKey: 'agent:ariel-admin:whatsapp:direct:+972542634114',

  //generic
  content: 'sender message content',
  timestamp: 1778443749000,
  messageId: '3EB0021B26850A9E399CB3',

  metadata: {
    //reciever phone number, should be same for self
    to: '+972...',

    //full sender phone number
    originatingTo: '+972542634114',
    senderId: '+972542634114',
    senderE164: '+972542634114',

    //channel
    provider: 'whatsapp',
    surface: 'whatsapp',
    originatingChannel: 'whatsapp',

    //generic
    messageId: '3EB0021B26850A9E399CB3',
    senderName: 'Bresleveloper Ai',
  }
}
```

```
ctx:{
  //always the accountId for whatsapp unless specifically connected multiple phones
  accountId: 'default',

  //conversationId in message_received is sender, in before_dispatch is responder
  conversationId: '+972542634114',
  senderId: '+972542634114'

  channelId: 'whatsapp',
  sessionKey: 'agent:ariel-admin:whatsapp:direct:+972542634114',
  messageId: '3EB0021B26850A9E399CB3',
}
```


## before_dispatch

`api.on("before_dispatch", (event, ctx) => {`...

```
event:{
  //sender message content
  content: '...',
  body:    '...',
  channel: 'whatsapp',
  sessionKey: 'agent:ariel-admin:whatsapp:direct:+972542634114',
  senderId: '+972542634114',
  isGroup: false,
  timestamp: 1778443749000
}
```

```
ctx:{
  //always the accountId for whatsapp unless specifically connected multiple phones
  accountId: 'default',

  //reciever phone number, should be same for self
  conversationId: '+972...',

  channelId: 'whatsapp',
  sessionKey: 'agent:ariel-admin:whatsapp:direct:+972542634114',
  senderId: '+972542634114'
}
```

## before_message_write
just like http / completion, is multiple times







# openclaw-control-ui GUI





## message_received

`api.on("message_received", (event, ctx) => {`...

```
event: {
  //empty
  from: '',

  //fixed for GUI
  senderId: 'openclaw-control-ui',

  //standard openclaw full session key 
  sessionKey: 'agent:maximus:main',

  //generic
  content: 'sender message content',
  messageId: 'e2454b1a-6b20-4a56-9f67-4c2e1896f6ff',

  metadata: {
    //channel
    provider: 'webchat',
    surface: 'webchat',
    originatingChannel: 'webchat',

    //fixed for GUI
    senderId: 'openclaw-control-ui',
    
    //generic
    messageId: 'e2454b1a-6b20-4a56-9f67-4c2e1896f6ff',
  }
}
```

```
ctx:{
  //always undefined
  accountId: undefined,

  sessionKey: 'agent:maximus:main',
  messageId: 'e2454b1a-6b20-4a56-9f67-4c2e1896f6ff',
  senderId: 'openclaw-control-ui'
}
```


## before_dispatch

`api.on("before_dispatch", (event, ctx) => {`...

```
event:{
  //sender message content
  content: 'yo maxi!',
  body: '[Sun 2026-05-10 20:11 UTC] yo maxi!',
  channel: 'webchat',
  sessionKey: 'agent:maximus:main',
  senderId: 'openclaw-control-ui',
  isGroup: false,
}
```

```
ctx:{
  //always undefined
  accountId: undefined,
  channelId: 'webchat',
  sessionKey: 'agent:maximus:main',
  senderId: 'openclaw-control-ui'
}
```

## before_message_write
just like http / completion, is multiple times, seems per streaming event

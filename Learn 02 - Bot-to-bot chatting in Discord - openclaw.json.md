# Learn 02 - Bot-to-bot chatting in Discord - openclaw.json.md (for dummies ♥)

Bot-to-bot chatting in Discord doesn’t work by default.

!IMPORTANT - this is simple and chatter arhitecture, will post sometime “Agent teams” arhitecture more apporpriate for prod level team, learn more [here](https://discord.com/channels/1456350064065904867/1476269289437790382)

## prologue 

1. [Learn 01 - Agents and Models - openclaw.json.md (for dummies ♥)](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/Learn%2001%20-%20Agents%20and%20Models%20-%20openclaw.json.md)
2. [my current full json](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/my.openclaw.example.json)
3. that said, before anything you do copy your working setting to some notepad or something until you get to a working version
4. i made this document since most existing commands in docs are incomplete and can easliy break your openclaw, including if you ask the agent to do them
5. if you get in troubles - [Troubleshoot OpenClaw](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/openclaw-troubleshoot.md)
6. if you have your openclaw on MAC then you have it to control your browser, maybe you can teach it to do all that alone ♥
7. also - promotion - contact me WhatsApp `+972542634114` or email `ariel.rubi@gmail.com` for help (paid service)


## table of content

this document assume you have a running openclaw server, if not - go install one (of whatsapp me to do that for you *paid service*)

part 1 - create Discord server and channels and discord-bots
part 2 - create openclaw agents
part 3 - breaksdown on openclaw.json settings for the bots to talks
part 4 - final words about next level architecture


## part 1 - create Discord server and channels and discord-bots


### create Discord Server (Guild)

What you need to do
1. goto [Discord](https://discord.com/channels/@me) - register if needed
2. on the left side nav find a `+` sign that sais (on hover) `Add a server`
3. add a server ☺
4. in that server - left side nav you will see `Text Channels   + ` and `# general`
5. click that `+` and create a new text channel
6. on bottom there is your picture/user image, near it is a settings icon `⚙️`, click it
7. scroll down to `*** Advanced` and click it
8. toggle on `Developer Mode`

*IMPORTANT - keep you server like your password! dont add anyone, not frieds not family, this is an opendoor to your server!


#### save url, server id and channel id

when you click that new channel your url will look like this:

`https://discord.com/channels/<your server id>/<your channel id>`

from here anytime i write serverId or guildId that means `<your server id>` and when i write channelId i mean `<your channel id>` so save them clearly and easy to find and copy.


### create discord-bots

**REFERENCE** - enable permissions (minimun) as in [docs.openclaw.ai](https://docs.openclaw.ai/channels/discord#quick-setup):

* View Channels
* Send Messages
* Read Message History
* Embed Links
* Attach Files
* Add Reactions (optional)

you can add more, just not recommended to allow it any admin stuff




1. goto [discord applications](https://discord.com/developers/applications/)
2. click `New Application`, give it a name (say `batman`), create (and confirm ur a human lol)
3. you are now in the discord-bot settings page
4. left nav click on `Bot`
5. find `Message Content Intent` (somewhere in the middle if the page) - toggle it on and save
6. same page - click all items in **REFERENCE**
7. now go back up and click `Reset Token` (and yes, and your password)
8. SAVE THAT TOKEN somewhere safe and easy to copy from, i will from now on reference it just as `token` or `your bot token`
9. left nav click on `OAuth2` 
10. under `Scopes` click `bot`
11. under `Bot Permissions` click again all items in **REFERENCE**
12. at the end there us a URL - copy and save it, this is an INVITE URL
13. go back to your channel at discord and paste that INVITE URL and send it as a message
14. click it and invite the bot ♥

repeat for at least 1 more bot, or whatever endless amout of bot and team MUWAHAHA!!!

### get user ID's

* in your channel reference the bots like `@batman` and send him something (like `ref`)
* click on the `@batman` -> right-click on the bot icon/name -> scroll down -> `Copy User ID`
* save it, its your `<bot ID>`, you will need it. advice - save each ID with a name, you might want to seperate their abilities and permissions
* repeat for all bots
* finally right click you -> `Copy User ID` and save as well.









## part 2 - create openclaw agents

read this if you want deep understanding

[Learn 01 - Agents and Models - openclaw.json.md (for dummies ♥)](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/Learn%2001%20-%20Agents%20and%20Models%20-%20openclaw.json.md)

otherwise, per agent:

1. open terminal
2. `openclaw agents add batman --workspace ~/.openclaw/workspace-batman`
3. go to you dashboard GUI (the webpage in `https://127.0.0.1:18789` usually, or refresh) and
4. left nad click `Agents` and click your new agent and click Files
5. if any of the files missing (usually memory.md) just write the filename (`memory`) and save, its important for this agent to be autonomous (unless you really know what ur doing)
6. back in terminal `openclaw agent --agent batman -message "wake up"`
7. back in GUI - Chat - find your agent - talk with him a bit, define him and his roles, objectives, who are you, what are your objectives, the more you invest here, the better the agent becomes





# Bot-to-bot chatting in Discord (for dummies ♥) begin!


## part 3 - breaksdown on openclaw.json settings for the bots to talks

at this point you can just copy paste and define correct your `openclaw.json` from [my current full json](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/my.openclaw.example.json), but if you dont get it, time to learn!

**Bot-to-bot chatting in Discord (for dummies ♥) begin!**

### top level configs sections

lets understand what i mean by that, your json looks like this:

```
{
    "meta":{
        ......
    },
    "auth":{
        ......
    },
    "agents":{
        ......
    },
    "gateway":{
        ......
    },
}
```

ect. ect. go review it in [my current full json](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/my.openclaw.example.json)

so i will now talk about high-level-config-sections, so you should either find then or create them.

### your bots need tools

so you should find/create tools with the following:

```
  "tools": {
    "sessions": {
      "visibility": "all"
    },
    "agentToAgent": {
      "enabled": true
    }
  },
```

that will allow your agents to read other sessions, AND allow them to create sessions between each other.

a session (in openclaw) is the definition of and agent talking to X via Y. 

* X can be you, friend, other agent
* Y can be GUI chat, discord, whatsapp, telegarm, cron job

and so you have any combination of XY, and with crons and discords you can click your GUI Sessions section and find the great long list. i made a cron to clean old cron sessions.

each session is a completely independent conversation/context window with the AI and they know nothing about each other. id you want your agent to know something accross sessions you must ask it to save to memory (and start `/new` session) or a file (and ask the other session to read it)



### your bots need bindings to discord

so you should find/create bindings with the following:

```
  "bindings": [
    {
      "agentId": "batman",
      "match": {
        "channel": "discord",
        "accountId": "batman"
      }
    },
    {
      "agentId": "bruce",
      "match": {
        "channel": "discord",
        "accountId": "bruce"
      }
    }
  ],
```

that is just a matching area, just approving and enabling the agents to interact with discord



### your bots need browser access

well, recommended, not a must. 

so you should find/create bindings with the following:

```
  "browser": {
    "enabled": true,
    "executablePath": "/usr/bin/chromium-browser",
    "headless": true,
    "noSandbox": true,
    "defaultProfile": "openclaw"
  },
```

* `"executablePath"` - you can set to wherever you download your browser, whoever it is
* `"headless"` - meaning it runs without a UI, for agents its great. a nice man make a [full list of Headless Browsers](https://github.com/dhamaniasad/HeadlessBrowsers). if you have a MAC or install some desktop to your VPS, you can use with a head and so you can easily login to stuff and see or do stuff
* `"headless"` - if you are security nervous, set to false, but read docs for meanings
* `"defaultProfile"` - read about it in [docs.openclaw.ai](https://docs.openclaw.ai/tools/browser#profiles-openclaw-vs-chrome) or leave `"openclaw"`








### your bots need a daily schedule to call them to action

# HEARTBEAT ♥

the settings part is easy, go find

```
  "browser": {
    "agents": {
        .....
    },
    "list": [
      {
        "id": "main"
      },
      {
        "id": "batman",
        "name": "batman",
        "workspace": "/root/.openclaw/workspace-batman",
        "agentDir": "/root/.openclaw/agents/batman/agent",
        "model": "ollama/qwen3.5:cloud",
        "heartbeat": {
          "every": "16m"
        }
      },
    ]
  },
```

you should see that section ready from the agent creation with 2 items missin:

* `"model": "ollama/qwen3.5:cloud",`
* `"heartbeat": { "every": "16m" }`

what are those - you should thinkg about that carefuly!

* `"heartbeat"` - this is a wonderful system embeded in openclaw that "tick" every X time per agent and tells him what to do, in plain english (send as prompt to AI), this is how we define a schedule for and agent. you should really work on giving it clear and tight instructions.
* `{ "every": "16m" }` - can be `m`, `h`, `d`, you should plan a correct schedule ahead. 16 min is nice for fast conversation when needed (and really burn tokens), keep in mind that they need a few minuts for their tasks, and long tasks can be longer, and prod level is to work vs a todo list
* `"model"` - the ai `<provider>/<model>` to run them, the burn ALOT of tokens, so dont connect them to your OPENAI subscription or they will deplete it fast. use [OLLAMA](https://ollama.com/blog/openclaw) or [SYNTHETIC.NEW](https://synthetic.new/landing/home?referral=55F5WqcExnQfLwi subscriptions for that

if you need help about that part go to [Learn 01 - Agents and Models - openclaw.json.md (for dummies ♥)](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/Learn%2001%20-%20Agents%20and%20Models%20-%20openclaw.json.md)




**HEARTBEAT.md**
you should go to your GUI, Agents section, click your agent, click Files, click HEARTBEAT.md and start writing.

mine says (Trendy ↔ MissDaily are my bots names):
```
# HEARTBEAT.md

# Trendy ↔ MissDaily single-channel heartbeat protocol

Target channel (ONLY):
- discord channel id: <your channel ID>

On each heartbeat, do exactly this:

1) Read recent messages from target channel to avoid repeating yourself.
2) Send exactly ONE concise message to target channel:
   - message(action:"send", channel:"discord", target:"<your channel ID>", message:"<your short next turn>")
   - message content - <write some agenda here>
```

!NOTE - `message:"<your short next turn>"` - this is not for you to change, leave exaclty like this

you only need to change the bots names (`Trendy ↔ MissDaily` to `batman ↔ joker`) and twice `<your channel ID>`





### your bots need a discord channel definition

be strong, longest and last one.

REMINDER, everything we did above and do later you should do all over again for each bot (except server and channel with discord)

so you should find/create channels with the following:


#### define discord server and channels


```
"channels": {
    "whatsapp": { ... },
    "discord": {
        "enabled": true,
        "allowBots": true,
        "groupPolicy": "allowlist",
        "streaming": "off",
        "allowFrom": [
            "discord:channel:<serverId>:<channelId>",
            "discord:user:<yourUserId>"
        ],
        "guilds": {
            "<serverId>": {
                "requireMention": false,
                "users": [
                    "<yourUserId>",
                    "<batmanBotId>",
                    "<jokerBotId>",
                    "<any-other-BotId-you-want-in-conversations>"
                ],
                "channels": {
                    "<channelId>": {
                        "allow": true,
                        "requireMention": false
                    }
                }
            }
        },
        "accounts": {
            ....
        }
    }
},
```

`"channels"` - a channel is a path of communication for a bot. usually you should have there WhatsApp or Telegram, your default communication of choice from back when you installed openclaw.

now lets add `"discord"` and explain:

* `"enabled"` - start channel automatically (from [docs](https://docs.openclaw.ai/gateway/configuration-reference#channels)).
* `"allowBots"` - allow bots to be pro-active in discord
* `"groupPolicy": "allowlist",` - allow bots to commnicate only with what you allow them to ([docs](https://docs.openclaw.ai/channels/zalouser#group-access-optional)) - recommended
* `"streaming: "off""` - its a whole thing to confing `on` so unless you want to right your own tutorial about it, leave it as `off`
* `"allowFrom": [` - the list of users and channels that can chat with the bot, meaning the bot will recieve and respond to messages from those users and channels. these is a global gate, and i prefer to put the channel and not the bots-users so that the bots respond to that channel and not the other bot anywhere in the server.
* `"guilds"` - definitions about your specific server 

`"guilds": { "<serverId>": {` definitions:
* `"requireMention": false,` - does bots must wait for `@batman` (`@botDiscordName/ID`) to be allowed to respond
* `"users": [` - list of users the bots are allowed to listen and respond to
* `"channels": {` - channels the bots are allowed to listen and respond to
* ` "<channelId>": { "allow": true, "requireMention": false }` - channels specific gate, must have `"allow": true` for bots to interact there




#### define discord account for bot

now lets move to `"accounts"`

```
"accounts": {
    "missdaily": {
        "name": "MissDaily",
```
 
I purposly used my bot name for clearification. these values above where auto-generated by my agents registering to discord. down i write from research

```
"accounts": {
    "<openclawInternalAccountName>": {
        "name": "<openclawCosmeticAccountName>",
```

* `"<openclawInternalAccountName>"` - this is how your openclaw treat this account internally
* `"<openclawCosmeticAccountName>"` - this is how your openclaw write this account when he talks to you


with that .....


```
"accounts": {
    "batman": {
        "name": "batman",
        "token": "<batman-bot-token>",
        "groupPolicy": "allowlist",
        "streaming": "off",
        "guilds": {
            "<serverId>": {
                "users": [
                    "<yourUserId>",
                    "<batmanBotId>",
                    "<jokerBotId>",
                    "<any-other-BotId-you-want-in-conversations>"
                ],
                "channels": {
                    "<channelId>": {
                        "allow": true,
                        "requireMention": false
                    },
                }
            }
        }
    }
},
```        

as you notice most of the stuff repeat themselves, this is because openclaw keep 3 gates:

1. `"allowFrom"` at top level - blocks everything except that
2. `"guilds"` - global definition
3. `"accounts"` - private definitions, completely overrides global definitions (theoretically should allow discarding global definition, didnt try)

**the new very important and secret thing** 

`"token": "<batman-bot-token>",` - remember that token when you created the bot? there it goes.

again, do the thing for each bot and.... let the chatter begin!!

i noticed that once the chatter, you can give/change them a goal in-chat and they will co-operate even if not as in-lined with the one in the `HEARTBEAT.md`, so that can really be a general fun chat with your bots.



**dont forget** - 
when you're done just to be just open terminal and `openclaw gateway restart`, and you can check with `openclaw status`





## small tips

**general help/chat with your bots** - you can discard using heartbeat (`0m`) and with these settings initiate a chat and they will start quite a chat. tested and they made 299 messages! (my OCD heart!! where is the last one to go 300!!) (some of it was just mutual stupid praising like AI's like to do)


**to stop endless loop** use strict `allowlists` + `requireMention:true`



**sometimes weak models skip turn** - known issue, happened about 1-2% of times even with brand new `"qwen3.5:cloud`.



**go pro** - use 1 bot as `orchestrator` and strict `allowlists` + `requireMention:true`, and only `orchestrator` has heartbeat with clear goal and should have like a todo or sheet or something, he read instruction, check states, call agents to action, repeat. if any agent need feedback he either ask `orchestrator` or you teach him to use `@mention`




**there is a message config section** - ask your openclaw to teach you about it. all i tough you today is around using the `message` tool, read about in [docs](https://docs.openclaw.ai/cli/message)




**sessions_send + maxPingPongTurns**
if you use [session-tool](https://docs.openclaw.ai/concepts/session-tool#sessions_send) for agents to communicate, this is for silent communication (user dont see it) - you can use
`session.agentToAgent.maxPingPongTurns`

This controls the maximum number of back-and-forth messages when two agents converse with each other (agent-to-agent conversation).

```
{
  "session": {
    "dmScope": "per-channel-peer",
    "agentToAgent": { 
      "maxPingPongTurns": 5  // ← Max conversation turns (default: 5)
    },
  },
}
```

but this is for a completely different architecture you can learn more about in [this help thread](https://discord.com/channels/1456350064065904867/1476269289437790382)












## Troubleshoot

I got allot of help from the openclaw community discord, specifically [this help thread](https://discord.com/channels/1456350064065904867/1476269289437790382) (me being bresleveloper - the asker), so if you still having trouble you can:

1. read that
2. ask help
3. contact me WhatsApp `+972542634114` or email `ariel.rubi@gmail.com`





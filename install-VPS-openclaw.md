# Install OpenClaw via Terminal 
we ♥ black screens

## get VPS
go to hostinger and purchase ubuntu server [my hostinger discount](https://www.hostinger.com/referral?REFERRALCODE=GWCARIELRP5M)

[what model to choose](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/openai.oauth.md)

## get subscription token
~~ go buy [OpenAI](https://developers.openai.com/codex/pricing/) ~~ - claude and gemini dont allow to use their OAuth with OpenClaw.



### other options:
* legit - use API (pay as you go) like [openrouter.ai](https://openrouter.ai/) or amazon bedrock
* legit & super easy - [ollama.com plan](https://ollama.com/blog/openclaw)
* legit - [synthetic.new](https://synthetic.new/?referral=RgalAYbTxY6qzQ8)

Now [ollama comes with plugin](https://docs.ollama.com/integrations/openclaw#web-search-and-fetch) for search `openclaw plugins install @ollama/openclaw-web-search`


## install openclaw

### NEW 1-liner
`curl -fsSL https://openclaw.ai/install.sh | bash`

follow instructions, skip where you can, choose your provider and model.

follow instructions for communication channel, easiest it Telegram (built for bots)

## Permissions Issues 
newer version has multiple safeguards, so any advanced things you want your agent to do require `elevated` permissions and can only be set via the settings itself. so lets learn about that. your openclaw settings file is `~/.openclaw/openclaw.json`. if you are in a VPS you can only edit that with `nano`, unpleasent but after edit save is `ctrl + x` -> `y` -> `enter`.

full command `nano ~/.openclaw/openclaw.json`.

then you must add a section at the same level as `"agents"` named `"tools"` like that:

```
  "tools": {
    "profile": "full",
    "elevated": {
      "enabled": true,
      "allowFrom": { "tui": [ "*" ] }
    },
    "exec": {
      "security": "full",
      "ask": "off",
      "host": "gateway"
    },
  },
```

more [here](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/telegram.super-admin.mode.json)

that will enable at least from terminal `openclaw tui` for your main agent to be able to do anything. `"profile": "full",` means the agent is allowed to use the `exec` tool, the tool for shell commands, and `"elevated"` is another gate for those. you need to enable per channel, so whatsapp, telegram, webchat, ect.



## bonus - free whisper model (transcribe)

HuggingFace `faster-whisper` start from tiny (75mb) up to large-v2 (+3GB). ask your openclaw to give you some analysis for each size or just choose `base`



# login to whatsapp if failed at onbboard 

* login (get QR code) `openclaw channels login --channel whatsapp`
* list pairing (make sure its there, and its yours) `openclaw devices list`
* approve the pairing (if only 1) `openclaw devices approve --latest`
* initiate connection if agent dont react `openclaw message send --channel whatsapp --target +123456 --message "hi"`
* send media file `openclaw message send --channel whatsapp --target +123456 --media /tmp/openclaw/file.pdf --message "here's the file"`

HAS RESTRICTIONS only from pre-defined folders and MEME types (look at docs)  







# OpenClaw Dashboard on VPS

## get your dashboard token
if you missed it during onboard, you can run `openclaw dashboard`

you should find this url (with some random token) `http://localhost:18789/#token=eb98c1c5adbb8448db25e0123456788b81c98e6b18562ca9`

you should find your IP address and choose a port (like 30080, anything between 20000-65000)

## ask this from your agent

```
http://localhost:18789/#token=....

this is the openclaw native dashboard
but you live in a VPS
so i want to open this dashboard to outside

i need your help

1. port forward this to 30080
2. enable 30080 https with Self-signed cert
3. allow origin for gateway https://<your ip>:30080 in your settings  openclaw.json
4. allow the port with ufw
5. approve the pairing device

```

after giving it to him:
1. he might argue, tell him to do it anyway
2. browse to `https://<your ip address>:30080`
3. you might get `ERR_CONNECTION_TIMED_OUT` - tell the agent to solve it
4. you should see `pairing required` error, copy pase it to the agent and tell him to approve the device
5. refresh and dashboard should work






# SECURITY

if using VPS tell your agent to do [all this](https://raw.githubusercontent.com/JarvisDeLaAri/OpenClawIT/refs/heads/main/secure-my-linux-openclaw-basics.md)











need more help? contact me! (paid serviec with ♥)
1. [WhatsApp](https://wa.me/972542634114?text=jarvis%20sent%20me%20to%20you%20about%20AI)
2. [EMAIL](mailto:ariel.rubi@gmail.com?subject=jarvis%20sent%20me%20to%20you%20about%20AI)

# Learn 01 - Agents and Models - openclaw.json.md (for dummies ♥)


## general rules

1. your openclaw.json is at `~/.openclaw/openclaw.json`
2. openclaw saves about 5 backups, so if you break anything just copy backup `cp ~/.openclaw/openclaw.json.bak ~/.openclaw/openclaw.json`
3. that said, before anything you do copy your working setting to some notepad or something until you get to a working version
4. i made this document since most existing commands in docs are incomplete and can easliy break your openclaw, including if you ask the agent to do them
5. if you get in troubles - [Troubleshoot OpenClaw](https://github.com/JarvisDeLaAri/OpenClawIT/blob/main/openclaw-troubleshoot.md)



## table of content

this document assume you have a running openclaw server, if not - go install one (of whatsapp me to do that for you *paid service*)

part 1 - adding more agents
part 2 - adding more providers
part 3 - adding models
part 4 - ollama as docker - define custom providers and models





# part 1 - adding more agents

read more at the official docs about [agents](https://docs.openclaw.ai/cli/agents)

## adding an agent 

it seems that there id not mechanism to add new agents via the UI (19.2.2026). so to initiate a simple agent without any channels or model you need 2 terminal commands (change `batman` to your agent name):

1. `openclaw agents add batman --workspace ~/.openclaw/workspace-batman`
2. `openclaw agent --agent batman -message "wake up"`

* doesnt matter what your message is, just initiate him, and you can continue in the web GUI (web dashboard).
* if you dont provide `--workspace` the terminal will ask you some questions

from that point you can pair it to channels, read docs about [multi agents](https://docs.openclaw.ai/concepts/multi-agent#quick-start)


## openclaw.json for agents

in settings raw is always the basics for the main agent:
```
{
.......
  "auth":.....
  "agents":{
    "defaults":......
```
the `"defaults"` contains details about default model, list of allowed/known models, and some more about the main agent.

after adding an agent `"list"` will appear
```
{
.......
  "auth":.....
  "agents":{
    "defaults":......
    "list": [
      {
        "id": "main"
      },
      {
        "id": "batman",
        "name": "batman",
        "workspace": "/root/.openclaw/workspace-batman",
        "agentDir": "/root/.openclaw/agents/batman/agent",
      }
    ]
  },
```

any agent you will add will join this list. to my understanding you must initiate the agent from terminal, cant just add it in settings.

to add a default model to that agent add `"model": "openai-codex/gpt-5.3-codex"` (dont forget comma at the line above), will talk more about it in models section.

read more in the docs about [multi-agents](https://docs.openclaw.ai/concepts/multi-agent#family-agent-bound-to-a-whatsapp-group)







# part 2 - adding more providers

*IMPORTANT* notice about providers - subscription providers like Google and Anthropic (Claude) ect. all have you agreed in their ToS NOT to use the subscription with 3rd party. Therefor you risk your account being *BANNED*.  (i will note that internet search (19.2.2026) shows that Anthropic is banning fast, google is banning, and currenlty OpanAI are not, BUT THEY MAY!). they also dont allow to serve customers with your subscription, that count as sharing and steating.

so dont do that. most tutorials have Anthropic subscription as the AI, but lets as their AI models are definitely the best. I personally eventually set my openclaw to use ollama as main, codex as agent for the hard stuff, and using claude code/cowork in my local machine for creative work, as codex is AA for anything you TELL him todo, but not creative side.


## primary provider/model

when you installed your openclaw you did `openclaw onboard` and set some provider and model. that will count as your primary model meaning evey chat, session and agent. 

the main issue with using the terminal commands is that they like to override the primary.

so lets learn about providers and how can we can set them immidialty in the settings

## subsciptions tokend and API keys

they are basically the same, just a different secret value to send to the AI endpoint. therefor there are several ways to get them

### the big providers
[Gemini](https://docs.openclaw.ai/concepts/model-providers#google-vertex-antigravity-and-gemini-cli), [Claude](https://docs.openclaw.ai/gateway/authentication#anthropic-setup-token-subscription-auth), GPT - each need his own thing. GPT with `openclaw onboard` just gives you a link to browser, which end with some other link (that wont work on browser) just copy that link back to the terminal and it will work.

### other subscription
there are other subscription providers that will allow you to do whatever you want, providing open souce models (usually the chinese), 3rd party, customers, you name it, 2 of those are [ollama](https://ollama.com/blog/openclaw) and [synthetic.new](https://synthetic.new/landing/home?referral=55F5WqcExnQfLwi). 

to my understanding sythetic is maybe the cheapest, and ollama is the easiest to use as they let you to launch openclaw with their special command with model of your choice.

i am sure there are many more of those. i did not read the ToS of immidiate providers like [kimi.com](https://www.kimi.com/). BTW they provide openclaw-cloud thing.

### API providers - PAYG
there are many API providers like [openrouter.ai](https://openrouter.ai/) or [amazon bedrock](https://aws.amazon.com/bedrock/pricing/), or all the big dogs themselves will allow you to purchase API token.

the point of API is PAYG - Pay As You Go. and for the global ones you can choose from any of the gazilion models out there (sometimes free!)

you can also use [huggingface](https://www.geeksforgeeks.org/artificial-intelligence/how-to-access-huggingface-api-key/) to access more special AI models (and some free!)

p.s. free ones cost maintenance from you. also they must have 64K context minimum.

anyway the point is that you get a token, put a bank of $ ahead, and use at your own pace. 

WHY nobody is using API keys with openclaw? because he is a heavy heavy drinker, every message can cost you 10$ and more with the expensive models like opus (i got 6$ for 1 message!). so use ollama or synthetic.new (it seems that synthetic.new is a bit faster, but i ♥ the ollama as a project). if you do want to use API KEY there are super cheap model that will carry you in a similar price like `openai/gpt-5-nano` ect.

## quick examples
note that they overrride the primary model

openrouter
* get your apikey 
* `openclaw onboard --auth-choice apiKey --token-provider openrouter --token "$OPENROUTER_API_KEY"`. 

ollama 
* `curl -fsSL https://ollama.com/install.sh | sh` - install in openclaw machine
* `ollama launch openclaw --model qwen3.5:cloud` - copy from model page

for others see docs for [model-providers](https://docs.openclaw.ai/concepts/model-providers)


## openclaw.json

lets learn what we get so we learn to define strait into the settings

### pre-defined providers

if you used stuff like claude, openai, openrouter, as they are "well defined" in openclaw's code, it will produce this clause in the settings

```
"auth": {
  "profiles": {
    "openai-codex:default": {
      "provider": "openai-codex",
      "mode": "oauth"
    },
    "openrouter:default": {
      "provider": "openrouter",
      "mode": "api_key"
    }
  }
},
```

what does it means?

1. `"profiles"` - is reference to defined profile in openclaw's code.
2. `"name:default"` - like `"openrouter:default"`, the name of the defined profie. *!IMPORTANT" must end with `:default`
3. `"provider"` - the name of the actual defined profie.
4. `"mode"` - the "secret" value is used a bit different when using "oauth" for the providers subscriptions, while everyting else is using a fixed schema with a Bearer ("api_key")

you will also notice that your "secret" value, token or api key, is not in the settings anywhere. its in another file and your can see it, just type in terminal `cat ~/.openclaw/agents/main/agent/auth-profiles.json`.

and guess what? you can "cheat" with ollama by putting it the same way, you just need to do it manually 
1. add exacty `"ollama:default": { "provider": "ollama", "mode": "api_key" }`
2. in `auth-profiles.json` in `"profiles"` add exacty
```
    "ollama:default": {
      "type": "api_key",
      "provider": "ollama",
      "key": "$YOUR_OLLAMA_KEY"
    }
```

why does it work? remember when i wrote "well defined"? well there are others defined, see them with `cat /usr/lib/node_modules/openclaw/dist/model-auth-CxlTW8uU.js | grep "BASE_URL"`. as long as you are using default values (like "http://127.0.0.1:11434" for ollama, see the others inside the file grep) it will work!


# part 3 - adding models

in your settings you will find
```
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/qwen3.5:cloud"
      },
      "models": {
        "openai-codex/gpt-5.3-codex": { },
```
where `"primary"` will be whatever you last used `openclaw onboard` with. 

as long as there is no `"models"` section then you may use `/model <provider>/<model>` to will allow you to dynamically use any model, if for example your are using openrouter. `/models openrouter --all` will list them all.

but usually you will want to end with something like this in 
```
  "agents": {
    "defaults": {
      "model": {
        "primary": "ollama/qwen3.5:cloud"
      },
      "models": {
        "openai-codex/gpt-5.3-codex": { "alias": "GPT" },
        "openrouter/x-ai/grok-4.1-fast": { "alias": "GROK" },
        "ollama/qwen3.5:cloud": { "alias": "QWEN" },
```

so what do we have here?

each item in `"models"` has its key as `<provider>/<model>` (for openrouter `x-ai/grok-4.1-fast` IS the model value). the `"alias"` is optional and you can also set it as `"ollama/qwen3.5:cloud": {},` (for ollama he will only find those exist in `ollama list`). so go and list all your models of use from all your providers :)

the only value is `"alias"` is to change eaiser a model, instead `/model ollama/qwen3.5:cloud` you write `/model QWEN`



### fallback model
one of the things you can do with multi model is to define a fallback model in case the primary one does not work, so for example i am using the expensive openai codex and when i reach rate limit it will automatically fallback to ollama qwen and next is openrouter

```
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai-codex/gpt-5.3-codex"
        "fallbacks": [
          "ollama/qwen3.5:cloud", "openrouter/x-ai/grok-4.1-fast", 
        ]
      },
```


## setting different models to different agents

so you now know models, and you know your agents, each agent has `"model"` parameter just like default

```
    "list": [
      {
        "id": "main"
      },
      {
        "id": "batman",
        "name": "batman",
        "workspace": "/root/.openclaw/workspace-batman",
        "agentDir": "/root/.openclaw/agents/batman/agent",
        "model": {
          "primary": "openai-codex/gpt-5.3-codex"
          "fallbacks": [
            "ollama/qwen3.5:cloud", "openrouter/x-ai/grok-4.1-fast", 
          ]
      },
```




# part 4 - ollama as docker - define custom providers and models

puttin ollama as a docker for clean seperation is the perfect example to learn how to use custom providers as many must be implemented this way, and btw onboarding with ollama will create this by default.

ALSO onboarding with ollama will also enable you to select your `http://<ip or domain>:<port>/v1` (dont forget v1).

when you use docker for your ollama you expose the ollama endoings in anoter way, usually change ip and port, even if the docker is internal only, just make sure its exposed to the openclaw.

in the config top level, like `"agents"` or `"agents"`, you can define a `"models"` section (NOT the `"agents"` -> `"defaults"` -> `"models"` !!)

the doc root look like
```
{
  "auth":.....
  "agents": ....
  "models": {
    "providers": {
      "ollama": {
        "api": "openai-completions",
        "apiKey": "__OPENCLAW_REDACTED__",
        "baseUrl": "http://127.0.0.1:11434/v1",
        "models": [
          {
            "id": "qwen3.5:cloud",
            .......
```

so lets explain this 1st

1. `"models"` - a placeholder to define custom <provider>/<model> items
2. `"providers"` - by hierarchy provider serve many models
3. `"ollama"` - whatever name you decide
4. `"api"` - in a sec
5. `"apiKey"` - the secret value, with onborading you get the above (or maybe its just a web UI feature)
6. `"baseUrl"` - the thing that ends with v1 (usually)

about `"api"` - it means the format. unless told otherwise its `"openai-completions"`. some providers like [synthetic](https://docs.openclaw.ai/providers/synthetic#synthetic) reportedly use `anthropic-messages`. see more in [source](https://github.com/openclaw/openclaw/blob/main/src/config/types.models.ts). there is even `"ollama"` ♥.

#### the actual custom models definition
```
"models": [
  {
    "id": "qwen3.5:cloud",
    "name": "qwen3.5:cloud",
    "maxTokens": 16384,
    "contextWindow": 131072,
    "cost": { "cacheRead": 0, "cacheWrite": 0, "input": 0, "output": 0 },
    "input": [ "text" ],
    "reasoning": false
    },
    {
      "contextWindow": 131072,
      ....
    }
  }
]
```

1. `"id"` and `"name"` - the name of your model at the provider
2. `"maxTokens"` and `"contextWindow"` - you must websearch these actualy values, and must be minimun 16000/64000
3. `"cost"` - same, not relevat in subscriptions
4. `"input"` - some models can also proccess image
5. `"reasoning"` - can this model use reasoning




















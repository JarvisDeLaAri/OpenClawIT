# Install OpenClaw via Terminal 
we ♥ black screens

## get VPS
go to hostinger and purchace ubuntu server `https://www.hostinger.com/referral?REFERRALCODE=GWCARIELRP5M`

## install node 24+
goto [nodejs download page](https://nodejs.org/en/download) and choose LTS | Linux | nvm | npm

you should get the following rows:
* `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash`
* restart terminal!
* `\. "$HOME/.nvm/nvm.sh"`
* `nvm install 24` 

## install openclaw
`curl -fsSL https://openclaw.ai/install.sh | bash`

## get claude token
* go buy claude pro/max
* open cmd `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd`
* or powershell `irm https://claude.ai/install.ps1 | iex`

### YOU MUST READ
did it say it did not install PATH enviroment variable? if so you need to search for `claude.exe`

usually you can get there by `%USERPROFILE%\.local\bin\claude.exe`

therefor to get the token use `%USERPROFILE%\.local\bin\claude.exe setup-token` and copy the token (usually yellow line, start with `sk`)

COPY THE TOKEN

## initialize openclaw
`openclaw onboard --install-daemon`

follow instructions, skip where you can, choose anthropic provider. if you bought claude pro use Haiku, else use opus 4.6



# openclaw dashboard

## open dashboard
if you want to open your dashboad ask him to forward port of the dashboard to XXXXX, and then ask him to openclaw dashboard and give you the token, and then build full url with server ip, and to make sure its https enabled, and tell him he need to make self signed certificate and restart gateway (->Gateway restarted with self-signed cert.)

result would be `https://<your-ip>:XXXXX?token=02934092834.....`

might be needing to ask him to help make everything connect


# SECURITY

tell him to do this (ask multi times if he did it all) [https://gist.github.com/JarvisDeLaAri/3ef4fce7df6563ca9c1a4597e5040e11](https://gist.github.com/JarvisDeLaAri/3ef4fce7df6563ca9c1a4597e5040e11)







## gemini or others

run the following 
* `npm install -g @google/gemini-cli`
* `openclaw plugins enable google-gemini-cli-auth`
* `openclaw models auth login --provider google-gemini-cli --set-default`

honeslty anything not anthropic for token just makes life hard




# Troubleshoot

## agent not responsive

`openclaw agent --agent [agent_name] --message "/new"` - if u dont know the agent name then its main



## in case this error:

`[openclaw] missing tool result in session history; inserted synthetic error result for transcript repair`

you really dont have alot to go with, its an open issue, session files got corrupted, usually by some code-error that causes infinite loop. copy the files to backup folder

* `openclaw gateway stop`
* `mv ~/.openclaw/agents/<agentId>/sessions ~/.openclaw/agents/<agentId>/sessions.bak`
* if you dont know your <agentId> then its `main`
* `openclaw gateway start --force`
  
if you miss some data you can ask the agent to look at backup folder, and even ask for the specific root reason.
  
mine for example was trying to push a big complicated script to another server, others report giviing too many queued messages.


## onboard not allowing to choose provider
`npx openclaw ...` seems to not be working fully, at least not on windows







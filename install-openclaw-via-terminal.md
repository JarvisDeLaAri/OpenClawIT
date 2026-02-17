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



## get subscription token
~~ go buy claude pro/max ~~ - your account will get banned. same for gemini.

to this date 17.2.2026 according to websearch (not a promise!) only openai do not ban subscription accounts using the openclaw (its a 3rd party and violation of ToS, especially if you serve clients).

* so not so legit - buy openai subscription
* legit - use API (pay as you go) like [openrouter.ai](https://openrouter.ai/) or amazon bedrock
* legit & super easy - [ollama.com plan](https://ollama.com/blog/openclaw)
* legit - [synthetic.new](https://synthetic.new/?referral=RgalAYbTxY6qzQ8)




## install openclaw
choose provider and subsciption, and terminal will instruct you how to get the token.
### Linux
`curl -fsSL https://openclaw.ai/install.sh | bash`

for windows see at the end

## initialize openclaw
`openclaw onboard --install-daemon`

follow instructions, skip where you can, choose your provider and model.

follow instructions for communication channel, easiest it Telegram (built for bots)




## bonus - free whisper model (transcribe)

HuggingFace `faster-whisper` start from tiny (75mb) up to large-v2 (+3GB). ask your openclaw to give you some analysis for each size or just choose `base`




# openclaw dashboard

## open dashboard
if you want to open your dashboad ask him to forward port of the dashboard to XXXXX, and then ask him to openclaw dashboard and give you the token, and then build full url with server ip, and to make sure its https enabled, and tell him he need to make self signed certificate and restart gateway (->Gateway restarted with self-signed cert.)

result would be `https://<your-ip>:XXXXX?token=02934092834.....`

might be needing to ask him to help make everything connect, just send him print screens









# SECURITY

tell him to do this (ask multi times if he did it all) [https://gist.github.com/JarvisDeLaAri/3ef4fce7df6563ca9c1a4597e5040e11](https://gist.github.com/JarvisDeLaAri/3ef4fce7df6563ca9c1a4597e5040e11)







## gemini or others

run the following 
* `npm install -g @google/gemini-cli`
* `openclaw plugins enable google-gemini-cli-auth`
* `openclaw models auth login --provider google-gemini-cli --set-default`










### Windows install
* open cmd `curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd`
* or powershell `irm https://claude.ai/install.ps1 | iex`

### YOU MUST READ
did it say it did not install PATH enviroment variable? if so you need to search for `claude.exe`

usually you can get there by `%USERPROFILE%\.local\bin\claude.exe`

therefor to get the token use `%USERPROFILE%\.local\bin\claude.exe setup-token` and copy the token (usually yellow line, start with `sk`)

COPY THE TOKEN




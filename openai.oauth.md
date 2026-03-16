# how to connect my openai (chatGPT) subscription to openclaw - the very idiot proof guide ♥

## 1. chatGPT vs Codex subscription
OpenAI is a COMPANY and it provides 2 lines of products. the chatGPT line, only for yout to talk with your chat, and the Codex line, an AI brain for your AI agents. you need to have Codes subscription. get one here:

[Codex Pricing Page](https://developers.openai.com/codex/pricing/).


## 2. how to connect OpenClaw to OpenAI OAuth? - part 1

1. if not yet installed OpenClaw - in your onboarding process just choose `OpenAI` => `OAuth`
2. re-doing onboarding - `openclaw onboard` => in choosing provider `OpenAI` => `OAuth` (you can skip everything else)
3. (RECOMMENDED) just adding to existing installation - `openclaw models auth login --provider openai-codex --set-default`

## 3. how to connect OpenClaw to OpenAI OAuth? - part 2
you will be prompted to got to some link. if its a local installation it will open browser, otherwise you need to copy-paste it (if using hostinger terminal you do not have CTRL+C/CTRL+V, so use mouse only).

when browsing to this like it will end with some strange link starting with `localhost:1455....`. if its a local installation you should be done. otherwise copy it in full and paste in your terminal.

## 4. Choose a model - part 1
you will be prompted a list of models, choose `gpt-5.3-codex`, its the most able one and easiest to get started

## 5. Choose a model - part 2
in chat with your agent you can do `/models openai-codex` to see what other models you can change during conversation. you dont lose conversation history.

## 6. Choose a model guide 
changing a model: `/model openai-codex/gpt-5.1-codex-mini`.

my guideline:
* if i need a thinking partner - `/model openai-codex/gpt-5.4`.
* if i need anything to be done - `/model openai-codex/gpt-5.3-codex`.
* if i need cheap - `/model openai-codex/gpt-5.1-codex-mini`.

## 7. PRO tip
use (Ollama subscription)[https://ollama.com/pricing] with your OpenAI subscription for the simple and automated tasks, use `qwen3.5:cloud`)

install ollama with openclaw:
1. install - `curl -fsSL https://ollama.com/install.sh | sh`
2. get model and test - `ollama run qwen3.5:cloud` (exit with ctrl + d)
3. add to models list - `openclaw onboard` - chooose ollama provider


need more help? contact me! (paid serviec with ♥)
1. (WhatsApp)[https://wa.me/972542634114?text=jarvis%20sent%20me%20to%20you%20about%20AI]
2. (EMAIL)[mailto:ariel.rubi@gmail.com?subject=jarvis%20sent%20me%20to%20you%20about%20AI]







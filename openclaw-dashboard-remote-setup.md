# OpenClaw Dashboard on VPS


## get your dashboard toker
if you missed it during onboard, you can run `openclaw dashboard`

you should find this url (with some random token) `http://localhost:18789/#token=eb98c1c5adbb8448db25e0123456788b81c98e6b18562ca9`

you should find your IP address and choose a port (like 30080, anything between 20000-65000)

## ask this from your agent

```
http://localhost:18789/#token=eb98c1c5adbb8448db25e0123456788b81c98e6b18562ca9
this is the openclaw native dashboard
but you live in a VPS
so i want to open this dashboard to outside

i need your help

1. port forward this to 30080
2. enable 30080 https with Self-signed cert
3. allow origin for gateway https://<your ip address>:30080 in your settings
4. allow the port with ufw
5. approve the pairing
```

after giving it to him:
1. he might argue, tell him to do it anyway
2. browse to `https://<your ip address>:30080`
3. you might get `ERR_CONNECTION_TIMED_OUT` - tell the agent to solve it
4. you should see `pairing required` error, copy pase it to the agent and tell him to approve the device
5. refresh and dashboard should work







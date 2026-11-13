# kronbot_bridge

FiveM and RedM resource that links your server to **[Kron](https://kronbot.xyz)**, the Discord bot:

- 🎫 the player's characters (name, job, phone, money) at the top of their Discord tickets
- 📍 **Unstuck** and 🚗 **return a vehicle to the garage** from Discord (staff; no garage on RedM)
- 🚨 in-city `/report`: a thread in your Discord, staff answer there, the player reads it in game
- 📊 a live player board in Discord: players online, slots, jobs on duty (resource 1.4.0+)

The resource only makes **outbound** HTTPS calls to kronbot.xyz. There is no port to open.

## Install

1. In the Kron dashboard, open the **FiveM bridge** (or **RedM bridge**) module and click **Generate a token**.
   A FiveM module token only works on a FiveM server, a RedM one only on a RedM server.
2. Unzip into `resources/[kron]/kronbot_bridge`.
3. In `server.cfg`, after `oxmysql` and your framework:

   ```cfg
   set kron_token "kron_xxxxxxxxxxxxxxxx"
   ensure kronbot_bridge
   ```

4. Restart the server. The console prints `[kronbot_bridge] Connected to Kron` and the dashboard status turns green.

**Requirements**: OneSync, [oxmysql](https://github.com/overextended/oxmysql), and QBCore or Qbox on FiveM, RSG-Core on RedM
(ESX and VORP coming).
Players need Discord running when they join so their Discord account is linked to their license.

**Waiting for the server in the dashboard?** Make sure `set kron_token` is **above** `ensure kronbot_bridge`, set `Config.Debug = true`
and read the console. On some hosts FXServer cannot open `kronbot.xyz` (`HTTP 0`) while `dravo.run`, the same API, works: from 1.5.1
the resource switches to `Config.ApiUrlFallback` by itself.

## Configuration

See `config.lua`: language, `/report` command name and cooldown, the unstuck spots (FiveM and RedM), the default garage.
Keep the token **only** in `server.cfg`: treat it like a password. A new token from the dashboard disables the old one.

## Data

Kron receives only what is needed: Discord ID, license, player name, the number of players per job, and, on staff request, the character's
name, job, phone and money (each field can be turned off in the dashboard). See https://kronbot.xyz/legal/privacy.

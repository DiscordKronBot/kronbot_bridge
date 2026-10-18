# dravo_bridge

FiveM resource that links your server to **[Dravo](https://dravo.run)**, the Discord bot:

- 🎫 the player's characters (name, job, phone, money) at the top of their Discord tickets
- 📍 **Unstuck** and 🚗 **return a vehicle to the garage** from Discord (staff)
- 🚨 in-city `/report`: a thread in your Discord, staff answer there, the player reads it in game

The resource only makes **outbound** HTTPS calls to dravo.run. There is no port to open.

## Install

1. In the Dravo dashboard, open the **FiveM bridge** module and click **Generate a token**.
2. Unzip into `resources/[dravo]/dravo_bridge`.
3. In `server.cfg`, after `oxmysql` and your framework:

   ```cfg
   set dravo_token "dravo_xxxxxxxxxxxxxxxx"
   ensure dravo_bridge
   ```

4. Restart the server. The console prints `[dravo_bridge] Connected to Dravo` and the dashboard status turns green.

**Requirements**: OneSync, [oxmysql](https://github.com/overextended/oxmysql), QBCore or Qbox (ESX coming).
Players need Discord running when they join so their Discord account is linked to their license.

## Configuration

See `config.lua`: language, `/report` command name and cooldown, the unstuck spot, the default garage.
Keep the token **only** in `server.cfg`: treat it like a password. A new token from the dashboard disables the old one.

## Data

Dravo receives only what is needed: Discord ID, license, player name, and, on staff request, the character's
name, job, phone and money (each field can be turned off in the dashboard). See https://dravo.run/legal/privacy.

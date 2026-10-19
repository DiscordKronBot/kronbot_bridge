local Strings = {
  fr = {
    usage = 'Utilisation : /%s <ton message>',
    sent = 'Ton report a été envoyé au staff. Tu recevras la réponse ici.',
    appended = 'Message ajouté à ton report.',
    disabled = 'Les reports ne sont pas activés sur ce serveur.',
    cooldown = 'Patiente quelques secondes avant de renvoyer un report.',
    failed = 'Impossible d’envoyer ton report pour le moment.',
    closed = 'Ton report #%s a été fermé par %s.',
    unstuck = 'Le staff t’a débloqué.',
    garage = 'Ton véhicule %s a été remis au garage par le staff.',
    no_token = '[kronbot_bridge] Aucun token : ajoute  set kron_token "..."  dans ton server.cfg (kronbot.xyz, module FiveM).',
    bad_token = '[kronbot_bridge] Token refusé par Kron. Génère-en un nouveau dans le dashboard.',
    connected = '[kronbot_bridge] Connecté à Kron (%s).',
  },
  en = {
    usage = 'Usage: /%s <your message>',
    sent = 'Your report was sent to staff. You will get the answer here.',
    appended = 'Message added to your report.',
    disabled = 'Reports are not enabled on this server.',
    cooldown = 'Wait a few seconds before sending another report.',
    failed = 'Your report could not be sent right now.',
    closed = 'Your report #%s was closed by %s.',
    unstuck = 'Staff unstuck you.',
    garage = 'Your vehicle %s was returned to the garage by staff.',
    no_token = '[kronbot_bridge] No token: add  set kron_token "..."  to your server.cfg (kronbot.xyz, FiveM module).',
    bad_token = '[kronbot_bridge] Token rejected by Kron. Generate a new one in the dashboard.',
    connected = '[kronbot_bridge] Connected to Kron (%s).',
  },
}

function L(key, ...)
  local lang = Strings[Config.Locale] or Strings.fr
  local s = lang[key] or Strings.fr[key] or key
  if select('#', ...) > 0 then return s:format(...) end
  return s
end

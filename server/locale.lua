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
    no_token = '[dravo_bridge] Aucun token : ajoute  set dravo_token "..."  dans ton server.cfg (dravo.run, module FiveM).',
    bad_token = '[dravo_bridge] Token refusé par Dravo. Génère-en un nouveau dans le dashboard.',
    connected = '[dravo_bridge] Connecté à Dravo (%s).',
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
    no_token = '[dravo_bridge] No token: add  set dravo_token "..."  to your server.cfg (dravo.run, FiveM module).',
    bad_token = '[dravo_bridge] Token rejected by Dravo. Generate a new one in the dashboard.',
    connected = '[dravo_bridge] Connected to Dravo (%s).',
  },
}

function L(key, ...)
  local lang = Strings[Config.Locale] or Strings.fr
  local s = lang[key] or Strings.fr[key] or key
  if select('#', ...) > 0 then return s:format(...) end
  return s
end

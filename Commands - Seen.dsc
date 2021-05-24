dCommander_Command_Seen:
  type: command
  debug: false
  name: seen
  usage: /seen <&lt>user<&gt>
  aliases:
  - lastseen
  - whois
  - who
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Get information from when a player was last seen.
  permission: dcommander.command.seen
  tab completions:
    0 1: <server.players.parse[name]>
  script:
  - choose <context.args.size>:
    - case 1:
      - define Target <server.match_offline_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop
      - define Admin <player.has_permission[dcommander.command.seen.admin]||<context.server>>
      - narrate format:dCommander_Format "Last seen of player:<proc[dCPS]> <[Target].name>"
      - if <[Admin]>:
        - narrate format:dCommander_Col_Format "IP Address:<proc[dCPS]> <yaml[dCommander_<[Target].uuid>].read[seen.ips].last||Unknown>"
      - narrate format:dCommander_Col_Format "Last Online:<proc[dCPS]> <tern[<[Target].is_online>]:Now||<[Target].last_played.time>>"
      - narrate format:dCommander_Col_Format "Health:<proc[dCPS]> <tern[<[Target].health_is[==].to[0]>]:Dead!||<[Target].health><proc[dCPP]>/<proc[dCPS]><[Target].health_max>>"
      - narrate format:dCommander_Col_Format "Banned:<proc[dCPS]> <[Target].is_banned>"
      - if <[Admin]>:
        - if <[Target].is_banned>:
          - narrate format:dCommander_Col_Format "&f      When:<proc[dCPS]> <[Target].ban_info.created.time>"
          - narrate format:dCommander_Col_Format "&f       Why:<proc[dCPS]> <[Target].ban_info.reason>"
          - define Expiry <[Target].ban_expiration_time>
          - narrate format:dCommander_Col_Format "&f    Expiry:<proc[dCPS]> <tern[<[Expiry].in_seconds.is[==].to[0]>]:Never||<[Expiry].time>>"
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.data_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Command_NameHistory:
  type: command
  debug: false
  name: namehistory
  usage: /namehistory <&lt>user<&gt>
  aliases:
  - names
  - historyname
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Get the name history of a player.
  permission: dcommander.command.namehistory
  tab completions:
    0 1: <server.players.parse[name]>
  script:
  - choose <context.args.size>:
    - case 1:
      - define Target <server.match_offline_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop


      - define Names <yaml[dCommander_<[Target].uuid>].read[seen.names]>
      - narrate format:dCommander_Format "Known names of: <[Target].name>"
      - narrate "<proc[dCPP]><[Names].separated_by[<[dCPS]>, <proc[dCPP]>]><proc[dCPS]>."


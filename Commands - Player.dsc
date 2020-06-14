dCommander_Command_Heal:
  type: command
  debug: false
  name: heal
  usage: /heal (player)
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Heal yourself or another player fully.
  permission: dcommander.command.heal
  tab complete:
  - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.get[1]>]>
  script:
  - choose <context.args.size>:
    - case 0:
      - inject dCommander_Require_Player_Handler
      - define Target <player>
    - case 1:
      - define Target <server.match_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"
      - stop

  - heal <[Target]>
  - if <[Target]> == <player||null>:
    - narrate format:dCommander_Format "You have been healed!"
    - stop

  - narrate format:dCommander_Format "<proc[dCPS]><[Target].name><proc[dCPP]> has been healed."
  - narrate format:dCommander_Format "<proc[dCPS]><player.name||console><proc[dCPP]> has healed you." targets:<[Target]>

dCommander_Command_Feed:
  type: command
  debug: false
  name: feed
  usage: /feed (player)
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Feed yourself or another player fully.
  permission: dcommander.command.feed
  script:
  - choose <context.args.size>:
    - case 0:
      - inject dCommander_Require_Player_Handler
      - define Target <player>
    - case 1:
      - define Target <server.match_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"
      - stop

  - feed <[Target]>
  - if <[Target]> == <player||null>:
    - narrate format:dCommander_Format "You have been fed!"
    - stop

  - narrate format:dCommander_Format "<proc[dCPS]><[Target].name><proc[dCPP]> has been fed."
  - narrate format:dCommander_Format "<proc[dCPS]><player.name||console><proc[dCPP]> has fed you." targets:<[Target]>

dCommander_Command_Gamemode:
  type: command
  debug: false
  name: gamemode
  aliases:
  - gm
  - mode
  usage: /gamemode <&lt>mode<&gt> (player)
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Changes your own, or another player's gamemode.
  permission: dcommander.command.gamemode
  tab complete:
  - define V <list[Creative|Survival|Adventure|Spectator|0|1|2|3]>
  - choose <context.args.size>:
    - case 0:
      - determine <[V]>
    - case 1:
      - determine <[V].filter[starts_with[<context.args.get[1]>]]>
    - case 2:
      - determine <server.list_online_players.parse[name].filter[starts_with[<context.args.get[2]>]]>
  script:
  - define Valid <list[Creative|Survival|Adventure|Spectator|0|1|2|3]>
  - choose <context.args.size>:
    - case 1:
      - inject dCommander_Require_Player_Handler
      - define Target <player>
    - case 2:
      - define Target <server.match_player[<context.args.get[2]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"
      - stop

  - define Mode <[Valid].filter[starts_with[<context.args.get[1]>]].get[1]||null>
  - if <[Mode]> == null:
    - narrate format:dCommander_Format "Invalid Gamemode! Valid modes are: <proc[dCPS]><[Valid].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
    - stop

  - choose <[Mode]>:
    - case 0:
      - define Mode Survival
    - case 1:
      - define Mode Creative
    - case 2:
      - define Mode Adventure
    - case 3:
      - define Mode Spectator

  - adjust <[Target]> gamemode:<[Mode]>
  - if <[Target]> == <player||null>:
    - narrate format:dCommander_Format "Your gamemode is now <proc[dCPS]><[Mode]><proc[dCPP]>."
    - stop

  - narrate format:dCommander_Format "Set the gamemode of <proc[dCPS]><[Target].name> <proc[dCPP]>to <proc[dCPS]><[Mode]><proc[dCPP]>."
  - narrate format:dCommander_Format "<proc[dCPS]><player.name||console> <proc[dCPP]>set your gamemode to <proc[dCPS]><[Mode]><proc[dCPP]>." targets:<[Target]>


dCommander_Command_Fly:
  type: command
  debug: false
  name: fly
  aliases:
  - flymode
  - canfly
  - wings
  usage: /fly (on/off/{toggle) (player)
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Changes whether you or another player can fly.
  permission: dcommander.command.fly
  script:
  - define Valid <list[On|Off|Toggle]>
  - choose <context.args.size>:
    - case 0:
      - inject dCommander_Require_Player_Handler
      - define Mode Toggle
      - define Target <player>
    - case 1:
      - inject dCommander_Require_Player_Handler
      - define Mode <[Valid].filter[starts_with[<context.args.get[1]>]].get[1]||null>
      - if <[Mode]> == null:
        - narrate format:dCommander_Format "Invalid mode! Valid modes are: <proc[dCPS]><[Valid].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
        - stop

      - define Target <player>
    - case 2:
      - define Mode <[Valid].filter[starts_with[<context.args.get[1]>]].get[1]||null>
      - if <[Mode]> == null:
        - narrate format:dCommander_Format "Invalid mode! Valid modes are: <proc[dCPS]><[Valid].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
        - stop

      - define Target <server.match_player[<context.args.get[2]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"
      - stop

  - choose <[Mode]>:
    - case On:
      - define MVal true
    - case Off:
      - define MVal false
    - case Toggle:
      - define MVal <[Target].can_fly.not>

  - adjust <[Target]> can_fly:<[MVal]>
  - define Enabled <tern[<[Target].can_fly>]:Enabled||Disabled>
  - if <[Target]> == <player||null>:
    - narrate format:dCommander_Format "Fly mode has been <proc[dCPS]><[Enabled]><proc[dCPP]>."
    - stop

  - narrate format:dCommander_Format "Fly mode has been <proc[dCPS]><[Enabled]><proc[dCPP]> for player <proc[dCPS]><[Target].name><proc[dCPP]>."
  - narrate format:dCommander_Format "Your fly mode has been <proc[dCPS]><[Enabled]><proc[dCPP]> by <proc[dCPS]><player.name||Console><proc[dCPP]>." targets:<[Target]>

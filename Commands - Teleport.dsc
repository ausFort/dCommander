dCommander_Command_SetSpawn:
  type: command
  debug: false
  name: setspawn
  usage: /setspawn
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Sets the current world's spawn location, to your position.
  permission: dcommander.command.setspawn
  script:
  - inject dCommander_Require_Ingame_Handler
  - adjust <player.world> spawn_location:<player.location.block>
  - narrate format:dCommander_Format "Set the spawn of <proc[dCPS]><player.world.name><proc[dCPP]> to <proc[dCFL].context[<player.location.block>|true|true|false]><proc[dCPP]>."

dCommander_Command_Spawn:
  type: command
  debug: false
  name: spawn
  usage: /spawn (player)
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Teleports you or another player to the spawn of the world they are in.
  permission: dcommander.command.spawn
  tab completions:
    0 1: <server.players.parse[name]>
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
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.data_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"
      - stop

  - if <yaml[dCommander_Config].read[teleports.delay.spawn.enabled]||false>:
    - define Delay <yaml[dCommander_Config].read[teleports.delay.spawn.amount]||3>
    - define Location <player.location.block>
    - narrate format:dCommander_Format "Moving will cancel your teleport."
    - repeat <[Delay]>:
      - if <player.location.block> != <[Location]>:
        - narrate format:dCommander_Format "Teleportation has been cancelled as you have moved!"
        - stop

      - define dLoc <yaml[dCommander_Config].read[teleports.delay.display_location]>
      - if <[dLoc]> == title:
        - title "subtitle:<proc[dPC].context[You will be teleported in <proc[dCPS]><[Delay].sub[<[Value].sub[1]>]><proc[dCPP]> seconds.]>" fade_in:0 stay:1s fade_out:0.1s

      - else if <[dLoc]> == action_bar:
        - actionbar "<proc[dPC].context[You will be teleported in <proc[dCPS]><[Delay].sub[<[Value].sub[1]>]><proc[dCPP]> seconds.]>"

      - else:
        - narrate format:dCommander_Format "You will be teleported in <proc[dCPS]><[Delay].sub[<[Value].sub[1]>]><proc[dCPP]> seconds."

      - wait 1s


  - teleport <[Target]> <[Target].world.spawn_location.add[0,1,0]>
  - if <[Target]> == <player>:
    - narrate format:dCommander_Format "You have been teleported to spawn!"
    - stop

  - narrate format:dCommander_Format "<proc[dCPS]><[Target].name><proc[dCPP]> has been teleported to spawn."
  - narrate format:dCommander_Format "<proc[dCPS]><player.name||console><proc[dCPP]> has teleported you to spawn." targets:<[Target]>

dCommander_Command_Teleport:
  type: command
  debug: false
  name: teleport
  aliases:
  - tp
  - port
  - tele
  usage: /teleport [<&lt>destination player<&gt>/<&lt>target player<&gt> <&lt>destination player<&gt>]
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Teleport to another player, or teleport someone else. Can teleport to offline players.
  permission: dcommander.command.teleport
  tab completions:
  0 1 2: <server.players.parse[name[]]>
  script:
  - choose <context.args.size>:
    - case 1:
      - inject dCommander_Require_Player_Handler
      - define Destination <server.match_offline_player[<context.args.get[1]>]||null>
      - if <[Destination]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

      - define Target <player>
    - case 2:
      - define Target <server.match_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

      - define Destination <server.match_offline_player[<context.args.get[2]>]||null>
      - if <[Destination]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.data_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"
      - stop

  - if <[Target]> == <[Destination]>:
    - narrate format:dCommander_Format "Cannot teleport a player to themself!"
    - stop

  - if <yaml[dCommander_Config].read[teleports.delay.teleport.enabled]||false>:
    - define Delay <yaml[dCommander_Config].read[teleports.delay.teleport.amount]||3>
    - define Location <player.location.block>
    - narrate format:dCommander_Format "Moving will cancel your teleport."
    - repeat <[Delay]>:
      - if <player.location.block> != <[Location]>:
        - narrate format:dCommander_Format "Teleportation has been cancelled as you have moved!"
        - stop

      - title "subtitle:<proc[dPC].context[You will be teleported in <proc[dCPS]><[Delay].sub[<[Value].sub[1]>]><proc[dCPP]> seconds.]>" fade_in:0 stay:1s fade_out:0.1s
      - wait 1s

  - teleport <[Target]> <[Destination].location>
  - if <[Target]> == <player>:
    - narrate format:dCommander_Format "You have been teleported to <proc[dCPS]><[Destination].name><proc[dCPP]>." targets:<[Target]>

  - else:
    - narrate format:dCommander_Format "<proc[dCPS]><[Target].name><proc[dCPP]> was teleported to <proc[dCPS]><[Destination].name><proc[dCPP]>."


dCommander_Command_Teleport_Here:
  type: command
  debug: false
  name: teleporthere
  aliases:
  - tphere
  - heretp
  - telehere
  - porthere
  - bring
  - bringhere
  usage: /teleporthere <&lt>player<&gt>
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Teleport another player to your location.
  permission: dcommander.command.teleporthere
  tab completions:
    0 1: <server.online_players.exclude[<player>].parse[name]>
  script:
  - inject dCommander_Require_Ingame_Handler
  - choose <context.args.size>:
    - case 1:
      - define Target <server.match_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

      - if <[Target]> == <player>:
        - narrate format:dCommander_Format "You cannot teleport yourself to yourself!"
        - stop

      - teleport <[Target]> <player.location>
      - narrate format:dCommander_Format "<proc[dCPS]><[Target].name><proc[dCPP]> has been teleported to you!"
      - narrate format:dCommander_Format "<proc[dCPS]><player.name><proc[dCPP]> teleported you to them!" targets:<[Target]>
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.data_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Command_Teleport_pos:
  type: command
  debug: false
  name: teleportpos
  aliases:
  - tppos
  - gotopos
  usage: /teleportpos <&lt>x<&gt> <&lt>z<&gt> <&lt>z<&gt>
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Teleport yourself to a set of coordinates.
  permission: dcommander.command.teleportpos
  script:
  - inject dCommander_Require_Ingame_Handler
  - choose <context.args.size>:
    - case 3:
      - define Error false
      - if <context.args.get[1].is[matches].to[number].not>:
        - narrate format:dCommander_Format "Your <&6>X<&f> coordinate is not a number!"
        - define Error true

      - if <context.args.get[2].is[matches].to[number].not>:
        - narrate format:dCommander_Format "Your <&6>Z<&f> coordinate is not a number!"
        - define Error true

      - else if <context.args.get[2]> > 256 || <context.args.get[2]> < 0:
        - narrate format:dCommander_Format "Y coordinate values must be between 0 and 256."
        - define Error true

      - if <context.args.get[3].is[matches].to[number].not>:
        - narrate format:dCommander_Format "Your <&6>Y<&f> coordinate is not a number!"
        - define Error true

      - if <[Error]>:
        - stop

      - define Location <location[<context.args.get[1]>,<context.args.get[2]>,<context.args.get[3]>,<player.world.name>]>
      - teleport <player> <[Location]>
      - narrate format:dCommander_Format "You have been teleported to <proc[dCFL].context[<[Location]>|false|true|false]>"
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.data_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

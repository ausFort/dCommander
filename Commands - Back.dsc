dCommander_Command_Back:
  type: command
  debug: false
  name: back
  aliases:
  - tpback
  - teleportback
  - backteleport
  - backtp
  - goback
  - return
  usage: /back
  allowed help:
  - determine <player.has_permission[<script.data_key[permission]>]||<context.server>>
  description: Teleport you back to your last location.
  permission: dcommander.command.back
  script:
  - inject dCommander_Require_Ingame_Handler
  - define Locations <yaml[dCommander_<player.uuid>].read[back_locations]||<list[]>>
  - if <[Locations].is_empty>:
    - narrate format:dCommander_Format "You have not been teleported recently!"
    - stop

  - define BackLoc <[Locations].last>
  - if <yaml[dCommander_Config].read[teleports.delay.back.enabled]||false>:
    - define Delay <yaml[dCommander_Config].read[teleports.delay.back.amount]||3>
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


  - flag <player> dCommander_Back
  - teleport <player> <[BackLoc]>
  - yaml set back_locations:<-:<[BackLoc]> id:dCommander_<player.uuid>
  - narrate format:dCommander_Format "You have been teleported back to <proc[dCPS]><proc[dCFL].context[<[BackLoc].block>|true|true]><proc[dCPP]>."

dCommander_Back_Saves:
  type: world
  debug: false
  add_location:
  - wait 1t
  - if <player.has_flag[dCommander_Back]>:
    - flag <player> dCommander_Back:!
    - stop

  - define Current <yaml[dCommander_<player.uuid>].read[back_locations]||<list[]>>
  - if <[Current].size> >= <yaml[dCommander_Config].read[teleports.back.limit]>:
    - yaml set back_locations:<-:<[Current].first> id:dCommander_<player.uuid>

  - yaml set back_locations:->:<context.origin> id:dCommander_<player.uuid>
  events:
    on player teleports:
    - inject locally add_location
    on player killed:
    - if <yaml[dCommander_Config].read[teleports.back.death]||false>:
      - define Current <yaml[dCommander_<player.uuid>].read[back_locations]||<list[]>>
      - if <[Current].size> >= <yaml[dCommander_Config].read[teleports.back.limit]> && <[Current].is_empty.not>:
        - yaml set back_locations:<-:<[Current].first> id:dCommander_<player.uuid>

      - yaml set back_locations:->:<context.origin> id:dCommander_<player.uuid>


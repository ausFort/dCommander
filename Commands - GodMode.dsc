dCommander_Command_Godmode:
  type: command
  debug: false
  name: godmode
  aliases:
  - god
  - godm
  usage: /godmode (on/off/{toggle) (player)
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Changes whether you or another player has godmode.
  permission: dcommander.command.godmode
  script:
  - define Valid li@On|Off|Toggle
  - choose <context.args.size>:
    - case 0:
      - if <context.server>:
        - narrate format:dCommander_Format "You must specify a player when in console!"
        - queue clear

      - define Mode Toggle
      - define Target <player>
    - case 1:
      - if <context.server>:
        - narrate format:dCommander_Format "You must specify a player when in console!"
        - queue clear

      - define Mode <def[Valid].filter[starts_with[<context.args.get[1]>]].get[1]||null>
      - if <def[Mode]> == null:
        - narrate format:dCommander_Format "Invalid mode! Valid modes are: <proc[dCPS]><def[Valid].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
        - queue clear

      - define Target <player>
    - case 2:
      - define Mode <def[Valid].filter[starts_with[<context.args.get[1]>]].get[1]||null>
      - if <def[Mode]> == null:
        - narrate format:dCommander_Format "Invalid mode! Valid modes are: <proc[dCPS]><def[Valid].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
        - queue clear

      - define Target <server.match_player[<context.args.get[2]>]||null>
      - if <def[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - queue clear

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> /fly (on/off/{toggle) (player)"
      - queue clear

  - choose <def[Mode]>:
    - case On:
      - define MVal true
    - case Off:
      - define MVal false
    - case Toggle:
      - define MVal <def[Target].has_flag[dCommander.GodMode].not>

  - if <def[MVal]>:
    - flag <def[Target]> dCommander.GodMode

  - else:
    - flag <def[Target]> dCommander.GodMode:!

  - define Enabled <t[<def[Target].has_flag[dCommander.GodMode]>]:Enabled||Disabled>
  - if <def[Target]> == <player||null>:
    - narrate format:dCommander_Format "Your god mode has been <proc[dCPS]><def[Enabled]><proc[dCPP]>."
    - queue clear

  - narrate format:dCommander_Format "God mode has been <proc[dCPS]><def[Enabled]><proc[dCPP]> for player <proc[dCPS]><def[Target].name><proc[dCPP]>."
  - narrate format:dCommander_Format "Your god mode has been <proc[dCPS]><def[Enabled]><proc[dCPP]> by <proc[dCPS]><player.name||Console><proc[dCPP]>." targets:<def[Target]>


dCommander_Handler_GodMode:
  type: world
  debug: false
  events:
    on player damaged:
      - if <player.has_flag[dCommander.GodMode]>:
        - determine cancelled


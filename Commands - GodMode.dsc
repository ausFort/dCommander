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
        - stop

      - define Mode Toggle
      - define Target <player>
    - case 1:
      - if <context.server>:
        - narrate format:dCommander_Format "You must specify a player when in console!"
        - stop

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
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> /fly (on/off/{toggle) (player)"
      - stop

  - choose <[Mode]>:
    - case On:
      - define MVal true
    - case Off:
      - define MVal false
    - case Toggle:
      - define MVal <[Target].has_flag[dCommander.GodMode].not>

  - if <[MVal]>:
    - flag <[Target]> dCommander.GodMode

  - else:
    - flag <[Target]> dCommander.GodMode:!

  - define Enabled <tern[<[Target].has_flag[dCommander.GodMode]>]:Enabled||Disabled>
  - if <[Target]> == <player||null>:
    - narrate format:dCommander_Format "Your god mode has been <proc[dCPS]><[Enabled]><proc[dCPP]>."
    - stop

  - narrate format:dCommander_Format "God mode has been <proc[dCPS]><[Enabled]><proc[dCPP]> for player <proc[dCPS]><[Target].name><proc[dCPP]>."
  - narrate format:dCommander_Format "Your god mode has been <proc[dCPS]><[Enabled]><proc[dCPP]> by <proc[dCPS]><player.name||Console><proc[dCPP]>." targets:<[Target]>


dCommander_Handler_GodMode:
  type: world
  debug: false
  events:
    on player damaged:
      - if <player.has_flag[dCommander.GodMode]>:
        - determine cancelled


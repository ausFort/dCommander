dCommander_Command_SetWarp:
  type: command
  debug: false
  name: setwarp
  usage: /setwarp <&lt>warp name<&gt>
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Set a warp to your current location.
  permission: dcommander.command.setwarp
  script:
  - inject dCommander_Require_Ingame_Handler
  - choose <context.args.size>:
    - case 1:
      - define Name <context.args.get[1]>
      - if <[Name]> != <[Name].escaped>:
        - narrate format:dCommander_Format "Plain text only, please."
        - stop

      - if <yaml[dCommander_Warps].contains[<[Name]>]>:
        - narrate format:dCommander_Format "Overwriting existing warp at <proc[dCFL].context[<proc[dCommander_Warps_Location].context[<[Name]>]>|true|true|true]><proc[dCPP]>."

      - run dCommander_Warps_Set def:<[Name]>|<player.location.block>|<player> instantly
      - narrate format:dCommander_Format "Warp <proc[dCPS]><[Name]><proc[dCPP]> created at <proc[dCFL].context[<proc[dCommander_Warps_Location].context[<[Name]>]>|true|true|true]><proc[dCPP]>."
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Command_DeleteWarp:
  type: command
  debug: false
  name: delwarp
  usage: /delwarp <&lt>warp name<&gt>
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Deletes the warp with the given name (if it exists).
  tab complete:
  - choose <context.args.size>:
    - case 0:
      - determine <proc[dCommander_Warps_Get].context[true]>
    - default:
      - determine <proc[dCommander_Warps_Get].context[true].filter[starts_with[<context.args.last>]]>
  permission: dcommander.command.delwarp
  script:
  - choose <context.args.size>:
    - case 1:
      - define Name <context.args.get[1]>
      - if <[Name]> != <[Name].escaped>:
        - narrate format:dCommander_Format "Plain text only, please."
        - stop

      - if <yaml[dCommander_Warps].contains[<[Name]>].not>:
        - narrate format:dCommander_Format "No warp exists with the given name."
        - stop

      - narrate format:dCommander_Format "Removed warp <proc[dCPS]><[Name]><proc[dCPP]> from <proc[dCFL].context[<proc[dCommander_Warps_Location].context[<[Name]>]>|true|true|true]><proc[dCPP]>."
      - yaml set <[Name]>:! id:dCommander_Warps
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Command_Warp:
  type: command
  debug: false
  name: warp
  usage: /warp <&lt>warp name<&gt>
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Warp to a location.
  tab complete:
  - choose <context.args.size>:
    - case 0:
      - determine <proc[dCommander_Warps_Get]>
    - default:
      - determine <proc[dCommander_Warps_Get].filter[starts_with[<context.args.last>]]>
  permission: dcommander.command.warp
  script:
  - inject dCommander_Require_Ingame_Handler
  - define Warps <proc[dCommander_Warps_Get]>
  - choose <context.args.size>:
    - case 0:
      - if <[Warps].is_empty>:
        - narrate format:dCommander_Format "You currently have no warps available to you!"
        - stop

      - narrate format:dCommander_Format "Available Warps:<proc[dCPS]> <[Warps].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
    - case 1:
      - define Target <context.args.get[1]>
      - if <[Target]> != <[Target].escaped>:
        - narrate format:dCommander_Format "Plain text only, please."
        - stop

      - if <[Warps].contains[<[Target]>].not>:
        - narrate format:dCommander_Format "No warp exists with the given name or you do not have permission for that warp."
        - stop

      - if <yaml[dCommander_Config].read[teleports.delay.warp.enabled]||false>:
        - define Delay <yaml[dCommander_Config].read[teleports.delay.warp.amount]||3>
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


      - teleport <player> <proc[dCommander_Warps_Location].context[<[Target]>]>
      - narrate format:dCommander_Format "You have been warped to <proc[dCPS]><[Target].to_titlecase><proc[dCPP]>."
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Warps_Location:
  type: procedure
  debug: false
  definitions: WarpName
  script:
  - if <yaml[dCommander_Warps].contains[<[WarpName]>]>:
    - determine <yaml[dCommander_Warps].read[<[WarpName]>.location]>

  - determine "Unknown Location"

dCommander_Warps_Set:
  type: task
  debug: false
  definitions: Name|Location|Creator
  script:
  - yaml set <[Name]>.location:<[Location]> id:dCommander_Warps
  - if <[Creator].exists>:
    - yaml set <[Name]>.creator:<[Creator]> id:dCommander_Warps


dCommander_Warps_Get:
  type: procedure
  debug: false
  definitions: All
  script:
  - if <[All]||false> || <yaml[dCommander_Config].read[warps.per_warp_permissions].not||true>:
    - determine <yaml[dCommander_Warps].list_keys[].parse[to_titlecase]>

  - define Warps <list[]>
  - foreach <yaml[dCommander_Warps].list_keys[]>:
    - if <player.has_permission[dcommander.command.warp.<[Value]>]>:
      - define Warps <[Warps].include[<[Value].to_titlecase>]>

  - determine <[Warps]>

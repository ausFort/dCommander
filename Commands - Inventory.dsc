dCommand_Command_InventorySee:
  type: command
  debug: false
  name: inventorysee
  aliases:
  - isee
  - invsee
  - checkinventory
  usage: /inventorysee <&lt>player<&gt>
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: See another player's inventory.
  permission: dcommander.command.inventorysee
  script:
  - inject dCommander_Require_Ingame_Handler
  - choose <context.args.size>:
    - case 1:
      - define Target <server.match_offline_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

      - else if <[Target]> == <player>:
        - narrate format:dCommander_Format "Why are you trying to peek at your own inventory?"
        - stop

      - narrate format:dCommander_Format "Opening inventory of <proc[dCPS]><[Target].name><proc[dCPP]>."
      - inventory open d:<[Target].inventory>
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Command_EnderSee:
  type: command
  debug: false
  name: endersee
  aliases:
  - endsee
  - enderchestsee
  usage: /endersee <&lt>player<&gt>
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: See a player's ender chest.
  permission: dcommander.command.endersee
  script:
  - inject dCommander_Require_Ingame_Handler
  - choose <context.args.size>:
    - case 1:
      - define Target <server.match_offline_player[<context.args.get[1]>]||null>
      - if <[Target]> == null:
        - narrate format:dCommander_Format "No player can be found by that name!"
        - stop

      - narrate format:dCommander_Format "Opening enderchest of <proc[dCPS]><[Target].name><proc[dCPP]>."
      - inventory open d:<[Target].enderchest>
    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Command_ClearInventory:
  type: command
  debug: false
  name: clearinventory
  aliases:
  - clear
  - clearinv
  - empty
  usage: /clearinventory (player)
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Clear your own or another player's inventory.
  permission: dcommander.command.clearinventory
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

  - inventory clear d:<[Target].inventory>
  - if <[Target]> == <player>:
    - narrate format:dCommander_Format "Cleared your inventory."
    - stop

  - narrate format:dCommander_Format "Cleared the inventory of <proc[dCPS]><[Target].name><proc[dCPP]>."
  - narrate format:dCommander_Format "Your inventory has been cleared." targets:<[Target]>

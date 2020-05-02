dCommander_Command_Item:
  type: command
  debug: false
  name: item
  aliases:
  - i
  usage: /item <&lt>item<&gt> (quantity)
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Give yourself an item.
  permission: dcommander.command.item
  script:
  - inject s@dCommander_Require_Ingame_Handler
  - choose <context.args.size>:
    - case 1:
      - define Item <context.args.get[1].as_item||null>
      - if <def[Item]> == null:
        - narrate format:dCommander_Format "Sorry, that item cannot be found!"
        - queue clear

      - if <yaml[dCommander_Config].read[give.per_item_permissions]> && <player.has_permission[dcommander.command.item.unrestricted].not>:
        - if <player.has_permission[dCommander.command.item.<def[Item].scriptname||<def[Item].material.name>>].not>:
          - narrate format:dCommander_Format "You don't have permission to give this item!"
          - queue clear

      - define Quantity 1
      - if <context.args.size> >= 2:
        - define Quantity <context.args.get[2].as_int||null>
        - if <def[Quantity]> == null:
          - narrate format:dCommander_Format "You must enter a whole number as the quantity. e.g. 2"
          - queue clear

      - give <def[Item]> quantity:<def[Quantity]>
      - narrate format:dCommander_Format "You have been given <proc[dCPS]><def[Quantity]> <def[Item].display||<def[Item].material.name>><proc[dCPP]>"

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <parse:<script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated>>"
      - queue clear

dCommander_Command_Enchant:
  type: command
  debug: false
  name: enchant
  aliases:
  - enchantments
  - enchantment
  - enchants
  usage: /enchant <&lt>list/enchantment(<&co>level)<&gt> ...
  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>
  description: Enchant the item in your hand.
  permission: dcommander.command.enchant
  script:
  - define valid <server.list_enchantments>
  - choose <context.args.size>:
    - case 0:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <parse:<script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated>>"

    - default:
      - if <context.args.get[1]> == list:
        - narrate format:dCommander_Format "Valid enchantments are:<proc[dCPS]> <def[valid].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
        - queue clear

      - inject s@dCommander_Require_Ingame_Handler
      - define Item <player.item_in_hand>
      - if <def[Item].material.name> == air:
        - narrate format:dCommander_Format "You cannot enchant air!"
        - queue clear

      - define Enchantments <context.args>
      - foreach <def[Enchantments]>:
        - define Enchantment <def[Value].before[:]>
        - if <def[valid].contains[<def[Enchantment]>].not>:
          - narrate format:dCommander_Format "Invalid enchantment:<proc[dCPS]> <def[Enchantment].to_uppercase><proc[dCPP]>."
          - queue clear

        - define Level <def[Value].after[:]||null>
        - if <def[Level]> == "":
          - define Level 1

        - if <def[Level]> == null || <def[Level]> !matches number || <def[Level]> <= 0:
          - narrate format:dCommander_Format "Enchantment level must be atleast 1! @<proc[dCPS]><def[Enchantment].to_uppercase><proc[dCPP]>."
          - queue clear

        - define Enchantments <def[Enchantments].set[<def[Enchantment]>,<def[Level]>].at[<def[Loop_Index]>]>

      - adjust <def[Item]> enchantments:<def[Enchantments]> save:item
      - inventory set o:<entry[item].result> d:<player.inventory> slot:<player.item_in_hand.slot>
      - define Enchantments <entry[item].result.enchantments.with_levels>
      - narrate format:dCommander_Format "Your <proc[dCPS]><def[Item].material.name><proc[dCPP]> is now enchanted with <proc[dCPS]><def[Enchantments].replace[,].with[<proc[dCPP]>:<proc[dCPS]>].as_list.separated_by[<proc[dCPP]> + <proc[dCPS]>]><proc[dCPP]>."

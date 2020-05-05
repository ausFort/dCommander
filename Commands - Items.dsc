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
  tab complete:
  - define ItemList <server.list_material_types.filter[is_item].parse[name].alphabetical>
  - choose <context.args.size>:
    - case 0:
      - determine <[ItemList]>
    - case 1:
      - determine <[ItemList].filter[contains[<context.args.last>]]>
  script:
  - inject s@dCommander_Require_Ingame_Handler
  - choose <context.args.size>:
    - case 0:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"
      - queue clear

    - default:
      - define Item <context.args.get[1].as_item||null>
      - if <[Item]> == null:
        - narrate format:dCommander_Format "Sorry, that item cannot be found!"
        - queue clear

      - if <yaml[dCommander_Config].read[give.per_item_permissions]> && <player.has_permission[dcommander.command.item.unrestricted].not>:
        - if <player.has_permission[dCommander.command.item.<[Item].scriptname||<[Item].material.name>>].not>:
          - narrate format:dCommander_Format "You don't have permission to give this item!"
          - queue clear

      - define Quantity 1
      - if <context.args.size> >= 2:
        - if <context.args.get[2].is_integer>:
          - define Quantity <context.args.get[2]>
        - else:
          - narrate format:dCommander_Format "You must enter a whole number as the quantity. e.g. 2"
          - queue clear

      - give <[Item]> quantity:<[Quantity]>
      - narrate format:dCommander_Format "You have been given <proc[dCPS]><[Item].display||<[Item].material.name>><proc[dCPP]> x <proc[dCPS]><[Quantity]><proc[dCPP]>."

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
        - narrate format:dCommander_Format "Valid enchantments are:<proc[dCPS]> <[valid].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."
        - queue clear

      - inject s@dCommander_Require_Ingame_Handler
      - define Item <player.item_in_hand>
      - if <[Item].material.name> == air:
        - narrate format:dCommander_Format "You cannot enchant air!"
        - queue clear

      - define Enchantments <context.args>
      - foreach <[Enchantments]>:
        - define Enchantment <[Value].before[:]>
        - if <[valid].contains[<[Enchantment]>].not>:
          - narrate format:dCommander_Format "Invalid enchantment:<proc[dCPS]> <[Enchantment].to_uppercase><proc[dCPP]>."
          - queue clear

        - define Level <[Value].after[:]||null>
        - if <[Level]> == "":
          - define Level 1

        - if <[Level]> == null || <[Level]> !matches number || <[Level]> <= 0:
          - narrate format:dCommander_Format "Enchantment level must be atleast 1! @<proc[dCPS]><[Enchantment].to_uppercase><proc[dCPP]>."
          - queue clear

        - define Enchantments <[Enchantments].set[<[Enchantment]>,<[Level]>].at[<[Loop_Index]>]>

      - adjust <[Item]> enchantments:<[Enchantments]> save:item
      - inventory set o:<entry[item].result> d:<player.inventory> slot:<player.item_in_hand.slot>
      - define Enchantments <entry[item].result.enchantments.with_levels>
      - narrate format:dCommander_Format "Your <proc[dCPS]><[Item].material.name><proc[dCPP]> is now enchanted with <proc[dCPS]><[Enchantments].replace[,].with[<proc[dCPP]>:<proc[dCPS]>].as_list.separated_by[<proc[dCPP]> + <proc[dCPS]>]><proc[dCPP]>."

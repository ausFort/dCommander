dcommander_Command_SetHome:
  type: command
  debug: false
  name: sethome
  usage: /sethome <&lt>home name<&gt>

  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>

  description: Set a new home to your current location.

  permission: dcommander.command.sethome
  script:
  - inject dCommander_Require_Ingame_Handler

  - choose <context.args.size>:

    - case 1:
      - define Name <context.args.get[1]>
      - if <[Name]> != <[Name].escaped>:
        - narrate format:dCommander_Format "Plain text only, please."
        - stop

      - define Max <proc[dCommander_Homes_Get_Max].context[<player>]>
      - if <[Max]> != -1 && <proc[dCommander_Homes_Get].size> == <[Max]> && <player.has_permission[dCommander.homes.unlimited].not>:
        - narrate format:dCommander_Format "You have reached your home limit of <proc[dCPS]><[Max]><proc[dCPP]> homes."

      - if <proc[dCommander_Homes_Get].contains[<[Name]>]>:
        - narrate format:dCommander_Format "Overwriting existing home at <proc[dCFL].context[<proc[dCommander_Homes_Location].context[<player.uuid>|<[Name]>]>|true|true|true]><proc[dCPP]>."

      - yaml set homes.<[Name]>:<player.location.block> id:dCommander_<player.uuid>
      - narrate format:dCommander_Format "New home <proc[dCPS]><[Name].to_titlecase><proc[dCPP]> set at <proc[dCFL].context[<player.location.block>|true|true|true]><proc[dCPP]>."

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"


dCommander_Command_DeleteHome:
  type: command
  debug: false
  name: delhome
  usage: /delhome <&lt>home name<&gt>

  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>

  description: Deletes your home with the given name (if it exists).

  tab complete:
  - choose <context.args.size>:
    - case 0:
      - determine <proc[dCommander_Homes_Get]>
    - default:
      - determine <proc[dCommander_Homes_Get].filter[starts_with[<context.args.last>]]>

  permission: dcommander.command.delhome
  script:
  - inject dCommander_Require_Ingame_Handler

  - choose <context.args.size>:

    - case 1:
      - define Name <context.args.get[1]>
      - if <[Name]> != <[Name].escaped>:
        - narrate format:dCommander_Format "Plain text only, please."
        - stop

      - if <proc[dCommander_Homes_Get].contains[<[Name]>].not>:
        - narrate format:dCommander_Format "You don't have a home by that name!"
        - stop

      - narrate format:dCommander_Format "Removed home <proc[dCPS]><[Name]><proc[dCPP]> from location <proc[dCFL].context[<proc[dCommander_Homes_Location].context[<player.uuid>|<[Name]>]>|true|true|true]><proc[dCPP]>."
      - yaml set homes.<[Name]>:! id:dCommander_<player.uuid>

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dcommander_Command_Home:
  type: command
  debug: false
  name: home
  usage: /home <&lt>home name<&gt>

  allowed help:
  - determine <player.has_permission[<script.yaml_key[permission]>]||<context.server>>

  description: Go to one of your homes.

  tab complete:
  - choose <context.args.size>:
    - case 0:
      - determine <proc[dCommander_Homes_Get]>
    - default:
      - determine <proc[dCommander_Homes_Get].filter[starts_with[<context.args.last>]]>

  permission: dcommander.command.home
  script:
  - inject dCommander_Require_Ingame_Handler

  - define Homes <proc[dCommander_Homes_Get]>
  - choose <context.args.size>:

    - case 0:
      - if <[Homes].is_empty>:
        - narrate format:dCommander_Format "You currently have no homes set!"
        - stop

      - narrate format:dCommander_Format "Your Homes:<proc[dCPS]> <[Homes].separated_by[<proc[dCPP]>, <proc[dCPS]>]><proc[dCPP]>."

    - case 1:
      - define Name <context.args.get[1]>
      - if <[Name]> != <[Name].escaped>:
        - narrate format:dCommander_Format "Plain text only, please."
        - stop

      - if <[Homes].contains[<[Name]>].not>:
        - narrate format:dCommander_Format "You don't have a home by that name!"
        - stop


      - if <yaml[dCommander_Config].read[teleports.delay.home.enabled]||false>:
        - define Delay <yaml[dCommander_Config].read[teleports.delay.home.amount]||3>
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


      - teleport <player> <proc[dCommander_Homes_Location].context[<player.uuid>|<[Name]>]>
      - narrate format:dCommander_Format "You've been teleported to your home <proc[dCPS]><[Name].to_titlecase><proc[dCPP]>."

    - default:
      - narrate format:dCommander_Format "Usage:<proc[dCPS]> <script.yaml_key[usage].split[ ].set[/<context.alias.to_lowercase>].at[1].space_separated.parsed>"

dCommander_Homes_Location:
  type: procedure
  debug: false
  definitions: UUID|HomeName
  script:
  - if <[UUID].exists> && <[HomeName].exists>:
    - if <[UUID].is_player||false>:
      - define UUID <[UUID].uuid>

    - define UUID <[UUID]||<player.uuid>>
    - if <yaml[dCommander_<[UUID]>].contains[homes.<[HomeName]>]>:
      - determine <yaml[dCommander_<[UUID]>].read[homes.<[HomeName]>]>


  - determine "Unknown Location"

dCommander_Homes_Get:
  type: procedure
  debug: false
  definitions: UUID
  script:
  - if <[UUID].exists>:
    - if <[UUID].is_player||false>:
      - define UUID <[UUID].uuid>


  - define UUID <[UUID]||<player.uuid>>
  - determine <yaml[dCommander_<[UUID]>].list_keys[Homes].parse[to_titlecase]||<list[]>>


dCommander_Homes_Get_Max:
  type: procedure
  debug: false
  definitions: Player
  script:
  - if <[Player].exists.not> && <player.is_online||false>:
    - define Player <player>

  - define Player <[Player]||<player>>
  - define Maxes <list[1]>
  - foreach <yaml[dCommander_Config].list_keys[homes.limit]||<list[]>>:
    - if <[Player].has_permission[dcommander.homes.limit.<[Value]>]>:
      - define Maxes <[Maxes].include[<yaml[dCommander_Config].read[homes.limit.<[Value]>]>]>


  - determine <[Maxes].numerical.last>

dCommander_Command_dCommander:
  type: command
  debug: false
  name: dcommander
  aliases:
  - dc
  - dcomm
  usage: /dCommander
  description: dCommander
  script:
    - choose <context.args.get[1]||help>:
      ## Reload ##
      - case reload:
        - if <player.has_permission[dcommander.command.reload]||<context.server>>:
          - if <server.has_file[/dCommander/config.yml].not>:
            - inject dCommander_Initialise_Main path:initialise_config
            - narrate format:dCommander_Format "Config not found, regenerating!"
          - else:
            - yaml load:/dCommander/config.yml id:dCommander_Config
          - narrate format:dCommander_Format "Reloaded dCommander!"
          - stop
        - narrate format:dCommander_Format "Usage: <proc[dCPS]>/dCommander <&lt>info<&gt>"

      ## Information ##
      - case info:
        - narrate format:dCommander_Format "dCommander Version <proc[dCPS]>0.8<proc[dCPP]>. Made by <proc[dCPS]>Fortifier<proc[dCPP]>."

      ## Help ##
      - default:
        - if <player.has_permission[dcommander.command.reload]||<context.server>>:
          - narrate format:dCommander_Format "Usage: <proc[dCPS]>/dCommander <&lt>info/reload<&gt>"
        - else:
          - narrate format:dCommander_Format "Usage: <proc[dCPS]>/dCommander <&lt>info<&gt>"

dCommander_Initialise_Main:
  type: world
  debug: false
  events:
    on server start:
      - if <server.has_file[/dCommander/config.yml].not>:
        - inject locally initialise_config
        - announce to_console format:dCommander_Format "Generated new configuration."
      - else:
        - yaml load:/dCommander/config.yml id:dCommander_Config
      - run dCommander_Players_Save instantly
      - if <server.scripts.parse[name].contains[dCommander_Command_Warp]>:
        - run dCommander_Warps_Save instantly
      - announce to_console format:dCommander_Format "dCommander successfully loaded."
    on shutdown:
      - if <yaml.list.contains[dCommander_Config]>:
        - yaml savefile:/dCommander/config.yml id:dCommander_Config
      - if <yaml.list.contains[dCommander_Warps]>:
        - yaml savefile:/dCommander/warps.yml id:dCommander_Warps

  initialise_config:
    - yaml create id:dCommander_Config
    - yaml set colors.primary:&f id:dCommander_Config
    - yaml set colors.secondary:&6 id:dCommander_Config
    - yaml set warps.per_warp_permissions:false id:dCommander_Config
    - yaml set teleports.delay.warp.enabled:false id:dCommander_Config
    - yaml set teleports.delay.home.enabled:false id:dCommander_Config
    - yaml set teleports.delay.spawn.enabled:false id:dCommander_Config
    - yaml set teleports.delay.back.enabled:false id:dCommander_Config
    - yaml set teleports.delay.warp.amount:3 id:dCommander_Config
    - yaml set teleports.delay.home.amount:3 id:dCommander_Config
    - yaml set teleports.delay.spawn.amount:3 id:dCommander_Config
    - yaml set teleports.delay.back.amount:3 id:dCommander_Config
    - yaml set teleports.delay.display_location:title id:dCommander_Config
    - yaml set homes.limit.default:1 id:dCommander_Config
    - yaml set homes.limit.premium:3 id:dCommander_Config
    - yaml set give.per_item_permissions:false id:dCommander_Config
    - yaml set teleports.back.limit:5 id:dCommander_Config
    - yaml set teleports.back.death:false id:dCommander_Config
    - yaml set messages.join.enabled:false id:dCommander_Config
    - yaml set "messages.join.message:&6Please welcome &f<&pc>name<&pc>&6 to the server!" id:dCommander_Config
    - yaml savefile:/dCommander/config.yml id:dCommander_Config

dCommander_Initialise_Players:
  type: world
  debug: false
  events:
    on player joins:
      - flag <player> dCommander_Back
      - if <server.has_file[/dCommander/saves/<player.uuid>.yml].not>:
        - yaml create id:dCommander_<player.uuid>
      - else if <yaml.list.contains[dCommander_<player.uuid>].not>:
        - yaml load:/dCommander/saves/<player.uuid>.yml id:dCommander_<player.uuid>
        - define IP <player.ip.address.after[/].before[:]>
        - if <yaml[dCommander_<player.uuid>].read[seen.ips].contains[<[IP]>].not||true>:
          - yaml set seen.ips:->:<[IP]> id:dCommander_<player.uuid>
        - define Name <player.name>
        - if <yaml[dCommander_<player.uuid>].read[seen.names].contains[<[Name]>].not||true>:
          - yaml set seen.names:->:<[Name]> id:dCommander_<player.uuid>
        - if <yaml[dCommander_Config].read[messages.join.enabled]||false>:
          - define Name <player.name>
          - if <yaml[dCommander_Config].contains[messages.join.message].not>:
            - stop
          - determine <yaml[dCommander_Config].read[messages.join.message].parse_color.replace[<&pc>name<&pc>].with[<[Name]>]>

dCommander_Players_Save:
  type: task
  debug: false
  script:
    - foreach <server.players>:
      - if <server.has_file[/dCommander/saves/<[Value].uuid>.yml].not>:
        - yaml create id:dCommander_<[Value].uuid>
      - else if <yaml.list.contains[dCommander_<[Value].uuid>].not>:
        - yaml load:/dCommander/saves/<[Value].uuid>.yml id:dCommander_<[Value].uuid>
      - yaml savefile:/dCommander/saves/<[Value].uuid>.yml id:dCommander_<[Value].uuid>
    - run <script> delay:15s instantly

dCommander_Warps_Save:
  type: task
  debug: false
  script:
    - if <server.has_file[/dCommander/warps.yml].not>:
      - yaml create id:dCommander_Warps
      - yaml savefile:/dCommander/warps.yml id:dCommander_Warps
      - announce to_console format:dCommander_Format "Generated new warps file."
    - else if <yaml.list.contains[dCommander_Warps].not>:
      - yaml load:/dCommander/warps.yml id:dCommander_Warps
      - announce to_console format:dCommander_Format "Loaded warps file."
    - run <script> delay:15s instantly

dCommander_Format:
  type: format
  debug: false
  format: <proc[dPC].context[&7[<proc[dCPS]>dCmd&7]<proc[dCPP]> <text>]>

dCommander_Col_Format:
  type: format
  debug: false
  format: <proc[dPC].context[<text>]>

dPC:
  type: procedure
  debug: false
  script:
  - determine <[1].parse_color>

dCPP:
  type: procedure
  debug: false
  script:
  - determine <yaml[dCommander_Config].read[Colors.Primary]>

dCPS:
  type: procedure
  debug: false
  script:
  - determine <yaml[dCommander_Config].read[Colors.Secondary]>

dCFL:
  type: procedure
  debug: false
  definitions: dLoc|Simple|Colored|With_World
  script:
  - if <list[true|false].contains[<[Colored]||null>].not>:
    - define Colored false
  - if <list[true|false].contains[<[With_World]||null>].not>:
    - define With_World true
  - if <[Simple]>:
    - define dLoc <[dLoc].block>
  - define X <tern[<[Colored]>].pass[<proc[dCPS]><[dLoc].x><proc[dCPP]>].fail[<[dLoc].x>]>
  - define Y <tern[<[Colored]>].pass[<proc[dCPS]><[dLoc].y><proc[dCPP]>].fail[<[dLoc].y>]>
  - define Z <tern[<[Colored]>].pass[<proc[dCPS]><[dLoc].z><proc[dCPP]>].fail[<[dLoc].z>]>
  - define World <empty>
  - if <[With_World]>:
    - define World ", <tern[<[Colored]>].pass[<proc[dCPS]><[dLoc].world.name>].fail[<[dLoc].world.name>]>"
  - define dLoc "<[X]>, <[Y]>, <[Z]><[World]>&r"
  - determine <[dLoc].parse_color>

dCommander_Require_Ingame_Handler:
  type: task
  debug: false
  script:
  - if <context.server>:
    - narrate format:dCommander_Format "You must be ingame to use this command!"
    - stop

dCommander_Require_Player_Handler:
  type: task
  debug: false
  script:
  - if <context.server>:
    - narrate format:dCommander_Format "You must specify a player when in console!"
    - stop

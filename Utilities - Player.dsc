dCommander_Utility_Chat_Color:
  type: world
  events:
    on player chats:
    - if <player.has_permission[dcommander.utility.chatcolor]> || <player.is_op>:
      - determine <context.message.parse_color>

dCommander_Utility_Sign_Color:
  type: world
  events:
    on player changes sign:
    - if <player.has_permission[dcommander.utility.signcolor]> || <player.is_op>:
      - determine <context.new.parse[parse_color].escape_contents>

TestTask:
    type: task
    script:
    - yaml id:<player.uuid> set islandHome:<player.location>
    - wait 1t
    - yaml id:<player.uuid> copykey:islandHome worldBorderCenter
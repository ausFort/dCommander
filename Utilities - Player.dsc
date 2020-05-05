dCommander_Utility_Chat_Color:
  type: world
  events:
    on player chats:
    - if <player.has_permission[dcommander.utility.chatcolor]> || <pl.is_op>:
      - determine <context.message.parse_color>

dCommander_Utility_Sign_Color:
  type: world
  events:
    on player changes sign:
    - if <player.has_permission[dcommander.utility.signcolor]> || <player.is_op>:
      - determine <context.new.parse[parse_color].escape_contents>


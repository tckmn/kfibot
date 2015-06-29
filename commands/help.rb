cmd = gets.chomp

if cmd == ''
    puts 'Use !commands to get a list of builtin commands, and !help ' +
        '{command} for help on any one of these commands.'
else
    case cmd.downcase
    when 'learn'
        puts 'Manipulates the LearnDb. Use !help learn ADD, !help learn ' +
            'DEL, !help learn LIST, and !help learn RAW for more information.'
    when 'learn add'
        puts 'Add a term to the LearnDb. Example: after !learn ADD foo ' +
            '(some text), !foo results in "(some text)".'
    when 'learn del'
        puts 'Deletes a term from the LearnDb. Example: !learn DEL foo.'
    when 'learn list'
        puts 'Shows a list of user-defined commands (ones defined with ' +
            '!learn that are stored directly in the LearnDb).'
    when 'learn raw'
        puts 'Show the raw text from the LearnDb of a command, before ' +
            'substituting $COMMANDS.'
    when 'learnimpl', 'learnimpl add', 'learnimpl del'
        puts 'Use !learnimpl ADD foo to make !foo run the file called ' +
            'foo.rb; use !learnimpl DEL foo to undo this. Only usable by ' +
            'bot owner (KeyboardFire) because this can be dangerous.'
    when 'commands'
        puts 'Shows a list of built-in commands (ones defined with ' +
            '!learnimpl that have a native Ruby implementation).'
    when 'tell'
        puts 'Queue a message for a user that is not currently in the room: ' +
            '!tell {user} {some message}. Works with both nicks and ' +
            'registered users\' usernames (the one that shows up when you ' +
            '/whois someone).'
    when 'ruby'
        puts 'Eval Ruby code (in a safe sandbox).'
    when 'js'
        puts 'Eval JavaScript code (node.js, in a safe sandbox).'
    when 'priv'
        puts "Manipulates users' priviliges with certain commands. Takes " +
            "four options. The first is ADD or DEL (self-explanatory), " +
            "second is ALLOW or DISALLOW (also obvious), third is a " +
            "username (found via /whois, not a nick), a @groupname, @@all, " +
            "or @@registered, and fourth is a pattern used to decide when " +
            "the rule applies (for example, use a pattern of 'help*' to " +
            "allow or disallow users from using the help command)."
    when 'group', 'group add', 'group del', 'group list'
        puts 'Creates groups for use with !priv (see !help priv). Use ' +
            '!group ADD {groupname} {username} to add someone to a group ' +
            '(this must be the name found via /whois, not the nick), and ' +
            '!group DEL {groupname} {username} to do the reverse. !group ' +
            'LIST is self-explanatory.'
    when 'kick'
        puts 'Kick a user, !kick {nick}. Use !ban if you would also like ' +
            'the user to not be able to reenter the channel.'
    when 'op'
        puts 'Add or remove operator status for a user, !op {ADD|DEL} ' +
            '{nick}. To op yourself, use the shorthand form of just !op.'
    when 'voice'
        puts 'Give or take voice from a user, !voice {ADD|DEL} {nick}. To ' +
            'let only voiced users talk, use !voice ONLY ON, and !voice ' +
            'ONLY OFF to reverse this.'
    when 'mute'
        puts 'Mute or unmute a user, !mute {ADD|DEL} {mask}. To list all ' +
            'muted users, !mute LIST. See also !help mask.'
    when 'ban'
        puts 'Ban or unban a user, !ban {ADD|DEL} {mask}. To list all ' +
            'banned users, !ban LIST. See also !help mask.'
    when 'mask'
        puts 'A mask can be either a nick (MyNick) or a username ' +
            '(*!MyUserName).'
    when 'topic'
        puts 'Change the topic, !topic {text}.'
    when 'restart'
        puts 'Restarts the bot.'
    when 'help'
        puts "I'm So Meta, Even This Acronym"
    else
        puts "I don't know what #{cmd} means."
    end
end

cmd = gets.chomp

if cmd == ''
    puts 'Use !commands to get a list of builtin commands, and !help ' +
        '{command} for help on any one of these commands.'
else
    case cmd.downcase
    when 'learn'
        puts 'Manipulates the LearnDb. Use !help learn ADD, !help learn ' +
            'DEL, and !help learn LIST for more information.'
    when 'learn add'
        puts 'Add a term to the LearnDb. Example: after !learn ADD foo ' +
            '(some text), !foo results in "(some text)".'
    when 'learn del'
        puts 'Deletes a term from the LearnDb. Example: !learn DEL foo.'
    when 'learn list'
        puts 'Shows a list of user-defined commands (ones defined with ' +
            '!learn that are stored directly in the LearnDb).'
    when 'learnimpl', 'learnimpl add', 'learnimpl del'
        puts 'Use !learnimpl ADD foo to make !foo run the file called ' +
            'foo.rb; use !learnimpl DEL foo to undo this. Only usable by ' +
            'bot owner (KeyboardFire) because this can be dangerous.'
    when 'commands'
        puts 'Shows a list of built-in commands (ones defined with ' +
            '!learnimpl that have a native Ruby implementation).'
    when 'restart'
        puts 'Restarts the bot.'
    when 'help'
        puts "I'm So Meta, Even This Acronym"
    else
        puts "I don't know what #{cmd} means."
    end
end

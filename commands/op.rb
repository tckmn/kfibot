action, nick = gets.chomp.split ' ', 2

action.downcase! if action

if action.nil?
    puts '$REQUEST_CHANNEL'
    STDOUT.flush
    chan = gets.chomp

    puts '$REQUEST_NICK'
    STDOUT.flush
    nick = gets.chomp

    puts "$REQUEST_SEND_CMD mode #{chan} +o #{nick}"
elsif (action != 'add' && action != 'del') || nick.nil? || nick.index(' ')
    puts 'usage: !op {ADD|DEL} {nick}'
else
    puts '$REQUEST_CHANNEL'
    STDOUT.flush
    chan = gets.chomp

    puts "$REQUEST_SEND_CMD mode #{chan} #{action == 'add' ? ?+ : ?-}o #{nick}"
end

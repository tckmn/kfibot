nick = gets.chomp

if nick.nil? || nick == '' || nick.index(' ')
    puts 'usage: !kick {nick}'
else
    puts '$REQUEST_CHANNEL'
    STDOUT.flush
    chan = gets.chomp

    puts "$REQUEST_SEND_CMD kick #{chan} #{nick}"
end

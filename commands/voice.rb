args = gets.chomp

puts '$REQUEST_CHANNEL'
STDOUT.flush
chan = gets.chomp

case args
when ''
    puts '$REQUEST_CHANNEL'
    STDOUT.flush
    chan = gets.chomp

    puts '$REQUEST_NICK'
    STDOUT.flush
    nick = gets.chomp

    puts "$REQUEST_SEND_CMD mode #{chan} +v #{nick}"
when /^(add|del) ([^ ]+)$/i
    add = $1.downcase == 'add'
    puts "$REQUEST_SEND_CMD mode #{chan} #{add ? ?+ : ?-}v #{$2}"
when /^only (on|off)$/i
    puts "$REQUEST_SEND_CMD mode #{chan} #{$1.downcase == 'on' ? ?+ : ?-}m"
else
    puts 'usage: !voice {ADD|DEL} {nick} or !voice ONLY {ON|OFF}'
end

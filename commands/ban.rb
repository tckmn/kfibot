args = gets.chomp

puts '$REQUEST_CHANNEL'
STDOUT.flush
chan = gets.chomp

case args
when /^(add|del) ([^ ]+)$/i
    add = $1.downcase == 'add'
    puts "$REQUEST_SEND_CMD mode #{chan} #{add ? ?+ : ?-}b #{$2}"
when /^list$/i
    puts 'list of banned users:'
    puts '$REQUEST_EVAL $echo_bans = true'
    puts "$REQUEST_SEND_CMD mode #{chan} +b"
else
    puts 'usage: !ban {ADD|DEL} {mask} or !ban LIST'
end

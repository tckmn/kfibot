topic = gets.chomp

if topic.nil? || topic == ''
    puts 'usage: !topic {text}'
else
    puts '$REQUEST_CHANNEL'
    STDOUT.flush
    chan = gets.chomp

    topic.gsub! ' ', '_'

    puts "$REQUEST_SEND_CMD topic #{chan} #{topic}"
end

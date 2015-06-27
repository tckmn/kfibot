require 'sqlite3'

db = SQLite3::Database.new 'learn.db'

to_user, msg = gets.chomp.split ' ', 2

puts '$REQUEST_NICK'
STDOUT.flush
from_user = gets.chomp

if to_user.nil? || msg.nil?
    puts 'usage: !tell {user} {some message}'
else
    db.execute 'insert into Tell values (?, ?, ?)', [to_user, from_user, msg]
    puts "ok, I'll let #{to_user} know."
end

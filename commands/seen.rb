require 'sqlite3'

db = SQLite3::Database.new 'learn.db'

user = gets.chomp

if user.nil? || user == ''
    puts 'usage: !seen {username}'
else
    seen = db.execute('select seen, message from Seen where user = ?', user)
    if seen.length > 0
        seen, message = seen[0]
        puts seen
        if message != seen
            puts "last message: #{message}"
        end
    else
        puts "I haven't seen #{user} anywhere."
    end
end


require 'sqlite3'

db = SQLite3::Database.new 'learn.db'

action, key = gets.chomp.split ' ', 2

puts '$REQUEST_WHOIS'
STDOUT.flush
whois = gets.chomp

USAGE_MSG = 'usage: !learnimpl {ADD|DEL} {key}'

if whois == 'KeyboardFire'
    if key.nil? || key.index(' ')
        puts USAGE_MSG
    else
        case action.downcase
        when 'add'
            if db.execute('select count(*) from LearnDb where key = ?', key)[0][0] == 0
                db.execute 'insert into LearnDb values (?, "$RUBY_IMPL")', key
                puts "key #{key} successfully added to LearnDb"
            else
                puts "key #{key} already exists in LearnDb!"
            end
        when 'del'
            val = db.execute('select val from LearnDb where key = ?', key)[0]
            if val
                if val[0] == '$RUBY_IMPL'
                    db.execute 'delete from LearnDb where key = ?', key
                    puts "key #{key} successfully deleted from LearnDb"
                else
                    puts "key #{key} does not have val of $RUBY_IMPL - use !learn instead"
                end
            else
                puts "key #{key} does not exist in LearnDb!"
            end
        else
            puts USAGE_MSG
        end
    end
else
    puts 'Only KeyboardFire may execute that command.'
end

require 'sqlite3'

db = SQLite3::Database.new 'learn.db'

action, key, val = gets.chomp.split ' ', 3

USAGE_MSG = 'usage: !learn ADD {key} {val} or !learn DEL {key} or !learn LIST or !learn RAW {key}'

case action ? action.downcase : nil
when 'add'
    if key.nil? || val.nil?
        puts USAGE_MSG
    else
        if val == '$RUBY_IMPL'
            puts '$RUBY_IMPL is dangerous - use !learnimpl instead'
        else
            if db.execute('select count(*) from LearnDb where key = ?', key)[0][0] == 0
                db.execute 'insert into LearnDb values (?, ?)', [key, val]
                puts "key #{key} successfully added to LearnDb"
            else
                puts "key #{key} already exists in LearnDb!"
            end
        end
    end
when 'del'
    if key.nil? || !val.nil?
        puts USAGE_MSG
    else
        val = db.execute('select val from LearnDb where key = ?', key)[0]
        if val
            if val[0] == '$RUBY_IMPL'
                puts 'cannot delete key with val of $RUBY_IMPL - use !learnimpl instead'
            else
                db.execute 'delete from LearnDb where key = ?', key
                puts "key #{key} successfully deleted from LearnDb"
            end
        else
            puts "key #{key} does not exist in LearnDb!"
        end
    end
when 'list'
    if !key.nil?
        puts USAGE_MSG
    else
        print 'list of user-defined commands: '
        puts db.execute('select key from LearnDb where val != "$RUBY_IMPL"')
            .map(&:first) * ', '
        puts 'for a list of builtin commands, use !commands'
    end
when 'raw'
    if key.nil? || !val.nil?
        puts USAGE_MSG
    else
        puts db.execute('select val from LearnDb where key = ?', key)[0]
    end
else
    puts USAGE_MSG
end

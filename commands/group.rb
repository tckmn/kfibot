require 'sqlite3'

db = SQLite3::Database.new 'learn.db'

args = gets.chomp

case args
when /^(add|del) [^ ]+ [^ ]+$/i
    action, group, nick = args.split
    if action.downcase == 'add'
        if db.execute('select count(*) from Groups where user = ? and ' +
            'group_name = ?', [nick, group])[0][0] == 0
            db.execute('insert into Groups values (?, ?)', [nick, group])
            puts "user #{nick} successfully added to group #{group}"
        else
            puts "user #{nick} is already in group #{group}!"
        end
    else
        if db.execute('select count(*) from Groups where user = ? and ' +
            'group_name = ?', [nick, group])[0][0] == 0
            puts "user #{nick} is not in group #{group}!"
        else
            db.execute('delete from Groups where user = ? and group_name = ?',
                [nick, group])
            puts "user #{nick} successfully deleted from group #{group}"
        end
    end
when /^list$/i
    print 'list of groups and members: '
    puts db.execute('select DISTINCT group_name from Groups').map{|g|
        "group #{g[0]}: " + db.execute('select user from Groups where ' +
            'group_name = ?', g[0]).map(&:first).join(', ')
    }.join('; ')
else
    puts 'usage: !group {ADD|DEL} {groupname} {member} or !group LIST'
end

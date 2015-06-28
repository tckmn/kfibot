require 'sqlite3'

db = SQLite3::Database.new 'learn.db'

args = gets.chomp

case args
when /^(add|del) (allow|disallow) @?@?[^ ]+ .+$/i
    action, _target, target, *match = args.split
    target = _target + ' ' + target
    match = match.join(' ').downcase
    if action.downcase == 'add'
        if db.execute('select count(*) from Privileges where privilege = ? ' +
            'and match = ?', [target, match])[0][0] == 0
            db.execute('insert into Privileges values (?, ?)', [target, match])
            puts 'privilege and match successfully added'
        else
            puts 'that privilege and match already exists!'
        end
    else
        if db.execute('select count(*) from Privileges where privilege = ? ' +
            'and match = ?', [target, match])[0][0] == 0
            puts "that privilege and match doesn't exist!"
        else
            db.execute('delete from Privileges where privilege = ? and ' +
                'match = ?', [target, match])
            puts 'privilege and match successfully deleted'
        end
    end
when /^list$/i
    print 'list of privilege rules and matches: '
    puts db.execute('select privilege, match from Privileges').map{|p, m|
        "'#{p}' for '#{m}'"
    }.join(', ')
else
    puts 'usage: !priv {ADD|DEL} {ALLOW|DISALLOW} {username|@group|' +
        '@@registered|@@all} {match} or !priv LIST'
end

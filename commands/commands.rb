require 'sqlite3'

db = SQLite3::Database.new 'learn.db'

print 'list of builtin commands: '
puts (db.execute('select key from LearnDb where val = "$RUBY_IMPL"')
    .map(&:first) + ['restart']) * ', '
puts 'for a list of user-defined commands, use !learn list'

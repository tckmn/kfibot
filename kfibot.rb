#!/usr/bin/ruby

require 'cinch'
require 'cinch/plugins/identify'
require 'sqlite3'
require 'open3'

require_relative 'config.rb'

# a bunch of ugly hacks...
$config[:logfile] = File.open($config[:logfile], 'a+')
class Cinch::Callback
    def logf txt
        $config[:logfile].puts txt
        $config[:logfile].flush  # FOR DEBUGGING ONLY!!!!!
    end

    def reply m, txt, suppress_ping=false
        if txt.length > 800
            m.reply 'Max message length (800) reached. Truncated response shown below:'
            txt = txt[0..800]
        end
        txt = "#{m.user.nick}: " + txt unless suppress_ping
        logf "[#{m.time}] <#{$config[:nick]}> #{txt}"
        m.reply txt
    end
end
$whois_return = nil
$whois_cache = {}
class Cinch::IRC
    alias old_on_318 on_318
    alias old_on_330 on_330
    def on_318 msg, events
        $whois_return = [nil, nil, nil, nil] unless $whois_return
        old_on_318 msg, events
    end
    def on_330 msg, events
        $whois_return = msg.params
        old_on_330 msg, events
    end
end
def query_whois user
    return $whois_cache[user] if $whois_cache[user]
    $whois_return = nil
    bot.irc.send "whois #{user}"
    sleep 0.1 until $whois_return
    $whois_cache[user] = $whois_return[2]
    $whois_return = nil
    $whois_cache[user]
end

bot = Cinch::Bot.new do
    prefix = '!'

    configure do |c|
        c.server = 'irc.freenode.org'
        c.nick = $config[:nick]
        c.channels = []
        c.plugins.plugins = [Cinch::Plugins::Identify]
        c.plugins.options[Cinch::Plugins::Identify] = {
            :username => $config[:nick],
            :password => $config[:password],
            :type => :nickserv
        }
    end

    db = SQLite3::Database.new 'learn.db'

    creating_learndb = db.execute <<-SQL
        select count(*)
        from sqlite_master
        where
            type = "table" and
            name = "LearnDb"
    SQL
    creating_learndb = creating_learndb[0][0] == 0

    db.execute <<-SQL
        create table if not exists LearnDb (
            key TEXT, val TEXT
        );
    SQL
    db.execute <<-SQL
        create table if not exists Tell (
            to_user TEXT, from_user TEXT, msg TEXT
        );
    SQL
    db.execute <<-SQL
        create table if not exists Privileges (
            privilege TEXT, match TEXT
        );
    SQL
    db.execute <<-SQL
        create table if not exists Groups (
            user TEXT, group_name TEXT
        );
    SQL
    if creating_learndb
        Dir["#{File.expand_path(File.dirname(__FILE__))}/commands/*.rb"].each do |f|
            cmd_name = f.match(/\/([^.\/]+).rb$/)
            if cmd_name
                db.execute 'insert into LearnDb values (?, "$RUBY_IMPL")', cmd_name[1]
            end
        end
        # sample user-defined command
        db.execute 'insert into LearnDb values ("choose", "$CHOOSE($0(|))")'
    end

    on :message, /(.*)/ do |m, txt|
        logf "[#{m.time}] <#{m.user.nick}> #{txt}"

        suppress_unknown = false

        # try to automatically answer 1-3 word questions
        q = txt.match(/
                ^w[\w']+(?:\s+(?:is|are))?(?:\s+(?:the|a))?\s+(?<q>[^ ]+?)\?*$|
                ^(?:(?:the|a)\s+)?(?<q>[^ ]+)\?+$
            /xi)
        if q
            txt = "!#{q['q']}?"
            suppress_unknown = true
        end

        if txt[0...prefix.length] == prefix
            txt = txt[prefix.length..-1]
            cmd, args = txt.split ' ', 2
            if cmd == 'restart'  # special-case
                reply m, 'restarting bot...'
                bot.quit("restarting (restarted by #{m.user.nick})")
                sleep 0.1 while bot.quitting
                # you're supposed to run this in a loop
                # while :; do ./kfibot.rb; done
            end
            unless cmd.nil?  # message might consist of only prefix...
                # check if user is allowed to run this command
                w = query_whois m.user.nick
                groups = db.execute('select group_name from Groups where ' +
                    'user = ?', w).map(&:first)
                privs = db.execute('select privilege, match from Privileges ' +
                    'where ? glob match', cmd)
                allow = (privs.find{|p| !p[0].index('@') && p[0].split[1] == w } ||
                    privs.find{|p| !p[0].index('@@') && groups.index(p[0].split[1][1..-1]) } ||
                    privs.find{|p| p[0].index('@@registered') && w } ||
                    privs.find{|p| p[0].index('@@all') } ||
                    ['allow'])

                val = if allow[0].split[0].downcase == 'disallow'
                    reply m, 'you are not allowed to execute this command ' +
                        "(rule: '#{allow[0]}' for match '#{allow[1]}')"
                    suppress_unknown = true
                    nil
                else
                    db.execute('select val from LearnDb where key = ?', cmd).first
                end

                if val.nil?
                    reply m, "unknown command #{cmd}" unless suppress_unknown
                else
                    val = val.first
                    if val == '$RUBY_IMPL'
                        Open3.popen3("ruby commands/#{cmd}.rb") do |stdin, stdout, stderr|
                            stdin.puts args
                            while line = stdout.gets
                                line = line.chomp
                                case line
                                when '$REQUEST_NICK'
                                    stdin.puts m.user.nick
                                when '$REQUEST_WHOIS'
                                    stdin.puts query_whois m.user.nick
                                else
                                    reply m, line
                                end
                            end
                            stdin.close_write
                        end
                    else
                        args = args ? args.split : []
                        (1..9).each do |i|
                            val.gsub!(/\$#{i}\(([^)]+)\)/) { args[i-1] || $1 }
                            val.gsub!("$#{i}") { args[i-1] }
                        end
                        val.gsub!(/\$0\(([^)]+)\)/) { args.join $1 }
                        val.gsub!('$0', args.join(' '))
                        val.gsub!(/\$CHOOSE\(([^)]+)\)/) { $1.split('|').sample }
                        val.gsub!('$NICK', m.user.nick)
                        reply m, val
                    end
                end
            end
        end
    end

    on :notice do |m|
        if m.message.index 'You are now identified for'
            $config[:channels].each do |c|
                bot.join c
            end
        end
    end

    on :nick do |m|
        old, new = m.raw.match(/^:([^!]+)!/)[1], m.user.nick
        if $whois_cache[old]
            $whois_cache[new] = $whois_cache[old]
            $whois_cache.delete old
        end
        logf "[#{m.time}] -!- #{old} is now known as #{new}"
    end

    on :join do |m|
        logf "[#{m.time}] -!- #{m.user.nick} has joined"
        if m.user.nick == $config[:nick]
            reply m, 'Bot started.', true
        else
            reply m, 'welcome! I am a robit, beep boop. Type !help to get ' +
                'assistance on how to use me.'
            w = query_whois m.user.nick
            db.execute('select from_user, msg from Tell where to_user = ? or to_user = ?',
                [m.user.nick, w]).each do |from_user, msg|
                reply m, "you have a message from #{from_user}: #{msg}"
            end
            db.execute('delete from Tell where to_user = ? or to_user = ?', [m.user.nick, w])
        end
    end

    on :leaving do |m|
        if m.params.length == 3
            logf "[#{m.time}] -!- #{m.user.nick} was kicked from " +
                "#{m.params[0]} by #{m.params[1]} (#{m.params[2]})"
        else
            logf "[#{m.time}] -!- #{m.user.nick} has left (#{m.params[0]})"
        end
        $whois_cache.delete m.user.nick
    end
end

bot.start

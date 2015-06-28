require 'shellwords'

code = gets.chomp

code = Shellwords.escape code
code.gsub!("'", "'\"'\"'")

puts `nodejs -e 'var Sandbox = require("/usr/local/lib/node_modules/sandbox"), s = new Sandbox(); s.options.timeout = 2000; s.run("#{code}", function(x) { console.log(x.result == "TimeoutError" ? "2 second timeout reached." : x.result); });'`

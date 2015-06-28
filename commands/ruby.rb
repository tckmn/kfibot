code = gets.chomp

mthread = nil
Thread.new {
    sleep 2
    mthread[:evalResult] = '2 second timeout reached.'
    mthread.kill
}
mthread = Thread.new {
    result = begin
        def doIt code
            $SAFE = 4
            eval code
        end
        doIt code
    rescue Exception => e
        "Error in eval: #{e}"
    end
    mthread[:evalResult] = result
}
mthread.join
puts String(mthread[:evalResult])

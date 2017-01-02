local Pack = require 'pack'

function love.load(arg)
    local source = arg[2]
    local output = arg[3] or 'out'

    Pack(source, output)
    love.event.push('quit')
end

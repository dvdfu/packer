local Pack = require 'pack'

function love.load(arg)
    local source = arg[1]
    local output = arg[2] or 'out'

    Pack(source, output)
    love.event.push('quit')
end

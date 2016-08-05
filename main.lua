local Pack = require 'pack'

local image

function love.load(arg)
    local source = arg[2]
    local output = arg[3] or 'out'

    local atlas = Pack(source, output)
    love.window.setMode(atlas.size, atlas.size)
    image = love.graphics.newImage(atlas.image)
end

function love.draw()
    love.graphics.draw(image)
end

function love.keypressed()
    love.event.push('quit')
end

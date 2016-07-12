local Pack = require 'pack'

local canvas

function love.load(arg)
    local source = arg[2]
    local output = arg[3] or 'out'

    local atlas = Pack(source)

    love.window.setMode(atlas.size, atlas.size)

    canvas = love.graphics.newCanvas(atlas.size, atlas.size, 'rgba8', 0)
    love.graphics.setCanvas(canvas)
    for _, item in pairs(atlas.layout) do
        love.graphics.draw(atlas.images[item.name], item.x, item.y)
    end
    love.graphics.setCanvas()

    local data = canvas:newImageData()
    data:encode('png', output..'.png')
end

function love.draw()
    love.graphics.draw(canvas)
end

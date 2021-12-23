--imports atlas.lua from the libs folder
Atlas = require "libs/atlas"

--sets filter to 'nearest'
love.graphics.setDefaultFilter("nearest", "nearest")

function love.load()

    --loads atlas into the 'atlas' variable
    atlas = Atlas.load('assets/sprites/chiki')

    --fetches the 'idle.png' sprite and sets it to chikiIdle variable
    chikiIdle = atlas:newSprite('idle.png')

    --fetches the varies animations and sets them to the appropiate variable
    chikiDance = atlas:newAnimation('dance.png', 2, 0.5)
    chikiWalk = atlas:newAnimation('walk.png', 3, 0.15)

end

function love.update(dt)

    --updates each animation
    chikiWalk:update(dt)
    chikiDance:update(dt)

end

function love.draw()

    --sets scale
    love.graphics.scale(config.scale, config.scale)

    --sets background color
    love.graphics.setBackgroundColor(99/255, 155/255, 155/255, 1)

    --draws out each sprite and animation
    chikiIdle:draw(10, 10)
    chikiWalk:draw(20, 10)
    chikiDance:draw(30, 10)

end
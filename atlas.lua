local Atlas = {}

function Atlas.load(filename)
    local image = love.graphics.newImage(filename..'.png')
    local data = require(filename)

    local sw, sh = image:getDimensions()
    local quads = {}

    for sprite, rect in pairs(data) do
        quads[rect.name] = love.graphics.newQuad(rect.x, rect.y, rect.w, rect.h, sw, sh)
    end

    local atlas = {
        draw = function(sprite, x, y, r, sx, sy, ox, oy, kx, ky)
            love.graphics.draw(image, quads[sprite], x, y, r, sx, sy, ox, oy, kx, ky)
        end
    }
    return atlas
end

return Atlas

local Sprite = {}

function Sprite.new(source, quad)
    return {
        source = source,
        quad = quad,
        draw = function(self, x, y, r, sx, sy, ox, oy, kx, ky)
            love.graphics.draw(self.source, self.quad, math.floor(x), math.floor(y), r, sx, sy, ox, oy, kx, ky)
        end
    }
end

local Atlas = {}

function Atlas.load(filename)
    local image = love.graphics.newImage(filename..'.png')
    local data = require(filename)

    local sw, sh = image:getDimensions()
    local quads = {}

    for sprite, rect in pairs(data.images) do
        quads[rect.name] = love.graphics.newQuad(
            rect.x + data.padding,
            rect.y + data.padding,
            rect.w - data.padding * 2,
            rect.h - data.padding * 2,
            sw, sh)
    end

    local atlas = {
        data = data.images,
        image = image,
        quads = quads,
        quadSplit = function(self, sprite, n)
            local x, y, w, h = self.quads[sprite]:getViewport()
            local row = {}
            for i = 1, n do
                row[i] = love.graphics.newQuad(x + (i - 1) * w / n, y, w / n, h, sw, sh)
            end
            return row
        end,
        draw = function(self, sprite, x, y, r, sx, sy, ox, oy, kx, ky)
            love.graphics.draw(image, self.quads[sprite], x, y, r, sx, sy, ox, oy, kx, ky)
        end,
        newSprite = function(self, name)
            assert(self.quads[name])
            return Sprite.new(self.image, self.quads[name])
        end
    }
    return atlas
end

return Atlas

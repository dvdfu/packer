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
        end
    }
    return atlas
end

return Atlas

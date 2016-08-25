function Sprite(source, quad)
    return {
        source = source,
        quad = quad,
        getQuad = function(self)
            return self.quad
        end,
        draw = function(self, x, y, r, sx, sy, ox, oy, kx, ky)
            love.graphics.draw(self.source, self.quad, math.floor(x), math.floor(y), r, sx, sy, ox, oy, kx, ky)
        end
    }
end

function Animation(source, quads, framerate)
    return {
        source = source,
        quads = quads,
        framerate = framerate,
        timer = 0,
        frame = 1,
        getQuads = function(self)
            return self.quads
        end,
        update = function(self, dt)
            self.timer = self.timer + dt
            while self.timer > self.framerate do
                self.timer = self.timer - self.framerate
                self.frame = self.frame + 1
                if self.frame > #self.quads then
                    self.frame = self.frame - #self.quads
                end
            end
        end,
        draw = function(self, x, y, r, sx, sy, ox, oy, kx, ky)
            local quad = self.quads[self.frame]
            love.graphics.draw(self.source, quad, math.floor(x), math.floor(y), r, sx, sy, ox, oy, kx, ky)
        end
    }
end

local Atlas = {}

function Atlas.load(filename)
    local image = love.graphics.newImage(filename .. '.png')
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
        draw = function(self, sprite, x, y, r, sx, sy, ox, oy, kx, ky)
            love.graphics.draw(image, self.quads[sprite], x, y, r, sx, sy, ox, oy, kx, ky)
        end,
        newSprite = function(self, name)
            assert(self.quads[name])
            return Sprite(self.image, self.quads[name])
        end,
        newAnimation = function(self, name, n, framerate)
            assert(self.quads[name])
            local x, y, w, h = self.quads[name]:getViewport()
            local quads = {}
            for i = 1, n do
                quads[i] = love.graphics.newQuad(x + (i - 1) * w / n, y, w / n, h, sw, sh)
            end
            return Animation(self.image, quads, framerate)
        end
    }
    return atlas
end

return Atlas

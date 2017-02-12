function Sprite(source, quad)
    return {
        source = source,
        quad = quad,
        getQuad = function(self)
            return self.quad
        end,
        draw = function(self, x, y, r, sx, sy, ox, oy, kx, ky)
            love.graphics.draw(self.source, self.quad, x, y, r, sx, sy, ox, oy, kx, ky)
        end
    }
end

function Animation(source, quads, framerate)
    return {
        source = source,
        quads = quads,
        framerate = framerate,
        tick = 0,
        frame = 1,
        played = false,
        getQuads = function(self)
            return self.quads
        end,
        setFramerate = function(self, framerate)
            self.framerate = framerate
        end,
        setFrame = function(self, frame)
            self.frame = (frame - 1) % #self.quads + 1
            self.tick = 0
        end,
        getFrame = function(self)
            return self.frame
        end,
        reset = function(self)
            self.frame = 0
            self.tick = 0
            self.played = false
        end,
        hasPlayed = function(self)
            return self.played
        end,
        update = function(self, dt)
            self.tick = self.tick + dt
            while self.tick > self.framerate do
                self.tick = self.tick - self.framerate
                self.frame = self.frame + 1
                if self.frame > #self.quads then
                    self.frame = self.frame - #self.quads
                    self.played = true
                end
            end
            while self.tick < 0 do
                self.tick = self.tick + self.framerate
                self.frame = self.frame - 1
                if self.frame < 1 then
                    self.frame = self.frame + #self.quads
                end
            end
        end,
        draw = function(self, x, y, r, sx, sy, ox, oy, kx, ky)
            local quad = self.quads[self.frame]
            love.graphics.draw(self.source, quad, x, y, r, sx, sy, ox, oy, kx, ky)
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

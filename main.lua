local layout = {}
local sprites = {}
local cells

local size = 256
local canvas

function love.load(arg)
    local source = arg[2]
    local output = arg[3]

    assert(source, 'Must specify a source directory to pack!')

    local files = love.filesystem.getDirectoryItems(source)
    print('Loaded '..#files..' sprites.')

    for _, file in pairs(files) do
        -- TODO recursive
        -- TODO check file type
        local image = love.graphics.newImage(source..'/'..file)
        table.insert(sprites, {
            image = image,
            file = file,
            w = image:getWidth(),
            h = image:getHeight()
        })
    end

    table.sort(sprites, function(a, b)
        return area(a) > area(b)
    end)

    -- for name, sprite in pairs(sprites) do
    --     print(sprite.w * sprite.h, name)
    -- end

    cells = { { x = 0, y = 0, w = size, h = size } }

    for _, sprite in pairs(sprites) do
        pack(sprite)
    end

    canvas = love.graphics.newCanvas(size, size, 'rgba8', 0)
    love.graphics.setCanvas(canvas)

    for _, item in pairs(layout) do
        love.graphics.draw(item.image, item.x, item.y)
    end
    love.graphics.setCanvas()
end

function area(item)
    return item.w * item.h
end

function pack(sprite)
    for i, cell in pairs(cells) do
        if fits(sprite, cell) then
            cells[i] = nil

            table.insert(layout, {
                image = sprite.image,
                file = sprite.file,
                x = cell.x,
                y = cell.y
            })

            local c1 = {
                x = cell.x + sprite.w,
                y = cell.y,
                w = cell.w - sprite.w,
                h = sprite.h
            }

            local c2 = {
                x = cell.x,
                y = cell.y + sprite.h,
                w = cell.w,
                h = cell.h - sprite.h
            }

            if area(c2) > 0 then table.insert(cells, c2) end
            if area(c1) > 0 then table.insert(cells, c1) end
            return
        end
    end
end

function fits(sprite, cell)
    return sprite.w <= cell.w and sprite.h <= cell.h
end

function love.update(dt) end

function love.draw()
    love.graphics.rectangle('line', 0, 0, size, size)
    love.graphics.draw(canvas)
end

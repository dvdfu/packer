local images = {}
local layout = {}
local cells = {}

-- TODO variable size
local size = 512
local canvas

function love.load(arg)
    love.window.setMode(size, size)
    local source = arg[2]
    local output = arg[3] or 'test'

    assert(source, 'Must specify a source directory to pack!')

    local sprites = {}
    loadFiles(source, sprites)

    table.sort(sprites, function(a, b)
        return area(a) > area(b)
    end)

    table.insert(cells, { x = 0, y = 0, w = size, h = size })

    for _, sprite in pairs(sprites) do
        pack(sprite)
    end

    -- TODO specify image format
    canvas = love.graphics.newCanvas(size, size, 'rgba8', 0)
    love.graphics.setCanvas(canvas)
    for _, item in pairs(layout) do
        love.graphics.draw(images[item.name], item.x, item.y)
    end
    love.graphics.setCanvas()

    local data = canvas:newImageData()
    data:encode('png', output..'.png')
end

function loadFiles(folder, sprites)
    local files = love.filesystem.getDirectoryItems(folder)
    for _, name in pairs(files) do
        -- TODO validate image extensions
        if love.filesystem.isDirectory(folder..'/'..name) then
            print('entering directory '..name)
            loadFiles(folder..'/'..name, sprites)
        else
            local ext = string.match(name, '^.+%.(.+)$')
            assert(validExtension(ext), 'Found invalid file '..name)
            local image = love.graphics.newImage(folder..'/'..name)
            images[name] = image
            table.insert(sprites, {
                name = name,
                w = image:getWidth(),
                h = image:getHeight()
            })
        end
    end
end

function area(item)
    return item.w * item.h
end

function pack(sprite)
    for i, cell in pairs(cells) do
        if fits(sprite, cell) then
            cells[i] = nil

            table.insert(layout, {
                name = sprite.name,
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

            if area(c1) > 0 then table.insert(cells, c1) end
            if area(c2) > 0 then table.insert(cells, c2) end
            return
        end
    end
end

function fits(sprite, cell)
    return sprite.w <= cell.w and sprite.h <= cell.h
end

function validExtension(ext)
    local extensions = {
        png = 1,
        jpg = 1,
        gif = 1,
        bmp = 1,
    }
    return extensions[ext]
end

function love.update(dt) end

function love.draw()
    love.graphics.draw(canvas)
end

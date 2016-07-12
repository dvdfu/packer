function Pack(source, output)
    assert(source, 'Must specify a source directory to pack!')
    assert(output, 'Must specify an output file name!')

    local self = {
        images = {},
        rects = {},
        cells = {},
        layout = {},
        size = 512
    }

    table.insert(self.cells, { x = 0, y = 0, w = self.size, h = self.size })

    loadFolder(self, source)

    table.sort(self.rects, function(a, b)
        return getArea(a) > getArea(b)
    end)

    for _, rect in pairs(self.rects) do
        pack(self, rect)
    end

    local image = toImage(self):newImageData()
    local text = toText(self)

    image:encode('png', output..'.png')
    love.filesystem.write(output..'.lua', text)

    return {
        image = image,
        text = text,
        size = self.size
    }
end

function loadFolder(self, folder)
    local files = love.filesystem.getDirectoryItems(folder)
    for _, name in pairs(files) do
        if love.filesystem.isDirectory(folder..'/'..name) then
            loadFolder(self, folder..'/'..name)
        elseif isExtensionValid(name) then
            local image = love.graphics.newImage(folder..'/'..name)
            self.images[name] = image
            table.insert(self.rects, {
                name = name,
                w = image:getWidth(),
                h = image:getHeight()
            })
        else
            print('Ignoring file, bad extension: '..name)
        end
    end
end

function pack(self, rect)
    for i, cell in pairs(self.cells) do
        if isFit(rect, cell) then

            table.insert(self.layout, {
                name = rect.name,
                x = cell.x,
                y = cell.y,
                w = rect.w,
                h = rect.h
            })

            local cell1 = {
                x = cell.x + rect.w,
                y = cell.y,
                w = cell.w - rect.w,
                h = rect.h
            }

            local cell2 = {
                x = cell.x,
                y = cell.y + rect.h,
                w = cell.w,
                h = cell.h - rect.h
            }

            self.cells[i] = nil
            if getArea(cell1) > 0 then table.insert(self.cells, cell1) end
            if getArea(cell2) > 0 then table.insert(self.cells, cell2) end
            return true
        end
    end

    print('Could not fit '..rect.name)
    return false
end

function isExtensionValid(filename)
    local ext = string.match(filename, '^.+%.(.+)$')
    local extensions = {
        png = 1,
        bmp = 1,
        jpg = 1,
        jpeg = 1,
        gif = 1,
    }
    return extensions[ext]
end

function isFit(rect, cell)
    return rect.w <= cell.w and rect.h <= cell.h
end

function getArea(item)
    return item.w * item.h
end

function toText(self)
    local text = '{'
    for _, item in pairs(self.layout) do
        text = text..'{name='..item.name..',x='..item.x..',y='..item.y..',w='..item.w..',h='..item.h..'},'
    end
    text = text..'}'
    return text
end

function toImage(self)
    local canvas = love.graphics.newCanvas(self.size, self.size, 'rgba8', 0)
    canvas:renderTo(function()
        for _, item in pairs(self.layout) do
            love.graphics.draw(self.images[item.name], item.x, item.y)
        end
    end)
    return canvas
end

return Pack

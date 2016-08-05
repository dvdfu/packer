function Pack(source, output)
    assert(source, 'Must specify a source directory to pack!')
    assert(output, 'Must specify an output file name!')

    local self = {
        images = {},
        rects = {},
        cells = {},
        layout = {},
        fileCount = 0,
        width = 128,
        height = 128
    }

    table.insert(self.cells, { x = 0, y = 0, w = self.width, h = self.height })

    loadFolder(self, source)
    print('Loaded '..self.fileCount..' sprites from '..source..'/')

    table.sort(self.rects, function(a, b)
        return getArea(a) > getArea(b)
    end)

    for _, rect in pairs(self.rects) do
        pack(self, rect)
    end

    local image = toImage(self):newImageData()
    local text = toText(self)
    local dir = love.filesystem.getSaveDirectory()

    image:encode('png', output..'.png')
    print('Saved '..dir..'/'..output..'.png')
    love.filesystem.write(output..'.lua', text)
    print('Saved '..dir..'/'..output..'.lua')

    return {
        image = image,
        text = text,
        size = getSquareSize(self)
    }
end

function loadFolder(self, folder)
    local files = love.filesystem.getDirectoryItems(folder)
    for _, name in pairs(files) do
        local fullPath = folder..'/'..name
        local pos = string.find(fullPath, '/')
        local path = string.sub(fullPath, pos + 1)
        if love.filesystem.isDirectory(fullPath) then
            loadFolder(self, fullPath)
        elseif isExtensionValid(name) then
            local image = love.graphics.newImage(fullPath)
            self.images[path] = image
            self.fileCount = self.fileCount + 1
            table.insert(self.rects, {
                name = path,
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

function getSquareSize(self)
    local i = 1
    local s = math.max(self.width, self.height)
    while i < s do
        i = i * 2
    end
    return i
end

function toText(self)
    local text = 'return {'
    for _, item in pairs(self.layout) do
        text = text..'{name="'..item.name..'",x='..item.x..',y='..item.y..',w='..item.w..',h='..item.h..'},'
    end
    text = text..'}'
    return text
end

function toImage(self)
    local size = getSquareSize(self)
    local canvas = love.graphics.newCanvas(size, size, 'rgba8', 0)
    canvas:renderTo(function()
        for _, item in pairs(self.layout) do
            love.graphics.draw(self.images[item.name], item.x, item.y)
        end
    end)
    return canvas
end

return Pack

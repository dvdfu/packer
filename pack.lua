function Pack(source, output)
    assert(source, 'Must specify a source directory to pack!')
    assert(output, 'Must specify an output file name!')

    local self = {
        images = {}, -- map filename to image data
        rects = {},  -- array of filenames and image dimensions
        cells = {},  -- array of open cells for placement
        layout = {}, -- array of filenames and placement information
        fileCount = 0,
        initialized = false,
        width = 0,
        height = 0,
        padding = 2
    }

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
                w = image:getWidth() + self.padding * 2,
                h = image:getHeight() + self.padding * 2
            })
        else
            print('Ignoring file, bad extension: '..name)
        end
    end
end

function pack(self, rect)
    if not self.initialized then
        table.insert(self.cells, {
            x = 0,
            y = 0,
            w = rect.w,
            h = rect.h
        })

        self.initialized = true
        self.width = rect.w
        self.height = rect.h
        return pack(self, rect)
    end

    for i, cell in pairs(self.cells) do
        if isFit(rect, cell) then
            table.insert(self.layout, {
                name = rect.name,
                x = cell.x,
                y = cell.y,
                w = rect.w,
                h = rect.h
            })

            local cellRight = {
                x = cell.x + rect.w,
                y = cell.y,
                w = cell.w - rect.w,
                h = rect.h
            }

            local cellDown = {
                x = cell.x,
                y = cell.y + rect.h,
                w = cell.w,
                h = cell.h - rect.h
            }

            self.cells[i] = nil
            if getArea(cellRight) > 0 then table.insert(self.cells, cellRight) end
            if getArea(cellDown) > 0 then table.insert(self.cells, cellDown) end
            return true
        end
    end

    if self.width < self.height then
        -- grow right
        table.insert(self.cells, {
            x = self.width,
            y = 0,
            w = rect.w,
            h = self.height
        })

        if rect.h > self.height then
            table.insert(self.cells, {
                x = 0,
                y = self.height,
                w = self.width,
                h = rect.h - self.height
            })
            self.height = rect.h
        end

        self.width = self.width + rect.w
    else
        -- grow down
        table.insert(self.cells, {
            x = 0,
            y = self.height,
            w = self.width,
            h = rect.h
        })

        if rect.w > self.width then
            table.insert(self.cells, {
                x = self.width,
                y = 0,
                w = rect.w - self.width,
                h = self.height
            })
            self.width = rect.w
        end

        self.height = self.height + rect.h
    end

    print('Grew canvas to '..self.width..'x'..self.height)

    return pack(self, rect)
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
    return math.max(self.width, self.height)
    -- local i = 1
    -- local s = math.max(self.width, self.height)
    -- while i < s do
    --     i = i * 2
    -- end
    -- return i
end

function toText(self)
    local text = 'return {padding='..self.padding..',images={'
    for _, item in pairs(self.layout) do
        text = text..'{name="'..item.name..'",x='..item.x..',y='..item.y..',w='..item.w..',h='..item.h..'},'
    end
    text = text..'}}'
    return text
end

function toImage(self)
    local size = getSquareSize(self)
    local canvas = love.graphics.newCanvas(size, size, 'rgba8', 0)
    canvas:renderTo(function()
        for _, item in pairs(self.layout) do
            love.graphics.draw(self.images[item.name],
                item.x + self.padding,
                item.y + self.padding)
        end
    end)
    return canvas
end

return Pack

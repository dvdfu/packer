--sets window width, height, and the scale
config = {

    width=64,
    height=64,
    scale=6

}

function love.conf(t)

    t.title = 'Packer Example'
    t.window.width = config.width*config.scale
    t.window.height = config.height*config.scale
    t.window.resizable = false
    t.console = true

end
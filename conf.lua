function love.conf(t)
    t.identity = 'packer'
    t.version = '0.10.1'

    t.window.title = 'Packer'

    t.modules.audio = false
    t.modules.joystick = false
    t.modules.keyboard = false
    t.modules.math = false
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.timer = false
    t.modules.touch = false
    t.modules.video = false
    t.modules.thread = false
end

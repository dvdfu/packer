# Packer

Packer is a tool for Love2D games that pack sprites into a [texture atlas](https://en.wikipedia.org/wiki/Texture_atlas) (or sprite sheet), which can increase game  performance. This project is **incomplete and currently under development**.

## Usage

Download the repository anywhere. You may choose to install Packer as a git submodule:

```sh
$ git submodule add git@github.com:dvdfu/packer.git modules/packer
$ git submodule init
$ git submodule update
```

Run the Packer folder using `love`.

```sh
$ love modules/packer [source] [output]
```

That's all! This packs all images in `source` and generates `output.png` and `output.lua` in your [save directory](https://love2d.org/wiki/love.filesystem). Move them to your game project.

## Drawing Sprites

```lua
Atlas = require 'modules/packer/atlas'

atlas = Atlas.load('output') -- load a texture atlas

playerSprite = atlas:newSprite('player.png')   -- fetch a sprite from a texture atlas
coinSprite = atlas:newSprite('items/coin.png') -- this sprite was located in a subfolder

coinSprite:draw(...) -- same arguments as love.graphics.draw(image, ...)
```

## Documentation

### Atlas

The Atlas class represents a repository of sprites, indexed by filename. They are generated by loading an image and atlas file previously created by Packer.

```lua
Atlas.load(name)
```

```lua
atlas:newSprite(name)
```

```lua
atlas:newAnimation(name, frameCount, frameRate) -- frameRate measured in seconds
```

### Sprite

The Sprite class represents an object that is ready to be drawn by Love2D. They can be generated by retrieving a sprite from an Atlas.

```lua
sprite:getQuad()
```

```lua
sprite:draw(...)
```

### Animation

An Animation is like a Sprite, but contains multiple quads that represent single frames in a looping animation. Animations should be packed as horizontal strips of equal-sized frames, much like how Aseprite exports animations.

```lua
animation:getQuads()
```

```lua
animation:update(dt)
```

```lua
animation:setFrame(frame)
```
Sets the frame of the animation, in the range `[1, frameCount]`. Uses modulus to resolve out-of-bound frames.

```lua
animation:setFramerate(framerate)
```

```lua
animation:draw(...)
```

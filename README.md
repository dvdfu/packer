# Packer

Packer is a tool for Love2D games that pack sprites into a [texture atlas](https://en.wikipedia.org/wiki/Texture_atlas), which can increase game  performance. This project is **incomplete and currently under development**.

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
Atlas = require 'modules.packer.atlas'

atlas = Atlas.load('output')
atlas.draw('sprite.png', ...) -- same arguments as love.graphics.draw(...)
```

## Notes

* Packer exports images as RGBA8 .png files
* any images in subfolders of `source` will also be packed
* `.png .bmp .jpg .jpeg .gif` are supported. All other file types are ignored
* duplicate filenames may occur from subfolders. In this case, the first loaded file is packed, and all duplicates are ignored

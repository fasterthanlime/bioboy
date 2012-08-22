
use gobject, cairo, sdl, deadlogger, ldkit

// game deps
import ldkit/[Display, Input, Math, Sprites, Sound]
import game/Engine

// libs deps
import deadlogger/Log
import zombieconfig

MainUI: class {

    engine: Engine
    display: Display
    input: Input

    label: LabelSprite

    init: func (=engine, config: ZombieConfig) {
	width  := config["screenWidth"] toInt()
	height := config["screenHeight"] toInt()

	display = Display new(width, height, false, "warmup")
	display hideCursor()

	input = Input new()

	label = LabelSprite new(vec2(100, 100), "Coucou")
    }

    update: func {
	display clear()
	label draw(display)
	display blit()

	input _poll()
    }

}


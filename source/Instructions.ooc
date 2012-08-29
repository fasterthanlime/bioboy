
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]

import bioboy

Instructions: class {

    engine: Engine
    ui: UI
    input: Input
    pass: Pass

    game: Game

    init: func (=engine, =game) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "instructions") 
	ui levelPass addPass(pass)

	sprite := ImageSprite new(vec2(0, 0), "assets/png/instructions.png")
	pass addSprite(sprite)

	input onKeyPress(Keys ESC, ||
	    clear()
	    game on("return-to-menu") 
	)

	clear()
    }

    clear: func {
	pass enabled = false
	input enabled = false
    }

    enter: func {
	pass enabled = true
	input enabled = true
    }

}



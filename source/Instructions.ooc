
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]

Instructions: class extends Actor {

    engine: Engine
    ui: UI
    input: Input
    pass: Pass

    onExit: Func

    init: func (=engine, =onExit) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "instructions") 
	ui levelPass addPass(pass)

	sprite := ImageSprite new(vec2(0, 0), "assets/png/fog.png")
	pass addSprite(sprite)

	input onKeyPress(Keys ESC, ||
	    "Caught esc" println()
	    clear()
	    onExit()
	)

	clear()
    }

    clear: func {
	pass enabled = false
	input enabled = false
	engine remove(this)
    }

    enter: func {
	pass enabled = true
	input enabled = true
	engine add(this)
    }

    update: func (delta: Float) {
    }

}



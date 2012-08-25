
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero

Menu: class extends Actor {

    engine: Engine
    ui: UI
    input: Input

    pass: Pass
    selector: ImageSprite

    positions := [
      vec2(537, 347),
      vec2(538, 466),
      vec2(537, 571)
    ] as ArrayList<Vec2>

    currentPos := 0

    onPlay: Func

    init: func (=engine, =onPlay) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "menu")
	ui statusPass addPass(pass)

	bg := ImageSprite new(vec(0, 0), "assets/png/title.png")
	pass addSprite(bg)

	selector = ImageSprite new(positions[0], "assets/png/selector.png")
	selector offset set!(- selector width * 0.5, - selector height * 0.5)
	pass addSprite(selector)

	input onMousePress(1, ||
	    selector pos _ println()
	)

	input onKeyPress(Keys UP, ||
	    updatePos(-1)
	)

	input onKeyPress(Keys DOWN, ||
	    updatePos(1)
	)

	input onKeyPress(Keys ENTER, ||
	    takeAction()
	)

	clear()
    }

    takeAction: func {
	clear()
	match currentPos {
	    case 0 =>
		onPlay()
	    case 1 =>
		// nothing yet
	    case 2 =>
		engine quit()
	}
    }

    updatePos: func (delta: Int) {
	currentPos += delta

	if (currentPos < 0){
	    currentPos = 0
	}

	if (currentPos >= positions size) {
	    currentPos = positions size - 1
	}

	selector pos = positions[currentPos]
    }

    enter: func {
	pass enabled = true
	input enabled = true
	engine add(this)
    }

    clear: func {
	pass enabled = false
	input enabled = false
	engine remove(this)
    }

    update: func (delta: Float) {

    }

}


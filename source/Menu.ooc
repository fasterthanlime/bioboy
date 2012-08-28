
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero, bioboy

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

    game: Game

    init: func (=engine, =game) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "menu")
	ui statusPass addPass(pass)

	bg := ImageSprite new(vec(0, 0), "assets/png/title.png")
	pass addSprite(bg)

	selector = ImageSprite new(positions[0], "assets/png/selector.png")
	selector offset set!(- selector width * 0.5, - selector height * 0.5)
	pass addSprite(selector)

	credits := LabelSprite new(vec2(200, 680), "Amos Wenger (everything else)")
	credits centered = true
	credits color set!(1, 1, 1)
	pass addSprite(credits)

	credits = LabelSprite new(vec2(200, 710), "Myriam Bechikh (levels, test)")
	credits centered = true
	credits color set!(1, 1, 1)
	pass addSprite(credits)

	credits = LabelSprite new(vec2(800, 680), "Sylvain Wenger (music)")
	credits centered = true
	credits color set!(1, 1, 1)
	pass addSprite(credits)
	
	credits = LabelSprite new(vec2(800, 710), "Romain Ruetschi (test)")
	credits centered = true
	credits color set!(1, 1, 1)
	pass addSprite(credits)

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
	    clear()
	    takeAction()
	)

	input onKeyPress(Keys ESC, ||
	    clear()
	    engine quit()
	)

	clear()
    }

    takeAction: func {
	clear()
	match currentPos {
	    case 0 =>
		game on("menu-play")
	    case 1 =>
		game on("menu-instructions")
	    case 2 =>
		game on("quit")
	}
    }

    updatePos: func (delta: Int) {
	currentPos += delta

	if (currentPos < 0){
	    currentPos = positions size - 1
	}

	if (currentPos >= positions size) {
	    currentPos = 0
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


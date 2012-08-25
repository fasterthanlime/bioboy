
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero

LevelSelect: class extends Actor {

    engine: Engine
    ui: UI
    input: Input

    pass: Pass
    selector: ImageSprite

    col := 0
    row := 0

    width := 8
    height := 7

    side := 60
    padding := 25

    paddingLeft := 200
    paddingTop := 100

    selector: RectSprite

    onPlay: Func (String)

    init: func (=engine, =onPlay) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "level-select") 
	ui statusPass addPass(pass)

	setupEvents()

	clear()
    }

    setupEvents: func {
	input onKeyPress(Keys RIGHT, || updateSelector(1, 0))
	input onKeyPress(Keys LEFT,  || updateSelector(-1, 0))
	input onKeyPress(Keys UP,    || updateSelector(0, -1))
	input onKeyPress(Keys DOWN,  || updateSelector(0, 1))

	input onKeyPress(Keys ENTER, || takeAction())
    }

    levelName: func (col, row: Int) -> String {
	"%d-%d" format(row, col)
    }

    takeAction: func {
	onPlay(levelName(col, row))
    }

    updateSelector: func (deltaCol, deltaRow: Int) {
	col += deltaCol
	if (col < 0) {
	    col = width - 1
	    if (row > 0) {
		row -= 1
	    } else {
		row = height - 1
	    }
	}
	if (col >= width) {
	    col = 0
	    if (row <= height) {
		row += 1
	    } else {
		row = 0
	    }
	}

	row += deltaRow
	if (row < 0) row = height - 1
	if (row >= height) row = 0

	selector pos set!(toScreen(col, row))
    }

    enter: func {
	pass enabled = true
	input enabled = true
	engine add(this)

	buildGrid()
    }

    clear: func {
	pass enabled = false
	input enabled = false
	engine remove(this)
    }

    toScreen: func (i, j: Int) -> Vec2 {
	x := paddingLeft + i * (side + padding)
	y := paddingTop + j * (side + padding)
	vec2(x, y)
    }

    buildGrid: func {
	for (j in 0..height) for (i in 0..width) {
	    rect := RectSprite new(toScreen(i, j))
	    if (i == width - 1) {
		rect color set!(1.0, 1.0, 0.0)
	    } else {
		rect color set!(1.0, 1.0, 1.0)
	    }
	    rect filled = false
	    rect thickness = 1
	    rect size set!(side, side)
	    pass addSprite(rect)
	}

	if (!selector) {
	    selector = RectSprite new(toScreen(0, 0))
	    selector size set!(side + 5, side + 5)
	    selector filled = false
	    selector thickness = 4
	    selector color set!(1.0, 1.0, 1.0)
	}
	pass addSprite(selector)
    }

    update: func (delta: Float) {
    }

}


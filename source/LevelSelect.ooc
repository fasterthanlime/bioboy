
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero

Item: class {

    name: String
    file: String

    init: func (=name) {
    }

}

Row: class {

    items := ArrayList<Item> new()

    name: String

    init: func (=name) {}

}

Plan: class {
    rows := ArrayList<Row> new()

    init: func (name: String) {
	fr := FileReader new("assets/levels/%s.txt" format(name))

	row: Row = null
	item: Item = null	

	while (fr hasNext?()) {
	    line := fr readLine()

	    if (line startsWith?("# ")) {
		row = Row new(line substring(2))
		rows add(row)
	    }

	    if (line startsWith?("## ")) {
		item = Item new(line substring(3))
		row items add(item)
	    }

	    if (line startsWith?("file: ")) {
		item file = line substring(6)
	    }
	}

	fr close()
    }

}

LevelSelect: class extends Actor {

    engine: Engine
    ui: UI
    input: Input

    pass: Pass
    selector: ImageSprite

    colNum := 0
    rowNum := 0

    plan: Plan
    row: Row
    item: Item

    side := 60
    padding := 25

    paddingLeft := 300
    paddingTop := 100

    selector: RectSprite
    rowLabel: LabelSprite
    nameLabel: LabelSprite

    onPlay: Func (String)

    init: func (=engine, =onPlay) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "level-select") 
	ui statusPass addPass(pass)

	setupEvents()

	buildGrid()

	clear()
    }

    setupEvents: func {
	input onKeyPress(Keys RIGHT, || updateSelector(1, 0))
	input onKeyPress(Keys LEFT,  || updateSelector(-1, 0))
	input onKeyPress(Keys UP,    || updateSelector(0, -1))
	input onKeyPress(Keys DOWN,  || updateSelector(0, 1))

	input onKeyPress(Keys ENTER, || takeAction())
    }

    takeAction: func {
	onPlay(item file)
    }

    updateSelector: func (deltaCol, deltaRow: Int) {
	colNum += deltaCol
	rowNum += deltaRow

	row = plan rows get(rowNum)
	item = row items get(colNum)

	selector pos set!(toScreen(colNum, rowNum))
	rowLabel setText("%s" format(row name))
	nameLabel setText("%s" format(item name))
    }

    enter: func {
	pass enabled = true
	input enabled = true
	engine add(this)
	updateSelector(0, 0)
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
	plan = Plan new("plan")

	for (j in 0..plan rows size) {
	    row = plan rows get(j)
	    for (i in 0..row items size) {
		item = row items get(i)

		rect := RectSprite new(toScreen(i, j))
		if (i == row items size - 1) {
		    rect color set!(1.0, 1.0, 0.0)
		} else {
		    rect color set!(1.0, 1.0, 1.0)
		}
		rect filled = false
		rect thickness = 1
		rect size set!(side, side)
		pass addSprite(rect)
	    }
	}

	selector = RectSprite new(toScreen(0, 0))
	selector size set!(side + 5, side + 5)
	selector filled = false
	selector thickness = 4
	selector color set!(1.0, 1.0, 1.0)
	pass addSprite(selector)

	rowLabel = LabelSprite new(vec2(50, paddingTop), "<World name>")
	rowLabel color set!(1.0, 1.0, 0.4)
	pass addSprite(rowLabel)

	nameLabel = LabelSprite new(vec2(50, 30 + paddingTop), "<Level name>")
	nameLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(nameLabel)
    }

    update: func (delta: Float) {

    }

    destroy: func {

    }

}


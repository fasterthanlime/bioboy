
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero

Medal: enum {
    NONE
    BRONZE
    SILVER
    GOLD
}

Item: class {

    name: String
    file: String
    medal := Medal NONE

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

    pass, gridPass: Pass
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
    pointsLabel: LabelSprite

    points := 0

    onPlay: Func (String)

    init: func (=engine, =onPlay) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "level-select") 
	ui statusPass addPass(pass)

	gridPass = Pass new(ui, "level-select-grid")
	pass addPass(gridPass)

	setupEvents()

	buildUI()

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
	rowNum += deltaRow
	if (rowNum < 0) rowNum = plan rows size - 1
	if (rowNum >= plan rows size) rowNum = 0

	row = plan rows get(rowNum)

	colNum += deltaCol
	if (colNum < 0) colNum = 0

	maxCols := row items size
	if (colNum >= maxCols) {
	    colNum = 0
	    updateSelector(0, 1)
	    return
	}

	item = row items get(colNum)

	selector pos set!(toScreen(colNum, rowNum))
	rowLabel setText("%s" format(row name))
	nameLabel setText("%s" format(item name))
    }

    success: func {
	item medal = Medal BRONZE
    }

    enter: func {
	pass enabled = true
	input enabled = true
	engine add(this)

	buildGrid()
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

    buildUI: func {
	plan = Plan new("plan")

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

	pointsLabel = LabelSprite new(vec2(50, 700), "%d" format(points))
	pointsLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(pointsLabel)

	buildGrid()
    }

    buildGrid: func {
	gridPass reset()

	for (j in 0..plan rows size) {
	    row = plan rows get(j)
	    for (i in 0..row items size) {
		pos := toScreen(i, j)
		item = row items get(i)

		// Rubyists, you may start laughing now
		sprite := match (item medal) {
		    case Medal NONE   => "none"
		    case Medal BRONZE => "bronze"
		    case Medal SILVER => "silver"
		    case Medal GOLD   => "gold"
		}

		medalSprite := ImageSprite new(pos, "assets/png/%s.png" format(sprite))
		medalSprite offset set!(- medalSprite width / 2, - medalSprite height / 2)
		gridPass addSprite(medalSprite)
	    }
	}
    }

    update: func (delta: Float) {

    }

    destroy: func {

    }

}


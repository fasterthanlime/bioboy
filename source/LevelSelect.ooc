
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero, Power, TimeHelper

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

    silverTime := 1000000 as Long
    goldTime := 1000000 as Long
    recordTime := -1 as Long

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

    // powers
    dgun := false
    armor := false
    jetpack := false
    bomb := false
    block := false
    slow := false
    hook := false

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

    paddingLeft := 40
    paddingTop := 60

    gridPaddingLeft := 350
    gridPaddingTop := 180

    selector: RectSprite
    rowLabel: LabelSprite
    nameLabel: LabelSprite
    pointsLabel: LabelSprite
    silverLabel: LabelSprite
    goldLabel: LabelSprite
    recordLabel: LabelSprite

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

    togglePower: func (which: Power) {
	match which {
	    case Power DGUN => dgun = !dgun
	    case Power ARMOR => armor = !armor
	    case Power JETPACK => jetpack = !jetpack
	    case Power BOMB => bomb = !bomb
	    case Power BLOCK => block = !block
	    case Power SLOW => slow = !slow
	    case Power HOOK => hook = !hook
	}
    }

    hasPower: func (which: Power) -> Bool {
	match which {
	    case Power DGUN => dgun
	    case Power ARMOR => armor
	    case Power JETPACK => jetpack
	    case Power BOMB => bomb
	    case Power BLOCK => block
	    case Power SLOW => slow
	    case Power HOOK => hook
	    case => false
	}
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
	silverLabel setText(TimeHelper format(item silverTime))
	goldLabel setText(TimeHelper format(item goldTime))
	recordLabel setText(TimeHelper format(item recordTime))
    }

    success: func {
	if (item medal < Medal BRONZE) {
	    item medal = Medal BRONZE
	}
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
	x := gridPaddingLeft + i * (side + padding)
	y := gridPaddingTop + j * (side + padding)
	vec2(x, y)
    }

    buildUI: func {
	plan = Plan new("plan")

	// panels
	leftPanel := RectSprite new(vec2(150, 400))
	leftPanel size set!(260, 800)
	leftPanel color set!(1, 1, 1)
	leftPanel alpha = 0.4
	pass addSprite(leftPanel)

	selector = RectSprite new(toScreen(0, 0))
	selector size set!(side + 5, side + 5)
	selector filled = false
	selector thickness = 4
	selector color set!(1.0, 1.0, 1.0)
	pass addSprite(selector)

	rowLabel = LabelSprite new(vec2(gridPaddingLeft - 30, 100), "<World name>")
	rowLabel fontSize = 62.0
	rowLabel color set!(1.0, 1.0, 0.4)
	pass addSprite(rowLabel)

	nameLabel = LabelSprite new(vec2(paddingLeft, 30 + paddingTop), "<Level name>")
	nameLabel fontSize = 32.0
	nameLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(nameLabel)

	// ===== spacer ======

	bestLabel := LabelSprite new(vec2(paddingLeft, 90 + paddingTop), "Your time")
	bestLabel color set!(0.5, 0.5, 0.5)
	pass addSprite(bestLabel)

	recordLabel = LabelSprite new(vec2(paddingLeft, 120 + paddingTop), "")
	recordLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(recordLabel)

	// ===== spacer ======

	timesLabel := LabelSprite new(vec2(paddingLeft, 180 + paddingTop), "Medal times")
	timesLabel color set!(0.5, 0.5, 0.5)
	pass addSprite(timesLabel)

	silverLabel = LabelSprite new(vec2(paddingLeft, 210 + paddingTop), "")
	silverLabel color set!(0.7, 0.7, 0.8)
	pass addSprite(silverLabel)

	goldLabel = LabelSprite new(vec2(paddingLeft, 240 + paddingTop), "")
	goldLabel color set!(0.7, 0.7, 0.2)
	pass addSprite(goldLabel)

	yourPoints := LabelSprite new(vec2(paddingLeft, 670), "Points")
	yourPoints color set!(0.7, 0.7, 0.7)
	pass addSprite(yourPoints)

	pointsLabel = LabelSprite new(vec2(paddingLeft, 700), "%d" format(points))
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


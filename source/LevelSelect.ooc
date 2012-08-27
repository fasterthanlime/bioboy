
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero, Power, TimeHelper

Medal: enum {
    NONE
    BRONZE
    SILVER
    GOLD

    val: func -> Int {
	match this {
	    case This NONE => 0
	    case This BRONZE => 1
	    case This SILVER => 2
	    case This GOLD => 3
	}
    }

    toString: func -> String {
	match this {
	    case This NONE => "none"
	    case This BRONZE => "bronze"
	    case This SILVER => "silver"
	    case This GOLD => "gold"
	}
    }
}

Item: class {

    name: String
    file: String
    medal := Medal NONE

    silverTime := -1 as Long
    goldTime := -1 as Long
    recordTime := -1 as Long

    init: func (=name) {
    }

    medal: func (millis: Long) -> Medal {
	if (millis < goldTime) {
	    Medal GOLD
	} else if (millis < silverTime) {
	    Medal SILVER
	} else {
	    Medal BRONZE
	}
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

	    if (line startsWith?("silver: ")) {
		time := line substring(8)
		item silverTime = TimeHelper parse(time)
	    }

	    if (line startsWith?("gold: ")) {
		time := line substring(6)
		item goldTime = TimeHelper parse(time)
	    }
	}

	fr close()
    }

}

LevelSelect: class extends Actor {

    // powers
    dgun := false
    armor := false
    slow := false

    engine: Engine
    ui: UI
    input: Input

    pass, gridPass, fgPass: Pass
    selector: ImageSprite

    powerDgun, powerArmor, powerTime: ImageSprite

    dgunPoints := 60
    armorPoints := 120
    slowPoints := 200

    colNum := 0
    rowNum := 0

    plan: Plan
    row: Row
    item: Item

    side := 60
    padding := 25
    verticalPadding := 45

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
    onExit: Func

    init: func (=engine, =onPlay, =onExit) {
	ui = engine ui
	input = ui input sub()

	pass = Pass new(ui, "level-select") 
	ui levelPass addPass(pass)

	gridPass = Pass new(ui, "level-select-grid")
	pass addPass(gridPass)

	fgPass = Pass new(ui, "level-select-foreground")
	pass addPass(fgPass)

	setupEvents()

	buildUI()

	clear()
    }

    activatePower: func (which: Power) {
	match which {
	    case Power DGUN => dgun = !dgun
	    case Power ARMOR => armor = !armor
	    case Power SLOW => slow = !slow
	}
    }

    hasPower: func (which: Power) -> Bool {
	match which {
	    case Power DGUN => dgun
	    case Power ARMOR => armor
	    case Power SLOW => slow
	    case => false
	}
    }

    setupEvents: func {
	input onKeyPress(Keys RIGHT, || updateSelector(1, 0))
	input onKeyPress(Keys LEFT,  || updateSelector(-1, 0))
	input onKeyPress(Keys UP,    || updateSelector(0, -1))
	input onKeyPress(Keys DOWN,  || updateSelector(0, 1))

	input onKeyPress(Keys ENTER, || takeAction())
	input onKeyPress(Keys ESC, || leave())
    }

    leave: func {
	clear()
	onExit()
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
	rowLabel setText("%s" format(item name))
	nameLabel setText("%s" format(row name))
	silverLabel setText(TimeHelper format(item silverTime))
	goldLabel setText(TimeHelper format(item goldTime))
	recordLabel setText(TimeHelper format(item recordTime))
	pointsLabel setText("%d" format(points))
    }

    success: func (millis: Long) {
	medal := item medal(millis)

	if (item medal < medal) {
	    points += (medal val() - item medal val()) * 10

	    unlockItems()
	    item medal = medal
	    ui flash("Won %s medal on %s" format(medal toString(), item name))
	}

	if (item recordTime == -1 || millis < item recordTime) {
	    item recordTime = millis
	}
    }

    unlockItems: func {
	if (points >= dgunPoints) {
	    dgun = true
	    powerDgun alpha = 1.0
	}

	if (points >= armorPoints) {
	    armor = true
	    powerArmor alpha = 1.0
	}

	if (points >= slowPoints) {
	    slow = true
	    powerTime alpha = 1.0
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
	y := gridPaddingTop + j * (side + verticalPadding)
	vec2(x, y)
    }

    buildUI: func {
	plan = Plan new("plan")

	// bg
	background := ImageSprite new(vec2(0, 0), "assets/png/fog.png")
	pass addSprite(background)

	// panels
	leftPanel := RectSprite new(vec2(150, 400))
	leftPanel size set!(260, 800)
	leftPanel color set!(0, 0, 0)
	leftPanel alpha = 0.7
	pass addSprite(leftPanel)

	topPanel := RectSprite new(vec2(512, 75))
	topPanel size set!(1024, 90)
	topPanel color set!(0, 0, 0)
	topPanel alpha = 0.7
	pass addSprite(topPanel)

	selector = RectSprite new(toScreen(0, 0))
	selector size set!(side + 15, side + 15)
	selector filled = false
	selector thickness = 6
	selector color set!(1, 1, 1)
	fgPass addSprite(selector)

	rowLabel = LabelSprite new(vec2(gridPaddingLeft - 30, 100), "<World name>")
	rowLabel fontSize = 62.0
	rowLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(rowLabel)

	nameLabel = LabelSprite new(vec2(paddingLeft, 30 + paddingTop), "<Level name>")
	nameLabel fontSize = 32.0
	nameLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(nameLabel)

	// ===== spacer ======

	bestLabel := LabelSprite new(vec2(paddingLeft, 120 + paddingTop), "Your time")
	bestLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(bestLabel)

	recordLabel = LabelSprite new(vec2(paddingLeft, 150 + paddingTop), "")
	recordLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(recordLabel)

	// ===== spacer ======

	timesLabel := LabelSprite new(vec2(paddingLeft, 210 + paddingTop), "Silver time")
	timesLabel color set!(0.7, 0.7, 0.8)
	pass addSprite(timesLabel)

	silverLabel = LabelSprite new(vec2(paddingLeft, 240 + paddingTop), "")
	silverLabel color set!(0.7, 0.7, 0.8)
	pass addSprite(silverLabel)

	// ===== spacer =====

	times2Label := LabelSprite new(vec2(paddingLeft, 300 + paddingTop), "Gold time")
	times2Label color set!(0.7, 0.7, 0.2)
	pass addSprite(times2Label)

	goldLabel = LabelSprite new(vec2(paddingLeft, 330 + paddingTop), "")
	goldLabel color set!(0.7, 0.7, 0.2)
	pass addSprite(goldLabel)

	// ===== *big* spacer ==== 

	yourPoints := LabelSprite new(vec2(paddingLeft, 670), "Points")
	yourPoints color set!(0.7, 0.7, 0.7)
	pass addSprite(yourPoints)

	pointsLabel = LabelSprite new(vec2(paddingLeft, 700), "%d" format(points))
	pointsLabel color set!(1.0, 1.0, 1.0)
	pass addSprite(pointsLabel)

	// powers

	powers := ImageSprite new(vec2(0, 0), "assets/png/powers.png")
	pass addSprite(powers)

	powerDgun = ImageSprite new(vec2(0, 0), "assets/png/power-dgun.png")
	powerDgun alpha = 0
	pass addSprite(powerDgun)

	powerArmor = ImageSprite new(vec2(0, 0), "assets/png/power-armor.png")
	powerArmor alpha = 0
	pass addSprite(powerArmor)

	powerTime = ImageSprite new(vec2(0, 0), "assets/png/power-time.png")
	powerTime alpha = 0
	pass addSprite(powerTime)

	buildGrid()
    }

    buildGrid: func {
	gridPass reset()

	for (j in 0..plan rows size) {
	    row = plan rows get(j)
	    for (i in 0..row items size) {
		pos := toScreen(i, j)
		item = row items get(i)

		outline := ImageSprite new(pos, "assets/png/item-outline.png")
		outline center!()
		gridPass addSprite(outline)

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


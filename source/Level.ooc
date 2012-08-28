
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass, Colors, Collision]
import io/[FileReader, File]
import structs/[ArrayList, List]
import deadlogger/Log

import Block, Hero, TimeHelper, LevelSelect, Power, bioboy

Level: class extends Actor {

    levelSelect: LevelSelect
    engine: Engine
    blocks := ArrayList<Block> new()

    ui: UI
    hero: Hero

    levelFile: String

    pass, bgPass, objectPass, hudPass: Pass
    input: Input

    lifeLabel, timeLabel: LabelSprite

    life := 0.0
    millis: Long = 0

    logger := static Log getLogger(This name)

    game: Game

    init: func (=engine, =levelSelect, =game) {
	ui = engine ui
	input = ui input sub()

	initPasses()
	initBg()
	initHud()
    
	input onKeyPress(Keys BACKSPACE, ||
	    loadLevel()
	)

	input onKeyPress(Keys ESC, ||
	    clear()
	    game on("level-fail")
	)
    }

    initPasses: func {
	pass = Pass new(ui, "level")
	pass enabled = false
	ui levelPass addPass(pass)

	bgPass = Pass new(ui, "level-background")
	pass addPass(bgPass)

	objectPass = Pass new(ui, "level-objects")
	pass addPass(objectPass)

	hudPass = Pass new(ui, "level-hud")
	pass addPass(hudPass)
    }

    initBg: func {
	fog := ImageSprite new(vec2(0, 0), "assets/png/green-fog.png")
	bgPass addSprite(fog)
    }

    initHud: func {
	timePanel := ImageSprite new(vec2(120, 60), "assets/png/time-support.png")
	timePanel center!()
	timePanel alpha = 0.9
	hudPass addSprite(timePanel)

	timeLabel = LabelSprite new(vec2(60, 75), "")
	timeLabel fontSize = 40.0
	timeLabel color set!(0.9, 0.9, 0.9)
	hudPass addSprite(timeLabel)

	lifePanel := ImageSprite new(vec2(920, 50), "assets/png/time-support.png")
	lifePanel center!()
	lifePanel alpha = 0.9
	hudPass addSprite(lifePanel)

	lifeLabel = LabelSprite new(vec2(920, 50), "")
	lifeLabel fontSize = 40.0
	lifeLabel centered = true
	lifeLabel color set!(0.9, 0.9, 0.9)
	hudPass addSprite(lifeLabel)
    }

    neighbors: func (pos: Vec2) -> List<Block> {
	minX := pos x - Block SIDE * 1.5
	maxX := pos x + Block SIDE * 1.5
	minY := pos y - Block SIDE * 1.5
	maxY := pos y + Block SIDE * 1.5

	neighbors := ArrayList<Block> new()

	for (block in blocks) {
	    has := false

	    if (block pos x >= minX && block pos x <= maxX &&
		block pos y >= minY && block pos y <= maxY) {
		neighbors add(block)
		has = true
	    }
	}

	neighbors
    }

    updateHud: func {
	lifeLabel setText("%.0f%%" format(life))
	timeLabel setText(TimeHelper format(millis))
    }

    update: func (delta: Float) {
	factor := engine slomo ? 0.5 : 1.0

	millis += (delta * factor) as Long
	updateHud()

	for(block in blocks) {
	    block update(delta)
	}

	hero update(delta)
    }

    clear: func {
	pass enabled = false
	input enabled = false
	engine remove(this)

	if (hero) {
	    hero destroy()
	    hero = null
	}

	for (block in blocks) {
	    block destroy()
	}
	blocks clear()

	iter := engine actors iterator()
	while (iter hasNext?()) {
	    actor := iter next()
	    if (actor == this) continue
	    if (actor class name == "Game") continue
	    if (actor class name == "Menu") continue
	    if (actor class name == "LevelSelect") continue

	    actor destroy()
	    iter remove()
	}
    }

    nextLevel: func {
	clear()
	play("tiling")	
	game on("level-success")
    }

    play: func (sound: String) {
	sample := ui boombox load("assets/ogg/sounds/%s.ogg" format(sound))
	if (sample) {
	    ui boombox play(sample)
	}
    }

    loopMusic: func (music: String) {
	sample := ui boombox load("assets/ogg/music/%s.ogg" format(music))
	if (sample) {
	    ui boombox loop(sample)
	}
    }

    jumpTo: func (=levelFile) -> Bool {
	loadLevel()
    }

    loadLevel: func -> Bool {
	clear()

	millis = 0
	life = 100.0

	path := "assets/levels/%s" format(levelFile)

	f := File new(path)
	if (!f exists?()) {
	    play("uh-oh")
	    ui flash("Level %s does not exist!" format(path))
	    return false
	}

	fr := FileReader new(f)

	logger info("Loading level %s" format(path))

	heroPos := vec2(0, 0)

	y := 0
	x := 0
	while (fr hasNext?()) {
	    c := fr read()

	    match c {
		case '\n' =>
		    y += 1
		    x = 0
		    continue
		case '>' =>
		    createBlock(x, y, "dblock-r")
		case '<' =>
		    createBlock(x, y, "dblock-l")
		case '^' =>
		    createBlock(x, y, "dblock-u")
		case 'v' =>
		    createBlock(x, y, "dblock-d")

		case ')' =>
		    b := createBlock(x, y, "dblock-r")
		    b permanent = true
		case '(' =>
		    b := createBlock(x, y, "dblock-l")
		    b permanent = true
		case 'n' =>
		    b := createBlock(x, y, "dblock-u")
		    b permanent = true
		case 'u' =>
		    b := createBlock(x, y, "dblock-d")
		    b permanent = true

		case 'b' =>
		    createBlock(x, y, "bomb")

		case '-' =>
		    createBlock(x, y, "net")

		case 'z' =>
		    createBlock(x, y, "bump")

		case 'x' =>
		    createBlock(x, y, "spike")

		case 'j' =>
		    createBlock(x, y, "blink")

		case '=' =>
		    createBlock(x, y, "inert")
		case 'a' =>
		    createBlock(x, y, "level-end")
		case '*' =>
		    createBlock(x, y, "ice")
		case 'd' =>
		    heroPos set!(x * Block SIDE, y * Block SIDE)
	    }

	    x += 1
	}

	hero = Hero new(engine, this, heroPos)

	fr close()
	
	engine add(this)
	pass enabled = true
	input enabled = true
	
	return true
    }

    createBlock: func (x, y: Int, type: String) -> Block {
	block := Block new(engine, this, type, x, y)
	blocks add(block)
	block
    }

}

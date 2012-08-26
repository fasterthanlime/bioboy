
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList
import deadlogger/Log

import Block, Hero, TimeHelper

Level: class extends Actor {

    engine: Engine
    blocks := ArrayList<Block> new()

    ui: UI
    hero: Hero

    levelFile: String
    onDone: Func (Bool)

    pass, bgPass, objectPass, hudPass: Pass

    lifeLabel: LabelSprite
    timeLabel: LabelSprite

    life := 0.0
    millis: Long = 0

    logger := static Log getLogger(This name)

    init: func (=engine, =onDone) {
	ui = engine ui

	initPasses()
	initBg()
	initHud()
    
	ui input onKeyPress(Keys BACKSPACE, ||
	    loadLevel()
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
	fog := ImageSprite new(vec2(0, 0), "assets/png/fog.png")
	bgPass addSprite(fog)
    }

    initHud: func {
	timeLabel = LabelSprite new(vec2(20, 50), "")
	timeLabel fontSize = 40.0
	timeLabel color set!(1.0, 1.0, 1.0)
	hudPass addSprite(timeLabel)

	lifeLabel = LabelSprite new(vec2(900, 50), "")
	lifeLabel fontSize = 40.0
	lifeLabel color set!(1.0, 1.0, 1.0)
	hudPass addSprite(lifeLabel)
    }

    updateHud: func {
	lifeLabel setText("%.0f%%" format(life))
	timeLabel setText(TimeHelper format(millis))
    }

    update: func (delta: Float) {
	millis += delta as Long
	updateHud()

	for(block in blocks) {
	    block update(delta)
	}

	hero update(delta)
    }

    clear: func {
	pass enabled = false
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

	    actor destroy()
	    iter remove()
	}
    }

    nextLevel: func {
	clear()
	onDone(true)
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
	
	return true
    }

    createBlock: func (x, y: Int, type: String) -> Block {
	block := Block new(engine, this, type, x, y)
	blocks add(block)
	block
    }

}

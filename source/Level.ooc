
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero

Level: class extends Actor {

    engine: Engine
    blocks := ArrayList<Block> new()

    ui: UI
    hero: Hero

    levelNum: Int

    pass, bgPass, objectPass: Pass

    init: func (=engine, =levelNum) {
	ui = engine ui

	initPasses()
	initBg()
	
    
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
    }

    initBg: func {
	fog := ImageSprite new(vec2(0, 0), "assets/png/fog.png")
	bgPass addSprite(fog)
    }

    update: func (delta: Float) {
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
	levelNum += 1
	loadLevel()
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

    loadLevel: func {
	clear()
	
	engine add(this)
	pass enabled = true

	path := "assets/levels/level%d.txt" format(levelNum)

	f := File new(path)
	if (!f exists?()) {
	    levelNum = 1
	    loadLevel()
	    return
	}

	fr := FileReader new(f)

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
    }

    createBlock: func (x, y: Int, type: String) -> Block {
	block := Block new(engine, this, type, x, y)
	ui levelPass addSprite(block sprite)
	blocks add(block)
	block
    }

}

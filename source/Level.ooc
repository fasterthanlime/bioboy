
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


StoryCard: class {
    image: String
    lines := ArrayList<String> new()

    init: func (=image) {}
}


Story: class extends Actor {

    engine: Engine

    ui: UI
    input: Input
    pass: Pass

    name: String
    cards := ArrayList<StoryCard> new()
    cardNum := 0

    onDone: Func

    init: func (=engine, =name, =onDone) {
	ui = engine ui
	input = ui input sub()
    
	loadStory()
	pass = Pass new(ui, "story")
	ui statusPass addPass(pass)

	input onKeyPress(Keys SPACE, ||
	    nextCard()
	)
    }

    loadStory: func () {
	fr := FileReader new("assets/story/%s.txt" format(name))

	while (fr hasNext?()) {
	    card := StoryCard new(fr readLine())
	    cards add(card)

	    fr readLine() // skip blank line after image path

	    while (fr hasNext?()) {
		line := fr readLine()

		if (line empty?()) {
		    break
		}

		card lines add(line)
	    }
	}
    }

    clear: func {
	pass reset()
	pass enabled = false
	input enabled = false
    }

    nextCard: func {
	cardNum += 1

	if (cards size <= cardNum) {
	    clear()
	    onDone()
	} else {
	    loadCard()
	}
    }

    loadCard: func {
	clear()

	pass enabled = true
	input enabled = true

	// image
        card := cards get(cardNum)
	bg := ImageSprite new(vec2(0, 0), "assets/png/%s.png" format(card image))
	pass addSprite(bg)

	// lines
	pos := vec2(200, 600)
	for (line in card lines) {
	    sprite := LabelSprite new(pos, line)
	    sprite color set!(0.8, 0.8, 0.8)
	    sprite fontSize = 30.0
	    pass addSprite(sprite)

	    pos = pos add(0, 30)
	}
    }

}



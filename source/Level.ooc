
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero

Level: class extends Actor {

    engine: Engine
    blocks := ArrayList<Block> new()

    ui: UI
    hero: Hero

    levelNum: Int

    init: func (=engine, =levelNum) {
	ui = engine ui

	engine add(this)

	fog := ImageSprite new(vec2(0, 0), "assets/png/fog.png")
	ui bgPass addSprite(fog)
    
	loadLevel()

	ui input onKeyPress(Keys BACKSPACE, ||
	    loadLevel()
	)
    }

    update: func (delta: Float) {
	for(block in blocks) {
	    block update(delta)
	}

	hero update(delta)
    }

    reset: func {
	if (hero) {
	    hero destroy()
	    hero = null
	}

	for (block in blocks) {
	    block destroy()
	}
	blocks clear()
    }

    nextLevel: func {
	levelNum += 1
	loadLevel()
    }

    loadLevel: func {
	reset()
	
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
		case '=' =>
		    createBlock(x, y, "inert")
		case 'a' =>
		    createBlock(x, y, "level-end")
		case 'd' =>
		    heroPos set!(x * Block SIDE, y * Block SIDE)
	    }

	    x += 1
	}

	hero = Hero new(engine, this, heroPos)

	fr close()
    }

    createBlock: func (x, y: Int, type: String) {
	block := Block new(engine, this, type, x, y)
	ui levelPass addSprite(block sprite)
	blocks add(block)
    }

}

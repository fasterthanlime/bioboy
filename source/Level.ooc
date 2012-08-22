
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor]
import io/FileReader

import Block

Level: class {

    engine: Engine

    ui: UI

    init: func (=engine) {
	ui = engine ui

	fog := ImageSprite new(vec2(0, 0), "assets/png/fog.png")
	ui bgPass addSprite(fog)

	fr := FileReader new("assets/levels/level1.txt")

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
		case 'd' =>
		    createBlock(x, y, "hero")
	    }

	    x += 1
	}
    }

    createBlock: func (x, y: Int, type: String) {
	block := Block new(type, x, y)
	ui levelPass addSprite(block sprite)
    }

}

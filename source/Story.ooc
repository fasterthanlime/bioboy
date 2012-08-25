
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Pass]
import io/[FileReader, File]
import structs/ArrayList

import Block, Hero

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
	bg := ImageSprite new(vec2(0, 0), "assets/png/story/%s.png" format(card image))
	pass addSprite(bg)

	// lines
	pos := vec2(200, 650)
	for (line in card lines) {
	    sprite := LabelSprite new(pos, line)
	    sprite color set!(0.8, 0.8, 0.8)
	    sprite fontSize = 30.0
	    pass addSprite(sprite)

	    pos = pos add(0, 30)
	}
    }

}

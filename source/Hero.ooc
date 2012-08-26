
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Collision, Display]
import Level, Block, Bullet
import math/Random, structs/ArrayList

Hero: class extends Actor {

    engine: Engine
    level: Level
    ui: UI
    input: Proxy

    oldPos := vec2(0, 0)
    pos: Vec2
    velX := 0.0
    velY := 0.0

    loseSounds := ["woops", "wth-was-that", "aah", "dont-think-so", "try-again", "too-bad"] as ArrayList<String>
    winSounds := ["victoly", "yay", "wohow"] as ArrayList<String>

    offset := vec2(2, -25)
    collisionOffset := vec2(3, 0)
    box: Box

    sprite: ImageSprite

    init: func (=engine, =level, =pos) {
	ui = engine ui

	pos add!(offset)
	sprite = ImageSprite new(pos, "assets/png/hero.png")

	box = Box new(vec2(0, 0), 26, sprite height)

	level objectPass addSprite(sprite)

	setupEvents()
    }

    setupEvents: func {
	input = ui input sub()

	input onKeyPress(Keys LEFT, || fire())
	input onKeyPress(Keys RIGHT, || fire())
	input onKeyPress(Keys UP, || fire())
	input onKeyPress(Keys DOWN, || fire())
    }

    fire: func {
	dir := vec2(0, 0)
	if (input isPressed(Keys LEFT)) {
	dir x = -1
	} else if (input isPressed(Keys RIGHT)) {
	dir x = 1
	}

	if (input isPressed(Keys UP)) {
	dir y = -1
	} else if (input isPressed(Keys DOWN)) {
	dir y = 1
	}

	if (dir squaredNorm() > 0.01) {
	    dir = dir normalized()

	    Bullet new(engine, level,
		    pos add(sprite width / 2,
			10 + sprite height / 2),
		    dir)
	}
    }

    update: func (delta: Float) {
	oldPos set!(pos)
	pos add!(velX, velY)

	handleCollisions()

	velY += 1.5
	if (velY > 8) {
	    velY = 8
	}

	if (velX > 8.0) {
	    velX = 8.0
	}

	if (pos x < 0 ||
	    pos y < 0 ||
	    pos x > ui display width ||
	    pos y > ui display height) {
	    die()
	}

	posDiff := pos sub(oldPos)
	if (posDiff norm() <= 0.01) {
	    if (velX > 8.0) {
		velX = 3.0
	    } else {
		velX *= 0.7
	    }
	}
    }

    handleCollisions: func {
	running := true

	hadCollision := false
	counter := 0
	while (running) {
	    counter += 1
	    if (counter > 16) {
		die()
		break
	    }

	    box pos set!(pos add(collisionOffset))

	    running = false

	    bestXBang: Bang = null
	    bestXBlock: Block = null

	    bestYBang: Bang = null
	    bestYBlock: Block = null

	    for(block in level blocks) {
		bang := box collide(block box)
		if (bang) {
		    if (block solid) {
			block applyThrust()

			if (bang dir y == 0) {
			    if (!bestXBang || bang depth < bestXBang depth) {
				bestXBang = bang
				bestXBlock = block
			    }
			} else {
			    if (!bestYBang || bang depth < bestYBang depth) {
				bestYBang = bang
				bestYBlock = block
			    }
			}

			if (bang dir y < 0) {
			    velY = 0
			}
		    }

		    if (block image == "level-end") {
			ui flash("You won!")
			level play(Random choice(winSounds))
			level nextLevel()
		    }
		}
	    }

	    if (bestYBang) {
		running = true
		pos add!(bestYBang dir mul(bestYBang depth))
		if (bestYBlock image != "ice") {
		    hadCollision = true
		}
	    }
	    if (bestXBang) {
		running = true
		pos add!(bestXBang dir mul(bestXBang depth))
		if (bestXBlock image == "ice") {
		    hadCollision = false
		} else {
		    velX = 0.0
		}
	    }
	}

	if (hadCollision) {
	    dampX()
	}
    }

    dampX: func {
	velX *= 0.9
    }

    die: func {
	ui flash("You died!")
	level play(Random choice(loseSounds))
	level loadLevel()
    }

    destroy: func {
	level objectPass removeSprite(sprite)
	input nuke()
    }

}




import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Collision]
import Level, Block, Bullet

Hero: class extends Actor {

    engine: Engine
    level: Level
    ui: UI
    input: Proxy

    pos: Vec2
    velX := 0
    velY := 0

    offset := vec2(2, -25)
    collisionOffset := vec2(3, 0)
    box: Box

    sprite: ImageSprite

    init: func (=engine, =level, =pos) {
	ui = engine ui

	pos add!(offset)
	sprite = ImageSprite new(pos, "assets/png/hero.png")

	box = Box new(vec2(0, 0), 26, sprite height)

	ui levelPass addSprite(sprite)

	setupEvents()
    }

    setupEvents: func {
	input = ui input sub()
	input onKeyPress(Keys SPACE, ||
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
		Bullet new(engine, level,
		    pos add(sprite width / 2,
		    10 + sprite height / 2),
		    dir normalized())
	    }
	)
    }

    update: func (delta: Float) {
	pos add!(velX, velY)

	handleCollisions()

	velY += 3
	if (velY > 8) {
	    velY = 8
	}
	velX *= 0.8
    }

    handleCollisions: func {
	running := true

	counter := 0
	while (running) {
	    counter += 1
	    if (counter > 16) {
		ui flash("You died!")
		level loadLevel()
		break
	    }

	    box pos set!(pos add(collisionOffset))

	    running = false

	    bestXBang: Bang = null
	    bestYBang: Bang = null

	    for(block in level blocks) {
		bang := box collide(block box)
		if (bang) {
		    if (block solid) {
			block applyThrust()

			if (bang dir y == 0) {
			    if (!bestXBang || bang depth < bestXBang depth) {
				bestXBang = bang
			    }
			} else {
			    if (!bestYBang || bang depth < bestYBang depth) {
				bestYBang = bang
			    }
			}

			if (bang dir y < 0) {
			    velY = 0
			}
		    }

		    if (block image == "level-end") {
			ui flash("You won!")
			level nextLevel()
		    }
		}
	    }

	    if (bestXBang) {
		running = true
		"pos = %s, XBang = %s" printfln(pos _, bestXBang _)
		pos add!(bestXBang dir mul(bestXBang depth))
	    }
	    if (bestYBang) {
		running = true
		pos add!(bestYBang dir mul(bestYBang depth))
	    }
	}
    }

    destroy: func {
	engine remove(this)
	ui levelPass removeSprite(sprite)
	input nuke()
    }

}



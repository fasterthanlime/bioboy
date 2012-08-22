
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input]
import Collision, Level, Block

Hero: class extends Actor {

    engine: Engine
    level: Level
    ui: UI

    pos: Vec2
    velY := 0

    offset := vec2(2, -25)
    collisionOffset := vec2(4, -25)
    box: Box

    sprite: ImageSprite

    init: func (=engine, =level, =pos) {
	engine add(this)
	ui = engine ui

	sprite = ImageSprite new(pos, "assets/png/hero.png")
	sprite offset set!(offset)

	box = Box new(vec2(0, 0), 28, sprite height)

	ui levelPass addSprite(sprite)

	setupEvents()
    }

    setupEvents: func {
    }

    update: func (delta: Float) {
	if (velY < 8) {
	    velY += 1
	}
	pos add!(0, velY)

	if (ui input isPressed(Keys LEFT)) {
	    pos add!(-4, 0)
	} else if (ui input isPressed(Keys RIGHT)) {
	    pos add!(4, 0)
	}

	handleCollisions()
    }

    handleCollisions: func {
	box pos set!(pos add(collisionOffset))


	bestXBang: Bang = null
	bestYBang: Bang = null

	for(block in level blocks) {
	    bang := box collide(block box)
	    if (bang) {
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
	}

	if (bestXBang) {
	    pos add!(bestXBang dir mul(bestXBang depth))
	}
	if (bestYBang) {
	    pos add!(bestYBang dir mul(bestYBang depth))
	}
    }

}



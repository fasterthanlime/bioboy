
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Collision]
import Level, Hero

Block: class extends Actor {

    SIDE := static 32

    engine: Engine
    level: Level

    image: String
    x, y: Int

    box: Box
    dir := vec2(0, 0)
    pos: Vec2

    inert := false
    solid := false

    speed := 4.0

    sprite: ImageSprite

    init: func (=engine, =level, =image, =x, =y) {
	path := "assets/png/%s.png" format(image)

	pos = vec2(x * SIDE, y * SIDE)
	sprite = ImageSprite new(pos, path)
	box = Box new(pos, SIDE - 1, SIDE - 1)

	setupAttributes()
    }

    setupAttributes: func {
	if (image == "inert") {
	    inert = true
	}

	if (image != "level-end") {
	    solid = true
	}
    }

    touch: func (bang: Bang) {
	match image {
	    case "dblock-r" =>
		dir = vec2(1, 0)
	    case "dblock-l" =>
		dir = vec2(-1, 0)
	    case "dblock-d" =>
		dir = vec2(0, 1)
	    case "dblock-u" =>
		dir = vec2(0, -1)
	}
    }

    update: func (delta: Float) {
	if (dir squaredNorm() > 0.01) {
	    pos add!(dir mul(speed))

	    for (block in level blocks) {
		if (block == this) continue
		if (block inert) {
		    bang := box collide(block box)
		    if (bang) {
			block touch(bang)
			pos add!(bang dir mul(bang depth))
			pos set!(pos snap(SIDE))
			dir set!(0, 0)
		    }
		}
	    }

	    bang := box collide(level hero box)
	    if (bang) {
		applyThrust()
	    }
	}
    }

    applyThrust: func {
	factor := 1.4

	match true {
	    case (dir x > 0.1) =>
		level hero velX = speed * factor
	    case (dir x < -0.1) =>
		level hero velX = -speed * factor
	    case (dir y > 0.1) =>
		level hero velY = speed * factor
	    case (dir y < -0.1) =>
		level hero velY = -speed * factor
	}
    }

    destroy: func {
	engine remove(this)
	level ui levelPass removeSprite(sprite)
    }

}



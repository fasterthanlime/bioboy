
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Collision]
import Level, Hero

Block: class extends Actor {

    SIDE := static 32

    engine: Engine
    level: Level

    image: String
    x, y: Int

    permanent := false

    box: Box
    dir := vec2(0, 0)
    pos: Vec2

    inert := false
    solid := false

    speed := 6.0

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
	if (!permanent) {
	    kick()
	}
    }

    kick: func {
	match image {
	    case "dblock-r" =>
		dir set!(1, 0)
	    case "dblock-l" =>
		dir set!(-1, 0)
	    case "dblock-d" =>
		dir set!(0, 1)
	    case "dblock-u" =>
		dir set!(0, -1)
	    case "ice" =>
		_destroy()
	}
    }

    update: func (delta: Float) {
	if (dir squaredNorm() > 0.01) {
	    pos add!(dir mul(speed))

	    for (block in level blocks) {
		if (block == this) continue
		bang := box collide(block box)
		if (bang) {
		    if (block inert || block dir squaredNorm() < 0.1) {
			block touch(bang)
			pos add!(bang dir mul(bang depth))
			pos set!(pos snap(SIDE))
			if (permanent) {
			    dir set!(dir mul(-1))
			} else {
			    dir set!(0, 0)
			}
			level play("boom")
		    }
		}
	    }

	    bang := box collide(level hero box)
	    if (bang) {
		applyThrust()
	    }
	} else {
	    if (permanent) {
		kick()
	    }
	}
    }

    applyThrust: func {
	factor := 1.2

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
	level ui levelPass removeSprite(sprite)
    }

    _destroy: func {
	level blocks remove(this)
	destroy()
    }

}



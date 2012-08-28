
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Collision]
import Level, Hero, Bullet

Block: class extends Actor {

    SIDE := static 32

    engine: Engine
    level: Level

    image: String
    x, y: Int

    permanent := false
    dead := false
    destructible := true
    permeable := false
    slippery := false

    box: Box
    dir := vec2(0, 0)
    pos: Vec2

    inert := false
    solid := true

    // only relevant for bomb (pretty code o/)
    countdown := -1
    blinkCount := 0

    speed := 3.0

    playCount := 0

    sprite: ImageSprite

    init: func (=engine, =level, =image, =x, =y) {
	path := "assets/png/%s.png" format(image)

	pos = vec2(x * SIDE, y * SIDE)
	sprite = ImageSprite new(pos, path)
	level objectPass addSprite(sprite)

	box = Box new(pos, SIDE - 1, SIDE - 1)

	setupAttributes()
    }

    setupAttributes: func {
	if (image == "inert") {
	    inert = true
	}

	if (image == "level-end" || image == "bump") {
	    solid = false
	}

	if (image == "net") {
	    permeable = true
	}

	if (image == "ice" || image == "net") {
	    slippery = true
	}
    }

    explodeTouch: func {
	if (image startsWith?("bomb")) {
	    countdown = 4
	} else {
	    _destroy()
	}
    }

    touch: func (bang: Bang) {
	if (!permanent) {
	    kick()
	}
    }

    orientation: func -> Vec2 {
	match image {
	    case "dblock-r" =>
		vec2(1, 0)
	    case "dblock-l" =>
		vec2(-1, 0)
	    case "dblock-d" =>
		vec2(0, 1)
	    case "dblock-u" =>
		vec2(0, -1)
	    case =>
		vec2(0, 0)
	}
    }

    kick: func {
	match image {
	    case "ice" =>
		_destroy()
	    case "bomb" =>
		if (countdown <= 0) {
		    countdown = 59
		}
	    case =>
		if (!dead) {
		    dir set!(orientation())
		}
	}
    }

    update: func (delta: Float) {
	if (dead) return

	if (playCount > 0) {
	    playCount -= 1
	}

	if (image == "blink") {
	    blinkCount += 1
	    if (blinkCount >= 50) {
		solid = !solid
		sprite alpha = (solid ? 1.0 : 0.2)
		blinkCount = 0
	    }
	}

	if (countdown >= 0) {
	    countdown -= 1
	    newImage := "bomb%d" format(countdown / 10)
	    if (image != newImage) {
		image = newImage

		level objectPass removeSprite(sprite)
		sprite = ImageSprite new(pos, "assets/png/%s.png" format(image))
		level objectPass addSprite(sprite)
	    }

	    if (countdown == 0) {
		Explosion new(engine, level objectPass, pos add(sprite width / 2, sprite height / 2), "prouf")
		level play("prouf")
		for(n in level neighbors(pos)) {
		    n explodeTouch()
		}
		_destroy()
	    }
	}

	moving := dir squaredNorm() > 0.01

	if (moving) {
	    pos add!(dir mul(speed))

	    for (block in level blocks) {
		if (block == this) continue
		bang := box collide(block box)
		if (bang) {
		    if ((block inert || block dir squaredNorm() < 0.1) && (block image != "net")) {
			dir1 := dir
			dir2 := block orientation()
			dot := dir1 dot(dir2)
			//"our dir = %s, their dir = %s, dot = %.2f" printfln(dir1 _, dir2 _, dot)

			if (dot >= -0.5) {
			    block touch(bang)
			}

			pos add!(bang dir mul(bang depth))
			pos set!(pos snap(SIDE))
			if (permanent) {
			    dir set!(dir mul(-1))
			} else {
			    dir set!(0, 0)
			    if (block inert) {
				dead = true	
			    }
			}
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
	factor := 1.11

	match true {
	    case (dir x > 0.1) =>
		level hero velX = speed * factor
	    case (dir x < -0.1) =>
		level hero velX = -speed * factor
	    case (dir y > 0.1) =>
		level hero velY = speed * factor
		level hero dampX()
	    case (dir y < -0.1) =>
		level hero velY = -speed * factor
		level hero dampX()
	}
    }

    destroy: func {
	level objectPass removeSprite(sprite)
    }

    _destroy: func {
	level blocks remove(this)
	destroy()
    }

}



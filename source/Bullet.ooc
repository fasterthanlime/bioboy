
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Collision]
import Level, Block, Hero

Bullet: class extends Actor {

    engine: Engine
    level: Level
    ui: UI

    pos: Vec2
    dir: Vec2
    speed := 16.0

    box: Box

    sprite: ImageSprite

    init: func (=engine, =level, =pos, =dir) {
	engine add(this)
	ui = engine ui

	sprite = ImageSprite new(pos, "assets/png/bullet.png")
	sprite offset set!(-6, -6)
	ui levelPass addSprite(sprite)
	
	box = Box new(vec2(0, 0), sprite width, sprite height)

	level play("plop")
    }

    update: func (delta: Float) {
	pos add!(dir mul(speed))
	box pos set!(pos add(sprite offset))

	for(block in level blocks) {
	    bang := box collide(block box)
	    if (bang) {
		block touch(bang)
		level play("fire")

	        dist := level hero pos sub(pos) norm()

		radius := 160.0
		recoil := 16.0

		if (dist < radius) {
		    factor := - (1.0 - dist / radius) * recoil
		    level hero velX += factor * dir x
		    level hero velY += factor * dir y
		}
		_destroy()
		break
	    }
	}
    }

    destroy: func {
	ui levelPass removeSprite(sprite)
    }

    _destroy: func {
	destroy()
	engine remove(this)
    }

}



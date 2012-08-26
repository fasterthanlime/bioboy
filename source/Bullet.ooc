
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Input, Collision, Pass, Colors]
import Level, Block, Hero, Power

DamageLabel: class extends Actor {

    engine: Engine
    pass: Pass

    sprite: LabelSprite

    counter := 0
    maxCounter := 100

    init: func (=engine, =pass, pos: Vec2, damage: Int) {
	sprite = LabelSprite new(pos, "- %d" format(damage))
	sprite fontSize = 30.0
	sprite color set!(Colors red)

	engine add(this)
	pass addSprite(sprite)
    }

    update: func (delta: Float) {
	counter += 1

	sprite alpha = (maxCounter - counter) / (1.0 * maxCounter)
	sprite pos add!(0, -1)

	if (counter >= maxCounter) {
	    destroy()
	}
    }

    destroy: func {
	pass removeSprite(sprite)
    }

    _destroy: func {
	destroy()
	engine remove(this)
    }

}

Bullet: class extends Actor {

    engine: Engine
    level: Level
    ui: UI

    pos: Vec2
    dir: Vec2
    speed := 12.0

    box: Box

    sprite: ImageSprite

    init: func (=engine, =level, =pos, =dir) {
	engine add(this)
	ui = engine ui

	sprite = ImageSprite new(pos, "assets/png/bullet.png")
	sprite offset set!(-6, -6)
	level objectPass addSprite(sprite)
	
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

		if (level hero hasPower(Power DGUN)) {
		    level play("fire")

		    diff := level hero pos sub(level hero offset) sub(pos)
		    diff x *= 1.2

		    dist := diff norm()
		    radius := 180.0
		    recoil := 8.0

		    if (dist < radius) {
			factor := - (1.0 - dist / radius) * recoil
			level hero velX += factor * dir x
			level hero velY += factor * dir y
		    }

		    damageRadius := 60.0
		    damage := 40
		    armor := (level hero hasPower(Power ARMOR) ? 0.3 : 1.0)

		    if (dist < damageRadius) {
			totalDamage := (damageRadius - dist) / damageRadius * damage * armor
			if (totalDamage > 1.0) {

			    DamageLabel new(engine, level hudPass, level hero pos add(0, -10), totalDamage)
			    level life -= totalDamage
			}
		    }
		} else {
		    level play("plop")
		}

		_destroy()
		break
	    }
	}
    }

    destroy: func {
	level objectPass removeSprite(sprite)
    }

    _destroy: func {
	destroy()
	engine remove(this)
    }

}



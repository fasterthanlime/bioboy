
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor]

Hero: class extends Actor {

    engine: Engine

    pos: Vec2

    sprite: ImageSprite

    init: func (=engine, =pos) {
	sprite = ImageSprite new(pos, "assets/png/hero.png")
	sprite offset set!(2, -25)

	engine ui levelPass addSprite(sprite)
	engine add(this)
    }

    update: func (delta: Float) {
	pos add!(1, 0)
    }

}




import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Collision]
import Level

Block: class extends Actor {

    SIDE := static 32

    engine: Engine
    level: Level

    image: String
    x, y: Int

    box: Box
    dir := vec2(0, 0)
    pos: Vec2

    speed := 4.0

    sprite: ImageSprite

    init: func (=engine, =level, =image, =x, =y) {
	engine add(this)
	path := "assets/png/%s.png" format(image)

	pos = vec2(x * SIDE, y * SIDE)
	sprite = ImageSprite new(pos, path)
	box = Box new(pos, SIDE, SIDE)
    }

    touch: func (bang: Bang) {
	"Touched! at %s" printfln(sprite pos _)

	match image {
	    case "dblock-r" =>
		dir = vec2(1, 0)
	    case "dblock-l" =>
		dir = vec2(-1, 0)
	    case "dblock-d" =>
		dir = vec2(0, -1)
	    case "dblock-u" =>
		dir = vec2(0, 1)
	}
    }

    update: func (delta: Float) {
	if (dir squaredNorm() > 0) {
	    pos add!(dir mul(speed))
	}
    }

}



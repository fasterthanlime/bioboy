
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Collision]

Block: class {

    SIDE := static 32

    image: String
    x, y: Int

    box: Box

    sprite: ImageSprite

    init: func (=image, =x, =y) {
	path := "assets/png/%s.png" format(image)

	pos := vec2(x * SIDE, y * SIDE)
	sprite = ImageSprite new(pos, path)
	box = Box new(pos, SIDE, SIDE)
    }

    touch: func (bang: Bang) {
	"Touched! at %s" printfln(sprite pos _)
    }

}



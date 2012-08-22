
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor]

Block: class {

    SIDE := static 32

    image: String
    x, y: Int

    sprite: ImageSprite

    init: func (=image, =x, =y) {
	path := "assets/png/%s.png" format(image)
	sprite = ImageSprite new(vec2(x * SIDE, y * SIDE), path)

	if (image == "hero") {
	    sprite offset set!(2, -20)
	}
    }

}



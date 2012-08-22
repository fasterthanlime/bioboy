
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor]

Level: class {

    engine: Engine

    ui: UI

    init: func (=engine) {
	ui = engine ui

	fog := ImageSprite new(vec2(0, 0), "assets/png/fog.png")
	ui bgPass addSprite(fog)

	label := LabelSprite new(vec2(150, 100), "Hi world")
	ui hudPass addSprite(label)

	engine onTick(|delta|
	    label pos add!(vec2(1, 0))
	)
    }

}

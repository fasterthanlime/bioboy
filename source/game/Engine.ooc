
// game deps
import ui/MainUI

// libs deps
use zombieconfig
import zombieconfig
import ldkit/Timing

Engine: class {

    ui: MainUI

    init: func (config: ZombieConfig) {
	ui = MainUI new(this, config)

	counter := 200

	while (counter > 0) {
	    counter -= 1
	    LTime delay(20)
	    ui update()
	}

	exit(0)
    }

}


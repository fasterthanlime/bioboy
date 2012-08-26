
use zombieconfig, ldkit, deadlogger

import zombieconfig
import ldkit/[Engine, Dead, Math, Sprites, UI]
import deadlogger/Logger
import structs/ArrayList

import Level, Story, Menu, LevelSelect

main: func (args: ArrayList<String>) {
    Game new()
}

Game: class {

    levelSelect: LevelSelect
    level: Level
    story: Story
    menu: Menu

    init: func {

	logger := Dead logger("main")
	logger info("bioboy starting up!")

	// load config
	configPath := "config/bioboy.config"
	config := ZombieConfig new(configPath, |base|
	    base("screenWidth", "1024")
	    base("screenHeight", "768")
	    base("fullScreen", "true")
	    base("title", "bioboy")
	)
	logger info("configuration loaded from %s" format(configPath))

	engine := Engine new(config)

	level = Level new(engine, |success|
	    if (success) {
		levelSelect success()
	    }
	    levelSelect	updateSelector(success ? 1 : 0, 0)
	    levelSelect enter()
	)

	levelSelect = LevelSelect new(engine, |levelFile|
	    if(level jumpTo(levelFile)) {
		levelSelect clear()
	    }
	)

	menu = Menu new(engine, ||
	    levelSelect enter()
	)

	story = Story new(engine, "intro", ||
	    menu enter()
	)
	story loadCard()

	engine run()

    }

}


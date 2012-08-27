
use zombieconfig, ldkit, deadlogger

import zombieconfig
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor]
import deadlogger/Logger
import structs/ArrayList

import Level, Story, Menu, LevelSelect, Instructions

main: func (args: ArrayList<String>) {
    Game new()
}

Game: class extends Actor {

    levelSelect: LevelSelect
    level: Level
    story: Story
    menu: Menu
    instructions: Instructions

    shouldSelectLevels := false

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
	
	// customize UI a bit
	engine ui mousePass enabled = false
	engine ui escQuits = false

	menu = Menu new(engine, ||
	    scheduleLevelSelect()
	, ||
	    instructions enter()
	)

	instructions = Instructions new(engine, ||
	    menu enter()
	)

	levelSelect = LevelSelect new(engine, |levelFile|
	    if(level jumpTo(levelFile)) {
		levelSelect clear()
	    }
	, ||
	    levelSelect clear()
	    menu enter()
	)

	level = Level new(engine, levelSelect, |success|
	    level clear()
	    if (success) {
		levelSelect success(level millis)
	    }
	    levelSelect	updateSelector(success ? 1 : 0, 0)
	    levelSelect enter()
	)
	level clear()

	story = Story new(engine, "intro", ||
	    menu enter()
	)
	story loadCard()

	engine add(this)
	engine run()

    }

    scheduleLevelSelect: func {
	shouldSelectLevels = true
    }

    update: func (delta: Float) {
	if(shouldSelectLevels) {
	    shouldSelectLevels = false
	    levelSelect enter()
	}
    }

}


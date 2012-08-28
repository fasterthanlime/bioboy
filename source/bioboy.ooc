
use zombieconfig, ldkit, deadlogger

import zombieconfig
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Sound]
import deadlogger/Logger
import structs/ArrayList

import Level, Story, Menu, LevelSelect, Instructions

main: func (args: ArrayList<String>) {
    Game new()
}

Game: class extends Actor {

    musics := ["drama", "spywillie", "castle", "valse"] as ArrayList<String>
    musicSource: Source
    currentMusic := 0

    levelSelect: LevelSelect
    level: Level
    story: Story
    menu: Menu
    engine: Engine
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

	engine = Engine new(config)
	
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

	play("assets/ogg/music/piano.ogg")

	engine add(this)
	engine run()
    }

    play: func (path: String) {
	if (musicSource) {
	    musicSource free()
	}

	sample := engine ui boombox load(path)
	musicSource = engine ui boombox play(sample)
    }

    musicPath: func -> String {
	"assets/ogg/music/%s.ogg" format(musics get(currentMusic))
    }

    scheduleLevelSelect: func {
	shouldSelectLevels = true
    }

    update: func (delta: Float) {
	if(shouldSelectLevels) {
	    shouldSelectLevels = false
	    levelSelect enter()
	    play(musicPath())
	}

	if (musicSource && musicSource getState() == SourceState STOPPED) {
	    currentMusic += 1
	    if (currentMusic >= musics size) {
		currentMusic = 0
	    }
	    play(musicPath())
	}
    }

}


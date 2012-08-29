
use zombieconfig, ldkit, deadlogger

import zombieconfig
import ldkit/[Engine, Dead, Math, Sprites, UI, Actor, Sound]
import deadlogger/Logger
import structs/[ArrayList, Stack]

import Level, Story, Menu, LevelSelect, Instructions

main: func (args: ArrayList<String>) {
    Game new()
}

GameEvent: class {

    name: String
    
    init: func (=name) {}

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

    events := Stack<GameEvent> new()

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

	menu = Menu new(engine, this) 

	instructions = Instructions new(engine, this)

	levelSelect = LevelSelect new(engine, this)

	level = Level new(engine, levelSelect, this)
	level clear()

	story = Story new(engine, "intro", this)
	story loadCard()

	play("assets/ogg/music/piano.ogg")

	engine add(this)
	engine run()
    }

    notify: func (event: GameEvent) {
	events push(event)
    }

    on: func (name: String) {
	notify(GameEvent new(name))
    }

    play: func (path: String) {
	if (musicSource) {
	    engine ui boombox freeSource(musicSource)
	}

	sample := engine ui boombox load(path, true)
	musicSource = engine ui boombox play(sample)
    }

    musicPath: func -> String {
	"assets/ogg/music/%s.ogg" format(musics get(currentMusic))
    }

    update: func (delta: Float) -> Bool {
	if (musicSource && musicSource getState() == SourceState STOPPED) {
	    currentMusic += 1
	    if (currentMusic >= musics size) {
		currentMusic = 0
	    }
	    play(musicPath())
	}

	while (!events empty?()) {
	    ev := events pop()
	    handleEvent(ev)
	}

	false
    }

    handleEvent: func (ev: GameEvent) {
	match (ev name) {
	    case "return-to-menu" =>
		menu enter()

	    case "menu-play" =>
		levelSelect enter()
		play(musicPath())
	    case "menu-instructions" =>
		instructions enter()

	    case "levelselect-play" =>
		if (level jumpTo(levelSelect item file)) {
		    levelSelect clear()
		}

	    case "level-success" =>
		levelSelect success(level millis)
		levelSelect updateSelector(1, 0)
		levelSelect enter()

	    case "level-fail" =>
		levelSelect updateSelector(0, 0)
		levelSelect enter()

	    case "quit" =>
		engine quit()
	}
    }

}


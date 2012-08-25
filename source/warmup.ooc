
use zombieconfig, ldkit, deadlogger

import zombieconfig
import ldkit/[Engine, Dead, Math, Sprites, UI]
import deadlogger/Logger
import structs/ArrayList

import Level

main: func (args: ArrayList<String>) {

    logger := Dead logger("main")
    logger info("warmup starting up!")

    // load config
    configPath := "config/warmup.config"
    config := ZombieConfig new(configPath, |base|
	base("screenWidth", "1024")
	base("screenHeight", "768")
	base("fullScreen", "true")
	base("title", "warmup")
    )

    levelNum := 1

    if (args size > 1) {
	levelNum = args[1] toInt()
    }

    logger info("configuration loaded from %s" format(configPath))

    engine := Engine new(config)

    level := Level new(engine, levelNum)

    menu := Menu new(engine, ||
	level loadLevel()
    )

    story := Story new(engine, "intro", ||
	menu enter()
    )
    story loadCard()

    engine run()

}

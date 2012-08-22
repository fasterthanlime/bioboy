
use zombieconfig, ldkit, deadlogger

import zombieconfig
import ldkit/[Engine, Dead, Math, Sprites, UI]
import deadlogger/Logger

import Level

main: func {

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

    logger info("configuration loaded from %s" format(configPath))

    engine := Engine new(config)

    level := Level new(engine)

    engine run()

}

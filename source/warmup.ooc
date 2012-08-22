
use zombieconfig, ldkit, deadlogger

import zombieconfig
import ldkit/[Engine, Dead]
import deadlogger/Logger

main: func {

    logger := Dead logger("main")
    logger info("warmup starting up!")

    // load config
    configPath := "config/warmup.config"
    config := ZombieConfig new(configPath, |base|
	base("screenWidth", "1280")
	base("screenHeight", "720")
    )

    logger info("configuration loaded from %s" format(configPath))

    engine := Engine new(config)
    engine run()

}

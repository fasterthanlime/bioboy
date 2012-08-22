
import game/Engine

use zombieconfig, deadlogger
import zombieconfig
import deadlogger/[Log, Handler, Formatter, Filter]

main: func {

    console := StdoutHandler new()
    console setFormatter(ColoredFormatter new(NiceFormatter new()))
    Log root attachHandler(console)

    logger := Log getLogger("main")
    logger info("warmup starting up!")

    // load config
    configPath := "config/warmup.config"
    config := ZombieConfig new(configPath, |base|
	base("screenWidth", "1280")
	base("screenHeight", "720")
    )

    logger info("configuration loaded from %s" format(configPath))

    Engine new(config)

}

import text/StringTokenizer

TimeHelper: class {

    MILLIS_IN_MINUTES := static 60 * 1000
    MILLIS_IN_SECONDS := static 1000
    MILLIS_IN_TENTHS := static 10

    format: static func (millis: Long) -> String {
	if (millis == -1) {
	    return "Unknown"
	}

	// Look, I'm not always proud of my code, okay?
	rest := millis

	minutes := (rest - (rest % MILLIS_IN_MINUTES)) / MILLIS_IN_MINUTES
	rest -= minutes * MILLIS_IN_MINUTES	

	seconds := (rest - (rest % MILLIS_IN_SECONDS)) / MILLIS_IN_SECONDS
	rest -= seconds * MILLIS_IN_SECONDS

	tenths := (rest - (rest % MILLIS_IN_TENTHS)) / MILLIS_IN_TENTHS

	"%d\"%02d'%02d" format(minutes, seconds, tenths)
    }

    parse: static func (s: String) -> Long {
	tokens := s split("\"")
	
	minutes := tokens get(0) toInt()
	secondsAndTenths := tokens get(1)

	tokens2 := secondsAndTenths split("'")
	seconds := tokens2 get(0) toInt()
	tenths := tokens2 get(1) toInt()

	minutes * MILLIS_IN_MINUTES + seconds * MILLIS_IN_SECONDS + tenths * MILLIS_IN_TENTHS
    }

}

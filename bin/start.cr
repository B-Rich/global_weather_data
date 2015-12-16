require "../src/global_weather_data"

w = GlobalWeatherData::WeatherStatsManager.new
w.process_path("input")

# p = GlobalWeatherData::InputPathProcessor.new
# p.make_it_so


# l = Logger.new(STDOUT)
# l.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
#                       io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
#                       io << severity.rjust(5) << ": " << message
#                     end
#
# i = GlobalWeatherData::InputProcessor.new(l)
#
# i.process_file("input/-imetar-METAR2014-07-01.csv")
# i.sort_and_filter
# i.store_output("data/METAR2014-07-01.csv")
# i.store_stats("data/2014-07-01")
#
# i = GlobalWeatherData::InputProcessor.new
# i.process_file("input/-imetar-METAR2015-01-04.csv")
# i.sort_and_filter
# i.store_output("data/METAR2015-01-04.csv")
# i.store_stats("data/2015-01-04")

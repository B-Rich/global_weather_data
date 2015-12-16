require "logger"
require "crystal_metar_parser"

class GlobalWeatherData::InputPathProcessor
  def initialize
    @logger = Logger.new(STDOUT)
    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
                          io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
                          io << severity.rjust(5) << ": " << message
                        end

  end

  def make_it_so
    @logger.info("Start")
    sleep 0.001

    Dir.new("input").each do |f|
      if f =~ /(METAR\d{4}-\d{2}-\d{2})/
        processor = GlobalWeatherData::InputProcessor.new(@logger)
        processor.process_file("input/#{f}")
        processor.sort_and_filter
        processor.store_output("data/#{$1}.csv")
        processor.store_stats("data/#{$1}")
      end
    end

    sleep 0.05
  end
end

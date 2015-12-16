require "logger"
require "crystal_metar_parser"

class GlobalWeatherData::InputProcessor
  def initialize(l = Logger.new(STDOUT))
    @logger = l as Logger
    @logger.info "Start"
    @data = Array(CrystalMetarParser::Metar).new

    @max_temps = Hash(String, Float64).new
    @min_temps = Hash(String, Float64).new

    @max_winds = Hash(String, Float64).new
    @min_winds = Hash(String, Float64).new
  end

  def process_file(path)
    @logger.info("Start process #{path}")
    f = File.open(path)
    f.each_line do |line|
      begin
        metar = CrystalMetarParser::Parser.parse(line.gsub(/,/, " "))
        if metar.temperature.degrees != -255 && metar.city.code != ""
          # metar ok
          @data << metar
        end
      rescue
      end

    end
    f.close

    @logger.info("Finish process #{path}")
  end

  def sort_and_filter
    @logger.info("Start sort")

    @data = @data.sort{ |a,b|
      a.temperature.degrees <=> b.temperature.degrees
    }

    @logger.info("Finish sort")
  end

  def store_output(path)
    @logger.info("Start store #{path}")

    f = File.open(path, "w")
    @data.each do |metar|
      f.puts "#{metar.city.code}; #{metar.temperature.degrees}; #{metar.wind.kmh}"
    end
    f.close

    @logger.info("Finish store #{path}")
  end

  def store_stats(path)
    @logger.info("Start stats #{path}")

    @data.each do |metar|
      if @max_temps.has_key?(metar.city.code)
        if @max_temps[metar.city.code] < metar.temperature.degrees
          @max_temps[metar.city.code] = metar.temperature.degrees
        end
      else
        @max_temps[metar.city.code] = metar.temperature.degrees
      end

      if @min_temps.has_key?(metar.city.code)
        if @min_temps[metar.city.code] > metar.temperature.degrees
          @min_temps[metar.city.code] = metar.temperature.degrees
        end
      else
        @min_temps[metar.city.code] = metar.temperature.degrees
      end

      if @max_winds.has_key?(metar.city.code)
        if @max_winds[metar.city.code] < metar.wind.speed
          @max_winds[metar.city.code] = metar.wind.speed
        end
      else
        @max_winds[metar.city.code] = metar.wind.speed
      end

      if @min_winds.has_key?(metar.city.code)
        if @min_winds[metar.city.code] > metar.wind.speed
          @min_winds[metar.city.code] = metar.wind.speed
        end
      else
        @min_winds[metar.city.code] = metar.wind.speed
      end


    end

    f = File.open(path + "_temp_min.csv", "w")
    @min_temps.keys.sort{|a,b|
      @min_temps[a] <=> @min_temps[b]
    }.each do |k|
      f.puts "#{k}; #{@min_temps[k]}"
    end
    f.close

    f = File.open(path + "_temp_max.csv", "w")
    @max_temps.keys.sort{|a,b|
      @max_temps[a] <=> @max_temps[b]
    }.each do |k|
      f.puts "#{k}; #{@max_temps[k]}"
    end
    f.close

    f = File.open(path + "_wind_min.csv", "w")
    @min_winds.keys.sort{|a,b|
      @min_winds[a] <=> @min_winds[b]
    }.each do |k|
      f.puts "#{k}; #{@min_winds[k]}"
    end
    f.close

    f = File.open(path + "_wind_max.csv", "w")
    @max_winds.keys.sort{|a,b|
      @max_winds[a] <=> @max_winds[b]
    }.each do |k|
      f.puts "#{k}; #{@max_winds[k]}"
    end
    f.close

    @logger.info("Finish stats #{path}")
  end

end

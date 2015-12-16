require "json"
require "yaml"
require "colorize"

class GlobalWeatherData::WeatherStatsManager
  def initialize
    @cities = Hash(String, GlobalWeatherData::WeatherStatsCity).new

    @i = Int64.new(0)
    @i_verbose_every = 10000

    @total_time_cost = 0.0
  end

  def process_path(path)
    files_filtered = Array(String).new
    Dir.entries(path).each do |f|
      if f =~ /METAR(\d{4})-(\d{2})-(\d{2})/
        files_filtered << f
      end
    end

    files_filtered.sort.each_with_index do |f,i|
      if f =~ /METAR(\d{4})-(\d{2})-(\d{2})/
        puts "processing file #{f}, #{i.to_s.colorize(:green)}/#{files_filtered.size.to_s.colorize(:yellow)}"

        t = Time.now

        time = Time.new($1.to_i, $2.to_i, $3.to_i)
        file = File.new( File.join([path, f]) )
        file.each_line do |line|
          add_metar_string(line, time)
        end
        file.close
        cost = Time.now - t

        @total_time_cost += cost.to_f

        puts "file done, #{i.to_s.colorize(:green)}/#{files_filtered.size.to_s.colorize(:yellow)}, cost #{cost.to_i.to_s.colorize(:red)} seconds"

        begin
          avg_cost_per_file = @total_time_cost / (i.to_f + 1.0)
          files_needed_to_process = files_filtered.size.to_f - i.to_f
          estimated_cost = files_needed_to_process * avg_cost_per_file

          puts "estimated #{ (estimated_cost / 60.0).round(2).to_s.colorize(:light_red) } minutes, #{estimated_cost} seconds, total time #{@total_time_cost}"
        rescue
          # just in case
        end
      end
    end

    write_output
  end

  def add_metar_string(string, time)
    options = {
      ":year" => time.year.to_s,
      ":month" => time.month.to_s
    }
    s = string.gsub(/,/, " ")

    begin
      metar = CrystalMetarParser::Parser.parse(s, options)
      add_metar(metar) if metar.city.code != ""
    rescue ArgumentError
      #puts metar.time.time_from
    end
  end

  def increment_counter
    if @i % @i_verbose_every == 0
      puts "added #{@i}"
    end
    @i += 1
  end

  def add_metar(metar)
    increment_counter

    k = metar.city.code
    unless @cities.has_key?(k)
      @cities[k] = GlobalWeatherData::WeatherStatsCity.new
      @cities[k].code = k
    end

    @cities[k].add_metar(metar)
  end

  def write_output
    write_output_monthly_temp
    write_output_monthly_wind
    write_output_full
  end

  def write_output_monthly_temp
    puts "writind monthly temp"

    # max
    f = File.new("data/stats_monthly_temp_max.csv", "w")
    @cities.keys.sort{|a,b| @cities[a].max_temp <=> @cities[b].max_temp }.each do |k|
      c = @cities[k]

      s = ""
      s += "#{k}; "

      (1..12).each do |m|
        if c.winds_monthly_max.has_key?(m)
          d = c.temperatures_monthly_max[m]
          s += "#{d}; "
        else
          s += "; "
        end
      end

      f.puts s
    end

    f.close

    # min
    f = File.new("data/stats_monthly_temp_min.csv", "w")
    @cities.keys.sort{|a,b| @cities[a].min_temp <=> @cities[b].min_temp }.each do |k|
      c = @cities[k]

      s = ""
      s += "#{k}; "

      (1..12).each do |m|
        if c.winds_monthly_min.has_key?(m)
          d = c.temperatures_monthly_min[m]
          s += "#{d}; "
        else
          s += "; "
        end
      end

      f.puts s
    end

    f.close
    puts "done"
  end

  def write_output_monthly_wind
    puts "writind monthly wind"

    # max
    f = File.new("data/stats_monthly_wind_max.csv", "w")
    @cities.keys.sort{|a,b| @cities[a].max_wind <=> @cities[b].max_wind }.each do |k|
      c = @cities[k]

      s = ""
      s += "#{k}; "

      (1..12).each do |m|
        if c.winds_monthly_max.has_key?(m)
          d = c.winds_monthly_max[m]
          s += "#{d}; "
        else
          s += "; "
        end
      end

      f.puts s
    end

    f.close

    # min
    f = File.new("data/stats_monthly_wind_min.csv", "w")
    @cities.keys.sort{|a,b| @cities[a].min_temp <=> @cities[b].min_temp }.each do |k|
      c = @cities[k]

      s = ""
      s += "#{k}; "

      (1..12).each do |m|
        if c.winds_monthly_min.has_key?(m)
          d = c.winds_monthly_min[m]
          s += "#{d}; "
        else
          s += "; "
        end
      end

      f.puts s
    end

    f.close
    puts "done"
  end

  def write_output_full
    puts "writing full"

    result = String.build do |node|
      node.json_array do |array|
        @cities.keys.each do |k|
          array << @cities[k].to_hash
        end
      end
    end

    f = File.new("data/stats.json", "w")
    f.puts result
    f.close

    puts "done"
  end
end

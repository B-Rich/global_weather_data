require "colorize"

class GlobalWeatherData::WeatherStatsConverter
  def initialize
    p = "data/metar_processed"
    Dir.mkdir_p(p) unless File.exists?(p)

    @i = 0
    @i_verbose_every = 10000
    @total_time_cost = 0.0

    @done_path = "data/metar_processed/done.txt"
    @done_array = Array(String).new

    get_done_list
  end

  def get_done_list
    if File.exists?(@done_path)
      File.new(@done_path).each_line do |line|
        @done_array << line.strip
      end
      puts "loaded #{@done_array.size} done files"
    end
  end

  def process_path(path)
    files_filtered = Array(String).new
    Dir.entries(path).each do |f|
      if f =~ /METAR(\d{4})-(\d{2})-(\d{2})/
        if @done_array.includes?(f)
          puts "skipping #{f}"
        else
          files_filtered << f
        end
      end
    end

    files_filtered.sort.each_with_index do |f,i|
      if f =~ /METAR(\d{4})-(\d{2})-(\d{2})/
        puts "processing file #{f}, #{i.to_s.colorize(:green)}/#{files_filtered.size.to_s.colorize(:yellow)}"

        t = Time.now

        fo_array = Array(String).new
        time = Time.new($1.to_i, $2.to_i, $3.to_i)
        options = {
          ":year" => time.year.to_s,
          ":month" => time.month.to_s
        }
        file = File.new( File.join([path, f]) )
        file.each_line do |line|
          begin
            metar = CrystalMetarParser::Parser.parse(line.gsub(/,/, " "), options)
            if metar.city.code != "" && metar.temperature.degrees.to_i != -255 && metar.wind.mps.to_i != -1
              s = ""
              s += "#{metar.city.code}; "
              s += "#{metar.time.time_from.epoch}; "
              s += "#{metar.temperature.degrees}; "
              s += "#{metar.wind.mps}; "
              s += "#{metar.pressure.pressure}"

              fo_array << s
              increment_counter
            end
          rescue ArgumentError
            #puts metar.time.time_from
          end
        end
        file.close

        # store
        fo = File.new("data/metar_processed/metar_#{$1}_#{$2}_#{$3}.csv", "w")
        fo.puts(fo_array.uniq.sort.join("\n"))
        fo.close

        # store that this file was processed
        f_done = File.new("data/metar_processed/done.txt", "a")
        f_done.puts(f)
        f_done.close

        cost = Time.now - t

        @total_time_cost += cost.to_f

        puts "file done, #{(i+1).to_s.colorize(:green)}/#{files_filtered.size.to_s.colorize(:yellow)}, cost #{cost.to_i.to_s.colorize(:red)} seconds"

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
  end

  def increment_counter
    if @i % @i_verbose_every == 0
      puts "processed #{@i}"
    end
    @i += 1
  end
end

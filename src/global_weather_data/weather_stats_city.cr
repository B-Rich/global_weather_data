class GlobalWeatherData::WeatherStatsCity
  def initialize
    @code = ""

    # counter
    @temperatures = Hash(Int32, Int32).new
    # daily in year
    @temperatures_daily_max = Hash(Int32, Int32).new
    @temperatures_daily_min = Hash(Int32, Int32).new
    # daily in year
    @temperatures_monthly_max = Hash(Int32, Int32).new
    @temperatures_monthly_min = Hash(Int32, Int32).new

    # counter
    @winds = Hash(Int32, Int32).new
    # daily in year
    @winds_daily_max = Hash(Int32, Int32).new
    @winds_daily_min = Hash(Int32, Int32).new
    # daily in year
    @winds_monthly_max = Hash(Int32, Int32).new
    @winds_monthly_min = Hash(Int32, Int32).new
  end

  property :code

  getter :temperatures_monthly_max, :temperatures_monthly_min,
    :temperatures,
    :temperatures_daily_max, :temperatures_daily_min

  getter :winds_monthly_max, :winds_monthly_min,
    :winds,
    :winds_daily_max, :winds_daily_min

  def max_temp
    return -255 if temperatures_monthly_max.size == 0
    temperatures_monthly_max.values.max.to_i
  end

  def min_temp
    return -255 if temperatures_monthly_min.size == 0
    temperatures_monthly_min.values.min.to_i
  end

  def max_wind
    return -1 if winds_monthly_max.size == 0
    winds_monthly_max.values.max.to_i
  end

  def min_wind
    return -1 if winds_monthly_min.size == 0
    winds_monthly_min.values.min.to_i
  end

  def to_hash
    return {
      "code" => @code,

      "temperatures" => @temperatures,
      "temperatures_daily_max" => @temperatures_daily_max,
      "temperatures_daily_min" => @temperatures_daily_min,
      "temperatures_monthly_max" => @temperatures_monthly_max,
      "temperatures_monthly_min" => @temperatures_monthly_min,

      "winds" => @winds,
      "winds_daily_max" => @winds_daily_max,
      "winds_daily_min" => @winds_daily_min,
      "winds_monthly_max" => @winds_monthly_max,
      "winds_monthly_min" => @winds_monthly_min,
    }
  end

  def add_metar(metar)
    add_temperature(metar.temperature.degrees, metar)
    add_wind(metar.wind.mps, metar)
  end

  def add_temperature(d, metar)
    add_temperature_time(d, metar.time.time_from)
  end


  def add_temperature_time(d, time)
    di = d.to_i
    if di > -100
      # increment counter
      if @temperatures.has_key?(di)
        @temperatures[di] += 1
      else
        @temperatures[di] = 1
      end

      # dailies
      day = time.day_of_year
      if @temperatures_daily_max.has_key?(day)
        @temperatures_daily_max[day] = di if @temperatures_daily_max[day] < di
      else
        @temperatures_daily_max[day] = di
      end

      if @temperatures_daily_min.has_key?(day)
        @temperatures_daily_min[day] = di if @temperatures_daily_min[day] > di
      else
        @temperatures_daily_min[day] = di
      end

      # monthly
      month = time.month
      if @temperatures_monthly_max.has_key?(month)
        @temperatures_monthly_max[month] = di if @temperatures_monthly_max[month] < di
      else
        @temperatures_monthly_max[month] = di
      end

      if @temperatures_monthly_min.has_key?(month)
        @temperatures_monthly_min[month] = di if @temperatures_monthly_min[month] > di
      else
        @temperatures_monthly_min[month] = di
      end
    end
  end

  def add_wind(d, metar)
    add_wind_time(d, metar.time.time_from)
  end

  def add_wind_time(d, time)
    di = d.to_i
    if di >= 0
      # increment counter
      if @winds.has_key?(di)
        @winds[di] += 1
      else
        @winds[di] = 1
      end

      # dailies
      day = time.day_of_year
      if @winds_daily_max.has_key?(day)
        @winds_daily_max[day] = di if @winds_daily_max[day] < di
      else
        @winds_daily_max[day] = di
      end

      if @winds_daily_min.has_key?(day)
        @winds_daily_min[day] = di if @winds_daily_min[day] > di
      else
        @winds_daily_min[day] = di
      end

      # monthly
      month = time.month
      if @winds_monthly_max.has_key?(month)
        @winds_monthly_max[month] = di if @winds_monthly_max[month] < di
      else
        @winds_monthly_max[month] = di
      end

      if @winds_monthly_min.has_key?(month)
        @winds_monthly_min[month] = di if @winds_monthly_min[month] > di
      else
        @winds_monthly_min[month] = di
      end
    end
  end
end

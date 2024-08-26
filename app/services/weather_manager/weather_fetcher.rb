module WeatherManager
  class WeatherFetcher < ApplicationService
    attr_reader :zip_code

    def initialize(zip_code)
      @zip_code = zip_code
    end

    def call
      weather_data = Rails.cache.read(@zip_code)
      return weather_data.merge(cached: true) if weather_data

      weather_data = WeatherApi.fetch_and_parse(@zip_code)
      if weather_data
        Rails.cache.write(@zip_code, weather_data, expires_in: 30.minutes)
        weather_data
      else
        Rails.logger.error("Weather data fetch failed for zip code: #{@zip_code}")
        false
      end
    end
  end
end
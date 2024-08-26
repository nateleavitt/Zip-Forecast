module WeatherManager
  # WeatherFetcher is a service class responsible for fetching weather data.
  # It first attempts to retrieve cached weather data. If not available,
  # it fetches new data using the WeatherApi class and caches it for future requests.
  #
  # This class is designed to handle weather data fetching and caching in a single call.
  class WeatherFetcher < ApplicationService
    attr_reader :zip_code

    # Initializes a new WeatherFetcher instance.
    #
    # @param zip_code [String] The zip code for which to fetch the weather data.
    def initialize(zip_code)
      @zip_code = zip_code
    end

    # Fetches weather data, either from the cache or by calling the WeatherApi.
    #
    # If the data is found in the cache, it returns the cached data with an
    # additional key indicating that the data was fetched from the cache.
    #
    # If the data is not in the cache, it fetches new weather data from the
    # WeatherApi, writes it to the cache, and returns the fetched data.
    #
    # If fetching the data fails, it logs an error and returns false.
    #
    # @return [Hash, false] A hash containing the weather data with an added
    #   `:cached` key indicating if the data was fetched from the cache, or false
    #   if the request failed.
    #
    # @example
    #   fetcher = WeatherManager::WeatherFetcher.new("90210")
    #   result = fetcher.call
    #   # => {
    #         current: {
    #           icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
    #           temperature: 75.0,
    #           condition: "Clear",
    #           location: "Beverly Hills",
    #           last_updated: "2024-08-26 12:00"
    #         },
    #         days: [
    #           {
    #             date: "2024-08-26",
    #             icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
    #             max_temp: 80.0,
    #             min_temp: 60.0
    #           },
    #           ...
    #         ],
    #         cached: true
    #       }
    def call
      # Attempt to retrieve weather data from cache
      weather_data = Rails.cache.read(@zip_code)
      return weather_data.merge(cached: true) if weather_data

      # Fetch weather data if not found in cache
      weather_data = WeatherApi.fetch_and_parse(@zip_code)
      if weather_data
        # Cache the fetched data
        Rails.cache.write(@zip_code, weather_data, expires_in: 30.minutes)
        weather_data
      else
        # Log an error if fetching data fails
        Rails.logger.error("Weather data fetch failed for zip code: #{@zip_code}")
        false
      end
    end
  end
end

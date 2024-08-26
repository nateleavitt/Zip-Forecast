# The WeatherManager module is responsible for managing weather-related
# functionalities such as fetching and parsing weather data.
module WeatherManager
  # The WeatherFetcher class is a service object that fetches weather data
  # from a third-party API (WeatherAPI). It caches the response based on
  # the provided zip code for 30 minutes to reduce redundant API requests.
  #
  # Example usage:
  #   weather = WeatherManager::WeatherFetcher.call("90210")
  #   if weather
  #     # Do something with the weather data
  #   else
  #     # Handle failure to fetch weather data
  #   end
  #
  # Dependencies:
  #   - Requires the `HTTParty` gem for making HTTP requests.
  #   - The API key for WeatherAPI must be set in ENV["WEATHER_API_KEY"].
  #
  # Params:
  # +zip_code+:: A String representing the zip or postal code for which the
  # weather data is fetched.
  class WeatherFetcher < ApplicationService
    attr_reader :zip_code

    # Initializes a new instance of WeatherFetcher with the provided zip code.
    #
    # Params:
    # +zip_code+:: A String representing the zip code to fetch weather data for.
    def initialize(zip_code)
      @zip_code = zip_code
    end

    # Calls the WeatherFetcher service to retrieve weather data.
    #
    # The weather data is cached for 30 minutes based on the zip code. If the
    # data is not found in the cache, a request is made to the WeatherAPI.
    # If the request is successful, the response is passed to the WeatherParser
    # to extract relevant weather information.
    #
    # Returns:
    #   - Hash:: A hash containing parsed weather data if successful.
    #   - False:: Returns false if the request fails.
    #
    # Example:
    #   weather = WeatherManager::WeatherFetcher.call("90210")
    #   # => { current_weather: {...}, forecast: [...] }
    def call
      Rails.cache.fetch(@zip_code, expires_in: 30.minutes) do
        # Make a request to the WeatherAPI to fetch weather data
        response = HTTParty.get(
          "https://api.weatherapi.com/v1/forecast.json",
          query: {
            key: ENV["WEATHER_API_KEY"],  # API key from environment variables
            q: @zip_code,                 # Query the weather based on the zip code
            days: 4,                      # Request 4 days of weather data
            aqi: "no",                    # Exclude air quality data
            alerts: "no"                  # Exclude weather alerts
          }
        )

        if response.success?
          # Parse the response using the WeatherParser
          WeatherManager::WeatherParser.call(response)
        else
          # Log the error if the request fails
          Rails.logger.error("Weather API request failed: #{response}")
          return nil # TODO: could return a custom error object/message
        end
      end
    end
  end
end

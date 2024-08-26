module WeatherManager
  # WeatherParser is responsible for extracting and organizing relevant weather
  # data from the response received from the weather API. It parses both current
  # conditions and a multi-day forecast, returning structured data for use
  # in the application.
  #
  # Usage Example:
  #   response = HTTParty.get("https://api.weatherapi.com/v1/forecast.json",
  #     query: { key: ENV["API_KEY"], q: zip_code, days: 4 })
  #   parsed_data = WeatherManager::WeatherParser.call(response)
  #
  #   parsed_data[:current] => { location: "City, State", temperature: 75.0,
  #     condition: "Sunny", icon: "icon_url", last_updated: "2023-08-25 12:00" }
  #   parsed_data[:days] => [{ date: "2023-08-25", max_temp: 80.0, min_temp: 60.0,
  #     condition: "Cloudy", icon: "icon_url" }, ...]
  class WeatherParser < ApplicationService
    # Number of forecast days to extract, including the current day
    FORECAST_DAYS = 4

    attr_reader :response

    # Initializes the parser with the API response data.
    #
    # @param response [Hash] The parsed JSON response from the weather API.
    def initialize(response)
      @response = response
    end

    # Main method to be called by clients. This method returns the parsed
    # weather data in a structured format.
    #
    # @return [Hash] A hash containing the current weather data and an array of
    #         forecast data for the next few days.
    def call
      {
        current: parse_current,
        days: parse_forecast
      }
    end

    private

    # Parses the current weather data from the API response.
    #
    # @return [Hash] A hash containing information about the current weather, such as
    #         location, temperature, condition, and last update time.
    def parse_current
      {
        location: "#{@response.dig('location', 'name')}, #{@response.dig('location', 'region')}",
        temperature: @response.dig("current", "temp_f"),
        condition: @response.dig("current", "condition", "text"),
        icon: @response.dig("current", "condition", "icon"),
        last_updated: @response.dig("current", "last_updated")
      }
    end

    # Parses the forecast data for the next few days.
    #
    # @return [Array<Hash>] An array of hashes, each containing the forecast information
    #         for a particular day (e.g., max temperature, min temperature, condition, date).
    #         If no forecast data is available, returns an empty array.
    def parse_forecast
      return [] unless @response.dig("forecast", "forecastday") # Return an empty array if no forecast

      forecast = @response.dig("forecast", "forecastday")&.map do |day|
        {
          max_temp: day.dig("day", "maxtemp_f"),
          min_temp: day.dig("day", "mintemp_f"),
          condition: day.dig("day", "condition", "text"),
          icon: day.dig("day", "condition", "icon"),
          date: day["date"]
        }
      end
      forecast[0..FORECAST_DAYS-1] if forecast # Safeguard if forecast is nil
    end
  end
end

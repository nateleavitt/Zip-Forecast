module WeatherManager
  class WeatherParser < ApplicationService
    FORECAST_DAYS = 4

    attr_reader :response

    def initialize(response)
      @response = response
    end

    # Main method to call and return parsed weather data
    def call
      {
        current: parse_current,
        days: parse_forecast
      }
    end

    private

    # Parses the current weather data from the API response
    def parse_current
      {
        location: "#{@response.dig('location', 'name')}, #{@response.dig('location', 'region')}",
        temperature: @response.dig("current", "temp_f"),
        condition: @response.dig("current", "condition", "text"),
        icon: @response.dig("current", "condition", "icon"),
        last_updated: @response.dig("current", "last_updated")
      }
    end

    # Parses the forecast data for up to 3 days from the API response
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

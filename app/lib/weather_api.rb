# WeatherApi is a class responsible for fetching and parsing weather data
# from the WeatherAPI service.
#
# It provides methods to request weather forecasts and parse the response
# into a more manageable format.
class WeatherApi
  # Fetches weather data from the WeatherAPI service and parses the response.
  #
  # @param zip_code [String] The zip code for which to retrieve the weather forecast.
  # @return [Hash, false] A hash containing the current weather and forecast data, or false if the request fails.
  # @example
  #   WeatherApi.fetch_and_parse("90210")
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
  #         ]
  #       }
  def self.fetch_and_parse(zip_code)
    response = HTTParty.get(
      "https://api.weatherapi.com/v1/forecast.json",
      query: {
        key: ENV["WEATHER_API_KEY"],  # API key from environment variables
        q: zip_code,                 # Query the weather based on the zip code
        days: 4,                      # Request 4 days of weather data
        aqi: "no",                    # Exclude air quality data
        alerts: "no"                  # Exclude weather alerts
      }
    )

    if response.success?
      parse_weather_data(response)
    else
      Rails.logger.error("Weather API request failed: #{response}")
      false
    end
  end

  # Parses the weather data response into a structured hash.
  #
  # @param response [HTTParty::Response] The response object from the WeatherAPI request.
  # @return [Hash] A hash containing the parsed weather data with the following structure:
  #   - :current [Hash] Current weather information with keys:
  #     - :icon [String] URL to the weather icon
  #     - :temperature [Float] Current temperature in Fahrenheit
  #     - :condition [String] Weather condition description
  #     - :location [String] Location name
  #     - :last_updated [String] Last update timestamp
  #   - :days [Array<Hash>] Array of hashes with forecast information for the next 4 days, each hash containing:
  #     - :date [String] Forecast date
  #     - :icon [String] URL to the weather icon
  #     - :max_temp [Float] Maximum temperature in Fahrenheit for the day
  #     - :min_temp [Float] Minimum temperature in Fahrenheit for the day
  # @example
  #   response = HTTParty.get("https://api.weatherapi.com/v1/forecast.json", query: { ... })
  #   WeatherApi.parse_weather_data(response)
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
  #         ]
  #       }
  def self.parse_weather_data(response)
    # Assuming the response is in JSON format
    data = response.parsed_response

    {
      current: {
        icon: data.dig("current", "condition", "icon"),
        temperature: data.dig("current", "temp_f"),
        condition: data.dig("current", "condition", "text"),
        location: data.dig("location", "name"),
        last_updated: data.dig("current", "last_updated")
      },
      days: data.dig("forecast", "forecastday").first(4).map do |day|
        {
          date: day["date"],
          icon: day.dig("day", "condition", "icon"),
          max_temp: day.dig("day", "maxtemp_f"),
          min_temp: day.dig("day", "mintemp_f")
        }
      end
    }
  end
end

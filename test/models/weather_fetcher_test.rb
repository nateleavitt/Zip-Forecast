class WeatherApi
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
      parse_weather_data(response.body) # Pass raw body instead of parsed_response
    else
      Rails.logger.error("Weather API request failed: #{response}")
      false
    end
  end

  def self.parse_weather_data(response_body)
    data = JSON.parse(response_body) # Parse the JSON string into a Ruby hash

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

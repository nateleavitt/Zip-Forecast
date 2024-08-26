module WeatherManager
  class WeatherFetcher < ApplicationService
    attr_reader :zip_code

    def initialize(zip_code)
      @zip_code = zip_code
    end

    def call
      Rails.cache.fetch(@zip_code, expires_in: 30.minutes) do
        response = HTTParty.get("https://api.weatherapi.com/v1/forecast.json",
          query: { key: ENV["WEATHER_API_KEY"],
          q: @zip_code,
          days: 4,
          aqi: "no",
          alerts: "no"
        })

        if response.success?
          WeatherManager::WeatherParser.call(response)
        else
          return false
        end
      end
    end
  end
end

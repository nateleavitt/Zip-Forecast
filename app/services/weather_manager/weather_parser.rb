module WeatherManager
  class WeatherParser < ApplicationService
    attr_reader :response

    def initialize(response)
      @response = response
    end

    def call
      {
        current: parse_current,
        days: parse_forecast
      }
    end

    def parse_current
      {
        location: @response["location"]["name"] + ", " + @response["location"]["region"],
        temperature: @response["current"]["temp_f"],
        condition: @response["current"]["condition"]["text"],
        icon: @response["current"]["condition"]["icon"],
        last_updated: @response["current"]["last_updated"]
      }
    end

    def parse_forecast
      forecast = @response["forecast"]["forecastday"].map do |day|
        {
          max_temp: day["day"]["maxtemp_f"],
          min_temp: day["day"]["mintemp_f"],
          condition: day["day"]["condition"]["text"],
          icon: day["day"]["condition"]["icon"],
          date: day["date"]
        }
      end
      forecast[0..4] # Return today and next 3 days
    end
  end
end

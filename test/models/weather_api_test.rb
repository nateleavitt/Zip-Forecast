require "test_helper"
require "webmock/minitest"
require "httparty"

class WeatherApiTest < ActiveSupport::TestCase
  def setup
    @zip_code = "12345"
    @api_key = ENV["WEATHER_API_KEY"]
    @url = "https://api.weatherapi.com/v1/forecast.json"
  end

  test "fetch_and_parse returns parsed weather data on success" do
    stub_request(:get, @url)
      .with(query: {
        key: @api_key,
        q: @zip_code,
        days: 4,
        aqi: "no",
        alerts: "no"
      })
      .to_return(
        status: 200,
        body: {
          "current" => {
            "condition" => { "icon" => "icon_url", "text" => "Clear" },
            "temp_f" => 75,
            "last_updated" => "2024-08-26 12:00"
          },
          "location" => { "name" => "City" },
          "forecast" => {
            "forecastday" => [
              { "date" => "2024-08-26", "day" => { "condition" => { "icon" => "day_icon_url" }, "maxtemp_f" => 80, "mintemp_f" => 60 } },
              { "date" => "2024-08-27", "day" => { "condition" => { "icon" => "day_icon_url" }, "maxtemp_f" => 82, "mintemp_f" => 62 } }
            ]
          }
        }.to_json
      )

    result = WeatherApi.fetch_and_parse(@zip_code)
    expected = {
      current: {
        icon: "icon_url",
        temperature: 75,
        condition: "Clear",
        location: "City",
        last_updated: "2024-08-26 12:00"
      },
      days: [
        { date: "2024-08-26", icon: "day_icon_url", max_temp: 80, min_temp: 60 },
        { date: "2024-08-27", icon: "day_icon_url", max_temp: 82, min_temp: 62 }
      ]
    }

    assert_equal expected, result
  end

  test "fetch_and_parse handles API failure" do
    stub_request(:get, @url)
      .with(query: {
        key: @api_key,
        q: @zip_code,
        days: 4,
        aqi: "no",
        alerts: "no"
      })
      .to_return(status: 500, body: "Internal Server Error")

    result = WeatherApi.fetch_and_parse(@zip_code)
    assert_not result
  end
end
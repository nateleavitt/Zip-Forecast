require "test_helper"
require "mocha/minitest"  # Ensure this is required

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_forecast_params = {
      forecast: {
        street: "123 Main St",
        city: "Mesa",
        state: "AZ",
        zip_code: "85201"
      }
    }

    @invalid_forecast_params = {
      forecast: {
        street: "123 Main St",
        city: "Mesa",
        state: "AZ",
        zip_code: ""  # Invalid because zip code is empty
      }
    }
  end

  test "should create forecast and fetch weather data" do
    WeatherManager::WeatherFetcher.stubs(:call).returns({
      current: {
        icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
        temperature: 100.0,
        condition: "Sunny",
        location: "Mesa",
        last_updated: "2024-08-26 14:00"
      },
      days: [
        { date: "2024-08-26", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", max_temp: 100, min_temp: 80 }
      ]
    })
    post forecasts_path, params: @valid_forecast_params, headers: { Accept: "text/vnd.turbo-stream.html" }
    assert_response :success

    # Check if the specific part of the Turbo Stream contains expected content
    assert_match /100\.0/, response.body  # Check for a part of the forecast data
    assert_match /Sunny/, response.body
    assert_match /Mesa/, response.body
  end

  test "should not create forecast with invalid input" do
    post forecasts_path, params: @invalid_forecast_params, headers: { Accept: "text/vnd.turbo-stream.html" }
    assert_response :unprocessable_entity
  end

  test "should handle weather fetch failure" do
    WeatherManager::WeatherFetcher.stubs(:call).returns(false)
    post forecasts_path, params: @valid_forecast_params, headers: { Accept: "text/vnd.turbo-stream.html" }
    assert_response :unprocessable_entity
  end
end

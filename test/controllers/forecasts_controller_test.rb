require "test_helper"

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
        zip_code: ""  # Invalid because zip_code is empty
      }
    }
  end

  # Test: Forecast is successfully fetched
  test "should create forecast and fetch weather data" do
    # Mock the WeatherManager::WeatherFetcher call to return valid weather data
    weather_data = {
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
    }

    WeatherManager::WeatherFetcher.stub(:call, weather_data) do
      assert_difference('Forecast.count', 0) do  # No actual record is saved since you're using a form object
        post forecasts_path, params: @valid_forecast_params
      end

      assert_response :redirect
      assert_redirected_to forecast_path(assigns(:forecast))
      assert_equal "Forecast was successfully fetched.", flash[:notice]
    end
  end

  # Test: Forecast creation fails due to invalid input
  test "should not create forecast with invalid input" do
    post forecasts_path, params: @invalid_forecast_params
    assert_response :unprocessable_entity
    assert_template :new
    assert_not_empty assigns(:forecast).errors
  end

  # Test: Weather API fails to fetch weather data
  test "should handle weather fetch failure" do
    # Mock the WeatherManager::WeatherFetcher call to return false, simulating a failure
    WeatherManager::WeatherFetcher.stub(:call, false) do
      post forecasts_path, params: @valid_forecast_params

      assert_response :unprocessable_entity
      assert_template :new
      assert_includes assigns(:forecast).errors.full_messages, "Unable to retrieve weather information for the provided zip code."
    end
  end
end

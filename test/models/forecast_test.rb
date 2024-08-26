require "test_helper"

class ForecastTest < ActiveSupport::TestCase
  def setup
    @valid_forecast = Forecast.new(street: "123 Main St", city: "Anytown", state: "NY", zip_code: "12345")
    @invalid_forecast = Forecast.new(street: "", city: "", state: "", zip_code: "")
  end

  test "valid forecast with all fields" do
    assert @valid_forecast.valid?
  end

  test "invalid forecast without required fields" do
    assert_not @invalid_forecast.valid?
    assert @invalid_forecast.errors[:street].any?, "Street is required"
    assert @invalid_forecast.errors[:city].any?, "City is required"
    assert @invalid_forecast.errors[:state].any?, "State is required"
    assert @invalid_forecast.errors[:zip_code].any?, "Zip code is required"
  end

  test "invalid zip code format" do
    forecast = Forecast.new(street: "123 Main St", city: "Anytown", state: "NY", zip_code: "abcde")
    assert_not forecast.valid?
    assert forecast.errors[:zip_code].any?, "Zip code should be in the format 12345 or 12345-6789"
  end

  test "valid zip code format with dash" do
    forecast = Forecast.new(street: "123 Main St", city: "Anytown", state: "NY", zip_code: "12345-6789")
    assert forecast.valid?
  end
end

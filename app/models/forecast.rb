# The Forecast class is a non-persistent model that represents a
# weather forecast request. It utilizes ActiveModel::Model to
# include functionalities like validation which are typically
# found in ActiveRecord models. This model is used to capture
# user input for weather queries based on their address components
# and validate the input before processing.
#
# Attributes:
# - street (String): The street address component of the location.
# - city (String): The city component of the location.
# - state (String): The state component of the location.
# - zip_code (String): The postal code which is used to fetch the weather data.
# - weather_data (Hash): Stores the weather data fetched from an external API.
#
# Validations:
# - street, city, state, zip_code: All these fields are required to be present.
# - zip_code: It is validated against a specific format to ensure it adheres to the
#   typical 5-digit or 9-digit (Zip+4) U.S. postal code format.
#
class Forecast
  include ActiveModel::Model

  # Attributes for the forecast request. These are used for input forms and validation.
  attr_accessor :street, :city, :state, :zip_code, :weather_data

  # Ensures that all attributes are present and that zip code follows a specific format.
  validates :street, :city, :state, :zip_code, presence: true
  validates :zip_code, format: { with: /\A\d{5}(-\d{4})?\z/,
    message: "should be in the format 12345 or 12345-6789" }
end

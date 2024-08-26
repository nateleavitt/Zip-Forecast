class Forecast
  include ActiveModel::Model

  # Attributes
  attr_accessor :street, :city, :state, :zip_code

  # Validations
  validates :street, :city, :state, :zip_code, presence: true
  validates :zip_code, format: { with: /\A\d{5}(-\d{4})?\z/,
    message: "should be in the format 12345 or 12345-6789" }
end

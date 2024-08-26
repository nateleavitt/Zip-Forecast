class Forecast < ApplicationRecord
  include ActiveModel::Model

  # Attributes
  attr_accessor :street, :city, :state, :zip, presence: true

  # Validations
  validates :street, :city, :state, :zip, presence: true
  validates :zip, format: { with: /\A\d{5}(-\d{4})?\z/, message: "should be in the format 12345 or 12345-6789" }
end

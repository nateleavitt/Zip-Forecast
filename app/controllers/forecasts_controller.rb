# ForecastsController is responsible for handling user interactions related to weather forecasts.
# It processes user input, interacts with services to fetch weather data, and manages the response
# flow back to the user, either displaying weather information or handling input errors.
#
# Actions:
# - index: Displays the main page where users can enter address information to fetch forecasts.
# - create: Processes the input from the user, fetches weather data, and responds accordingly.
#
class ForecastsController < ApplicationController

  def index
  end

  # Processes the forecast request from the user input provided via form submission.
  # It validates the input, fetches the weather forecast, and handles the response
  # based on the success or failure of the data retrieval.
  #
  # Upon successful data fetch, it redirects to a page displaying the weather information.
  # On failure, it re-renders the form with appropriate error messages.
  def create
    @forecast = Forecast.new(forecast_params)

    # Validate forecast input details
    if @forecast.valid?
      weather_data = WeatherManager::WeatherFetcher.call(@forecast.zip_code)

      # Check if weather data was successfully retrieved
      if weather_data
        @forecast.weather_data = weather_data
      else
        @forecast.errors.add(:base, "Unable to retrieve weather information for the provided zip code.")
      end
    end

    # Responds with either HTML or Turbo Stream format based on the request type
    respond_to do |format|
      if @forecast.errors.empty? && @forecast.weather_data
        format.turbo_stream
        format.html { redirect_to forecast_path(@forecast),
                      notice: "Forecast was successfully fetched." }
      else
        # Render the new form with error messages if data fetch fails or validation fails
        format.turbo_stream { render turbo_stream:
                              turbo_stream.replace("#{helpers.dom_id(@forecast)}_form",
                              partial: "form", locals: { forecast: @forecast }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  # Strong parameters method to whitelist allowed parameters for creating a forecast.
  # This helps prevent wrong or malicious data from being processed by the controller.
  def forecast_params
    params.require(:forecast).permit(:street, :city, :state, :zip_code)
  end
end

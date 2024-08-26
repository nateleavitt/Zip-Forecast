class ForecastsController < ApplicationController
  def index
  end

  def create
    @forecast = Forecast.new(forecast_params)

    if @forecast.valid?
      weather_data = WeatherManager::WeatherFetcher.call(@forecast.zip_code)

      # Check if weather data was returned, otherwise add a custom error
      if weather_data
        @forecast.weather_data = weather_data
      else
        @forecast.errors.add(:base, "Unable to retrieve weather information for the provided zip code.")
      end
    end

    respond_to do |format|
      if @forecast.errors.empty? && @forecast.weather_data
        format.turbo_stream
        format.html { redirect_to forecast_path(@forecast), notice: "Forecast was successfully fetched." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("#{helpers.dom_id(@forecast)}_form", partial: "form", locals: { forecast: @forecast }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def forecast_params
    params.require(:forecast).permit(:street, :city, :state, :zip_code)
  end
end

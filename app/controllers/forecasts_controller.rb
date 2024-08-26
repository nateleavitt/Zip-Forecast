class ForecastsController < ApplicationController
  def index
  end

  def create
    @forecast = Forecast.new(forecast_params)

    # Checking validation of forecast to make sure we have
    # valid data.
    if @forecast.valid?
      @forecast.weather_data = WeatherManager::WeatherFetcher.call(@forecast.zip_code)
    end

    puts "***** weather data: #{@forecast.weather_data}"

    respond_to do |format|
      # Could save here if wanting to persist the forecast
      # However, for this example, we are not persisting the forecast so we
      # are ensuring the validation is correct and the weather data exists
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

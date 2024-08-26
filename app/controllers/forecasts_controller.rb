class ForecastsController < ApplicationController
  def index
    @forecasts = []
  end

  def create
    @forecast = Forecast.new(forecast_params)

    respond_to do |format|
      if @forecast.valid?
        format.turbo_stream
        format.html { redirect_to forecast_path(zip_code: @forecast.zip_code), notice: "Forecast was successfully fetched." }
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

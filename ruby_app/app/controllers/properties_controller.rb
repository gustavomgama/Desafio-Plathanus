class PropertiesController < ApplicationController
  before_action :set_property, only: [:show]

  def index
    @properties = Property.includes(:photos).order(:name)
  end

  def show; end

  private

  def set_property
    @property = Property.includes(:photos).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to properties_path, alert: "Property not found"
  end
end

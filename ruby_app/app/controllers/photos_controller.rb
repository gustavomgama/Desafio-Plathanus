class PhotosController < ApplicationController
  before_action :set_photo

  def show
    if File.exists?(@photo.file_path)
      send_file @photo.file_path,
                type: @photo.content_type,
                disposition: "inline",
                filename: @photo.filename
    else
      head :not_found
    end
  end

  private

  def set_photo
    @property = Property.find(params[:property_id])
    @photo = @property.photos.find_by!(filename: params[:filename])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end

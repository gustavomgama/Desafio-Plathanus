class PhotosController < ApplicationController
  before_action :set_property
  before_action :set_photo

  def show
    return head :not_found unless @photo

    if File.exist?(@photo.file_path)
      send_file @photo.file_path, type: @photo.content_type, disposition: "inline", filename: @photo.filename
    else
      head :not_found
    end
  end

  private

  def set_property
    @property = Property.find(params[:property_id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def set_photo
    return head :not_found unless @property
    return head :not_found if params[:filename].blank? && params[:id].blank?

    filename = params[:filename] || "#{params[:id]}.#{params[:format]}"

    begin
      @photo = @property.photos.find_by!(filename: filename)
    rescue ArgumentError => e
      if e.message.include?("null byte")
        head :not_found
      else
        raise
      end
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end
end

class Photo < ApplicationRecord
  belongs_to :property

  validates :filename, presence: true, length: { maximum: 255 }
  validates :position, presence: true,
                      uniqueness: { scope: :property_id },
                      numericality: { greater_than: 0 }
  validates :content_type, inclusion: {
    in: %w[image/jpeg image/jpg image/png image/webp],
    message: "must be a valid image format"
  }
  validates :file_size, numericality: {
    greater_than: 0,
    less_than: 10.megabytes,
    message: "must be between 1 byte and 10MB"
  }

  scope :covers, -> { where(position: 3) }
  scope :by_position, -> { order(:position) }

  before_validation :set_next_position, if: :new_record?

  def cover_photo?
    property.cover_photo == self
  end

  def file_path
    Rails.root.join("storage", "photos", property_id.to_s, filename)
  end

  def url
    "/photos/#{property_id}/#{filename}"
  end

  private

  def set_next_position
    return if position.present?

    last_position = property.photos.maximum(:position) || 0
    self.position = last_position + 1
  end
end

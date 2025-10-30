class Property < ApplicationRecord
  has_many :photos, -> { order(:position) }, dependent: :destroy, inverse_of: :property

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  def cover_photo
    @cover_photo ||= photos.loaded? ? cover_photo_from_loaded : cover_photo_from_database
  end

  def has_cover_photo?
    @has_cover_photo ||= photos.loaded? ? photos.size >= 3 : photos.count >= 3
  end

  def cover_photo_position
    has_cover_photo? ? 3 : 1
  end

  private

  def cover_photo_from_loaded
    return nil if photos.empty?
    photos.count >= 3 ? photos[2] : photos.first
  end

  def cover_photo_from_database
    return nil unless photos.exists?
    photos.where(position: cover_photo_position).first || photos.first
  end
end

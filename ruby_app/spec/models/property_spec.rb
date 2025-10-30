require 'rails_helper'

RSpec.describe Property, type: :model do
  describe 'validations' do
    it 'requires a name' do
      property = build(:property, name: nil)
      expect(property).not_to be_valid
      expect(property.errors[:name]).to include("can't be blank")
    end

    it 'requires name to be at least 2 characters' do
      property = build(:property, name: 'A')
      expect(property).not_to be_valid
      expect(property.errors[:name]).to include('is too short (minimum is 2 characters)')
    end

    it 'limits name to 100 characters' do
      long_name = 'A' * 101
      property = build(:property, name: long_name)
      expect(property).not_to be_valid
      expect(property.errors[:name]).to include('is too long (maximum is 100 characters)')
    end

    it 'accepts valid names' do
      property = build(:property, name: 'Beautiful Family Home')
      expect(property).to be_valid
    end
  end

  describe 'associations' do
    it 'has many photos' do
      property = create(:property)
      photo1 = create(:photo, property: property, position: 1)
      photo2 = create(:photo, property: property, position: 2)

      expect(property.photos).to contain_exactly(photo1, photo2)
    end

    it 'orders photos by position' do
      property = create(:property)
      photo3 = create(:photo, property: property, position: 3)
      photo1 = create(:photo, property: property, position: 1)
      photo2 = create(:photo, property: property, position: 2)

      expect(property.photos.to_a).to eq([photo1, photo2, photo3])
    end

    it 'destroys photos when property is destroyed' do
      property = create(:property, :with_cover_photo)
      photo_ids = property.photos.pluck(:id)

      property.destroy

      expect(Photo.where(id: photo_ids)).to be_empty
    end
  end

  describe '#cover_photo' do
    context 'when property has no photos' do
      it 'returns nil' do
        property = create(:property)
        expect(property.cover_photo).to be_nil
      end
    end

    context 'when property has fewer than 3 photos' do
      it 'returns the first photo' do
        property = create(:property, :with_few_photos)
        first_photo = property.photos.first

        expect(property.cover_photo).to eq(first_photo)
      end
    end

    context 'when property has 3 or more photos' do
      it 'returns the third photo' do
        property = create(:property, :with_cover_photo)
        third_photo = property.photos.find_by(position: 3)

        expect(property.cover_photo).to eq(third_photo)
      end
    end

    context 'when photos are already loaded' do
      it 'returns the correct cover photo' do
        property = create(:property, :with_cover_photo)
        property.photos.load # Preload the association
        third_photo = property.photos.find { |p| p.position == 3 }

        expect(property.cover_photo).to eq(third_photo)
      end
    end

    context 'when photos are not loaded' do
      it 'queries the database to find cover photo' do
        property = create(:property, :with_cover_photo)

        expect { property.cover_photo }.to make_database_queries
      end
    end
  end

  describe '#has_cover_photo?' do
    it 'returns true when property has 3 or more photos' do
      property = create(:property, :with_cover_photo)
      expect(property).to have_cover_photo
    end

    it 'returns false when property has fewer than 3 photos' do
      property = create(:property, :with_few_photos)
      expect(property).not_to have_cover_photo
    end

    it 'returns false when property has no photos' do
      property = create(:property)
      expect(property).not_to have_cover_photo
    end
  end

  describe '#cover_photo_position' do
    it 'returns 3 when property has cover photo' do
      property = create(:property, :with_cover_photo)
      expect(property.cover_photo_position).to eq(3)
    end

    it 'returns 1 when property does not have cover photo' do
      property = create(:property, :with_few_photos)
      expect(property.cover_photo_position).to eq(1)
    end
  end
end

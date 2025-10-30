require 'rails_helper'

RSpec.describe Photo, type: :model do
  describe 'validations' do
    let(:property) { create(:property) }

    describe 'filename' do
      it 'requires a filename' do
        photo = build(:photo, filename: nil)
        expect(photo).not_to be_valid
        expect(photo.errors[:filename]).to include("can't be blank")
      end

      it 'limits filename to 255 characters' do
        long_filename = 'a' * 252 + '.jpg'
        photo = build(:photo, filename: long_filename)
        expect(photo).not_to be_valid
        expect(photo.errors[:filename]).to include('is too long (maximum is 255 characters)')
      end
    end

    describe 'position' do
      it 'requires a position' do
        photo = build(:photo, position: nil)
        # Skip the callback that auto-assigns position
        photo.define_singleton_method(:set_next_position) { }
        expect(photo).not_to be_valid
        expect(photo.errors[:position]).to include("can't be blank")
      end

      it 'requires position to be greater than 0' do
        photo = build(:photo, position: 0)
        expect(photo).not_to be_valid
        expect(photo.errors[:position]).to include('must be greater than 0')
      end

      it 'requires position to be unique within property' do
        create(:photo, property: property, position: 1)
        duplicate_photo = build(:photo, property: property, position: 1)

        expect(duplicate_photo).not_to be_valid
        expect(duplicate_photo.errors[:position]).to include('has already been taken')
      end

      it 'allows same position across different properties' do
        other_property = create(:property)
        create(:photo, property: property, position: 1)
        other_photo = build(:photo, property: other_property, position: 1)

        expect(other_photo).to be_valid
      end
    end

    describe 'content_type' do
      it 'accepts valid image formats' do
        %w[image/jpeg image/jpg image/png image/webp].each do |content_type|
          photo = build(:photo, content_type: content_type)
          expect(photo).to be_valid
        end
      end

      it 'rejects invalid formats' do
        photo = build(:photo, content_type: 'application/pdf')
        expect(photo).not_to be_valid
        expect(photo.errors[:content_type]).to include('must be a valid image format')
      end
    end

    describe 'file_size' do
      it 'requires file_size to be greater than 0' do
        photo = build(:photo, file_size: 0)
        expect(photo).not_to be_valid
        expect(photo.errors[:file_size]).to include('must be between 1 byte and 10MB')
      end

      it 'rejects files larger than 10MB' do
        photo = build(:photo, file_size: 11.megabytes)
        expect(photo).not_to be_valid
        expect(photo.errors[:file_size]).to include('must be between 1 byte and 10MB')
      end

      it 'accepts valid file sizes' do
        photo = build(:photo, file_size: 5.megabytes)
        expect(photo).to be_valid
      end
    end
  end

  describe 'associations' do
    it 'belongs to property' do
      property = create(:property)
      photo = create(:photo, property: property)

      expect(photo.property).to eq(property)
    end
  end

  describe 'scopes' do
    let(:property) { create(:property) }

    describe '.covers' do
      it 'returns photos at position 3' do
        cover_photo = create(:photo, property: property, position: 3)
        create(:photo, property: property, position: 1)

        expect(Photo.covers).to contain_exactly(cover_photo)
      end
    end

    describe '.by_position' do
      it 'orders photos by position' do
        photo3 = create(:photo, property: property, position: 3)
        photo1 = create(:photo, property: property, position: 1)
        photo2 = create(:photo, property: property, position: 2)

        expect(Photo.by_position.to_a).to eq([ photo1, photo2, photo3 ])
      end
    end
  end

  describe 'callbacks' do
    describe 'set_next_position' do
      let(:property) { create(:property) }

      it 'sets position to 1 for first photo' do
        photo = create(:photo, property: property, position: nil)
        expect(photo.position).to eq(1)
      end

      it 'sets position to next available for subsequent photos' do
        create(:photo, property: property, position: 1)
        create(:photo, property: property, position: 2)

        new_photo = create(:photo, property: property, position: nil)
        expect(new_photo.position).to eq(3)
      end

      it 'does not override explicitly set position' do
        photo = create(:photo, property: property, position: 5)
        expect(photo.position).to eq(5)
      end
    end
  end

  describe 'instance methods' do
    let(:property) { create(:property, :with_cover_photo) }

    describe '#cover_photo?' do
      it 'returns true for the cover photo' do
        cover_photo = property.photos.find_by(position: 3)
        expect(cover_photo).to be_cover_photo
      end

      it 'returns false for non-cover photos' do
        other_photo = property.photos.find_by(position: 1)
        expect(other_photo).not_to be_cover_photo
      end
    end

    describe '#file_path' do
      it 'returns the expected file path' do
        photo = property.photos.first
        expected_path = Rails.root.join('storage', 'photos', property.id.to_s, photo.filename)

        expect(photo.file_path).to eq(expected_path)
      end
    end

    describe '#url' do
      it 'returns the expected URL' do
        photo = property.photos.first
        expected_url = "/photos/#{property.id}/#{photo.filename}"

        expect(photo.url).to eq(expected_url)
      end
    end
  end
end

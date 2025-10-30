require "rails_helper"

RSpec.describe PhotosController, type: :controller do
  let(:property) { create(:property, :with_cover_photo) }
  let(:photo) { property.photos.first }

  describe "GET #show" do
    context "with valid property and photo" do
      before do
        FileUtils.mkdir_p(File.dirname(photo.file_path))
        File.write(photo.file_path, "fake image content")
      end

      after do
        File.delete(photo.file_path) if File.exist?(photo.file_path)
      end

      it "returns successful response" do
        get :show, params: { property_id: property.id, filename: photo.filename }
        expect(response).to have_http_status(:success)
      end

      it "serves file with correct content type" do
        get :show, params: { property_id: property.id, filename: photo.filename }
        expect(response.content_type).to eq(photo.content_type)
      end

      it "serves file with inline disposition" do
        expect(controller).to receive(:send_file).with(
          photo.file_path,
          type: photo.content_type,
          disposition: "inline",
          filename: photo.filename
        )

        get :show, params: { property_id: property.id, filename: photo.filename }
      end

      it "assigns the correct property" do
        get :show, params: { property_id: property.id, filename: photo.filename }
        expect(assigns(:property)).to eq(property)
      end

      it "assigns the correct photo" do
        get :show, params: { property_id: property.id, filename: photo.filename }
        expect(assigns(:photo)).to eq(photo)
      end

      it "finds photo by filename within property scope" do
        other_property = create(:property, :with_cover_photo)
        same_filename_photo = other_property.photos.first
        same_filename_photo.update!(filename: photo.filename)

        get :show, params: { property_id: property.id, filename: photo.filename }
        expect(assigns(:photo)).to eq(photo)
        expect(assigns(:photo)).not_to eq(same_filename_photo)
      end
    end

    context "with missing file" do
      it "returns not found when file doesn't exist" do
        get :show, params: { property_id: property.id, filename: photo.filename }
        expect(response).to have_http_status(:not_found)
      end

      it "doesn't crash when file path is invalid" do
        # Create a property with a photo but don't give it a valid file
        property_without_photo = create(:property)
        photo_without_file = create(:photo, property: property_without_photo, filename: "missing.jpg")

        allow(File).to receive(:exist?).with(photo_without_file.file_path).and_return(false)

        get :show, params: { property_id: property_without_photo.id, filename: photo_without_file.filename }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with invalid property id" do
      it "returns not found for non-existent property" do
        get :show, params: { property_id: 99999, filename: photo.filename }
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for malformed property id" do
        get :show, params: { property_id: 'invalid', filename: photo.filename }
        expect(response).to have_http_status(:not_found)
      end

      it "handles deleted property gracefully" do
        property_id = property.id
        photo_filename = property.photos.first.filename
        property.destroy

        get :show, params: { property_id: property_id, filename: photo_filename }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with invalid filename" do
      it "returns not found for non-existent filename" do
        get :show, params: { property_id: property.id, filename: 'non-existent.jpg' }
        expect(response).to have_http_status(:not_found)
      end

      it "handles empty filename" do
        expect {
          get :show, params: { property_id: property.id, filename: '' }
        }.to raise_error(ActionController::UrlGenerationError)
      end

      it "handles filename from different property" do
        other_property = create(:property, :with_cover_photo)
        other_photo = other_property.photos.first

        get :show, params: { property_id: property.id, filename: other_photo.filename }
        expect(response).to have_http_status(:not_found)
      end
    end

    context "security considerations" do
      it "handles null byte injection gracefully" do
        malicious_filename = "photo.jpg\x00.txt"

        get :show, params: { property_id: property.id, filename: malicious_filename }
        expect(response).to have_http_status(:not_found)
      end

      it "route constraints prevent malicious filenames" do
        # These should be blocked by route constraints, not reach the controller
        malicious_filenames = [
          "../../../etc/passwd",
          "../../../../config/database.yml"
        ]

        malicious_filenames.each do |filename|
          expect {
            get :show, params: { property_id: property.id, filename: filename }
          }.to raise_error(ActionController::UrlGenerationError)
        end
      end
    end

    context "different photo content types" do
      let!(:jpeg_photo) { create(:photo, property: property, content_type: "image/jpeg", filename: 'test.jpg') }
      let!(:png_photo) { create(:photo, property: property, content_type: "image/png", filename: 'test.png') }
      let!(:webp_photo) { create(:photo, property: property, content_type: "image/webp", filename: 'test.webp') }

      before do
        [ jpeg_photo, png_photo, webp_photo ].each do |photo|
          FileUtils.mkdir_p(File.dirname(photo.file_path))
          File.write(photo.file_path, "fake #{photo.content_type} content")
        end
      end

      after do
        [ jpeg_photo, png_photo, webp_photo ].each do |photo|
          File.delete(photo.file_path) if File.exist?(photo.file_path)
        end
      end

      it "serves JPEG files with correct content type" do
        get :show, params: { property_id: property.id, filename: jpeg_photo.filename }
        expect(response.content_type).to eq('image/jpeg')
      end

      it "serves PNG files with correct content type" do
        get :show, params: { property_id: property.id, filename: png_photo.filename }
        expect(response.content_type).to eq("image/png")
      end

      it "serves WebP files with correct content type" do
        get :show, params: { property_id: property.id, filename: webp_photo.filename }
        expect(response.content_type).to eq("image/webp")
      end
    end

    context "error handling" do
      it "handles database connection errors gracefully" do
        allow(Property).to receive(:find).and_raise(ActiveRecord::ConnectionNotEstablished)

        expect { get :show, params: { property_id: property.id, filename: photo.filename } }.to raise_error(ActiveRecord::ConnectionNotEstablished)
      end

      it "handles file system errors gracefully" do
        allow(File).to receive(:exist?).and_raise(Errno::EACCES, "Permission denied")

        expect { get :show, params: { property_id: property.id, filename: photo.filename } }.to raise_error(Errno::EACCES)
      end
    end

    context "performance characteristics" do
      it "limits database queries" do
        FileUtils.mkdir_p(File.dirname(photo.file_path))
        File.write(photo.file_path, "fake image content")

        expect { get :show, params: { property_id: property.id, filename: photo.filename } }.to make_database_queries(count: 2)

        File.delete(photo.file_path) if File.exist?(photo.file_path)
      end

      it "doesn't load unnecessary associations" do
        expect(Property).to receive(:find).with(property.id.to_s).and_call_original
        expect(Property).not_to receive(:includes)

        get :show, params: { property_id: property.id, filename: photo.filename }
      end
    end
  end

  describe "parameter handling" do
    it "handles special characters in filename" do
      special_photo = create(:photo, property: property, filename: 'photo with spaces & symbols!.jpg')

      get :show, params: { property_id: property.id, filename: special_photo.filename }
      expect(assigns(:photo)).to eq(special_photo)
    end

    it "handles Unicode characters in filename" do
      unicode_photo = create(:photo, property: property, filename: 'фото_测试_éñ.jpg')

      get :show, params: { property_id: property.id, filename: unicode_photo.filename }
      expect(assigns(:photo)).to eq(unicode_photo)
    end

    it "handles very long filenames" do
      long_filename = "#{'a' * 200}.jpg"
      long_photo = create(:photo, property: property, filename: long_filename)

      get :show, params: { property_id: property.id, filename: long_filename }
      expect(assigns(:photo)).to eq(long_photo)
    end
  end
end

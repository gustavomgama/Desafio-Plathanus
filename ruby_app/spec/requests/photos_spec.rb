require "rails_helper"

RSpec.describe "Photos", type: :request do
  let(:property) { create(:property, :with_cover_photo) }
  let(:photo) { property.photos.first }

  describe "GET /photos/:property_id/:filename" do
    context "with valid property and photo file" do
      before do
        FileUtils.mkdir_p(File.dirname(photo.file_path))
        File.write(photo.file_path, "fake image content")
      end

      after do
        File.delete(photo.file_path) if File.exist?(photo.file_path)
      end

      it "returns successful response" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response).to have_http_status(:ok)
      end

      it "serves image with correct content type" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response.content_type).to eq(photo.content_type)
      end

      it "serves file with inline disposition" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response.headers["Content-Disposition"]).to include("inline")
      end

      it "serves actual file content" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response.body).to eq("fake image content")
      end

      it "works with the named route" do
        get photo_path(property_id: property.id, filename: photo.filename)
        expect(response).to have_http_status(:ok)
      end

      it "works with nested resource route" do
        get "/properties/#{property.id}/photos/#{photo.filename}"
        expect(response).to have_http_status(:ok)
      end
    end

    context "with missing photo file" do
      it "returns not found when file doesn't exist on disk" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "returns empty body for not found" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response.body).to be_empty
      end
    end

    context "with invalid property id" do
      it "returns not found for non-existent property" do
        get "/photos/99999/#{photo.filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for malformed property id" do
        get "/photos/invalid/#{photo.filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for negative property id" do
        get "/photos/-1/#{photo.filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "returns empty body for invalid property" do
        get "/photos/99999/#{photo.filename}"
        expect(response.body).to be_empty
      end
    end

    context "with invalid filename" do
      it "returns not found for non-existent filename" do
        get "/photos/#{property.id}/non-existent.jpg"
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for empty filename" do
        get "/photos/#{property.id}/"
        expect(response).to have_http_status(:not_found)
      end

      it "returns not found for filename from different property" do
        other_property = create(:property, :with_cover_photo)
        other_photo = other_property.photos.first

        get "/photos/#{property.id}/#{other_photo.filename}"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "security testing" do
      it "prevents path traversal attacks" do
        malicious_filename = "../../../etc/passwd"

        get "/photos/#{property.id}/#{malicious_filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "prevents accessing files outside photo directory" do
        malicious_filename = "../../../../config/database.yml"

        get "/photos/#{property.id}/#{malicious_filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "handles URL encoded path traversal attempts" do
        malicious_filename = URI.encode_www_form_component("../../../etc/passwd")

        get "/photos/#{property.id}/#{malicious_filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "prevents null byte injection" do
        malicious_filename = URI.encode_www_form_component("photo.jpg\x00.txt")

        get "/photos/#{property.id}/#{malicious_filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "handles double-encoded path traversal" do
        malicious_filename = "%252E%252E%252F%252E%252E%252Fetc%252Fpasswd"

        get "/photos/#{property.id}/#{malicious_filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "prevents access to system files" do
        system_files = [
          "/etc/passwd",
          "/proc/version",
          "/var/log/auth.log",
          "config/master.key",
          ".env"
        ]

        system_files.each do |file|
          get "/photos/#{property.id}/#{file}"
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "different image formats" do
      let!(:jpeg_photo) { create(:photo, property: property, content_type: "image/jpeg", filename: "test.jpg") }
      let!(:png_photo) { create(:photo, property: property, content_type: "image/png", filename: "test.png") }
      let!(:webp_photo) { create(:photo, property: property, content_type: "image/webp", filename: "test.webp") }

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
        get "/photos/#{property.id}/#{jpeg_photo.filename}"
        expect(response.content_type).to eq('image/jpeg')
      end

      it "serves PNG files with correct content type" do
        get "/photos/#{property.id}/#{png_photo.filename}"
        expect(response.content_type).to eq("image/png")
      end

      it "serves WebP files with correct content type" do
        get "/photos/#{property.id}/#{webp_photo.filename}"
        expect(response.content_type).to eq("image/webp")
      end
    end

    context "special characters in filenames" do
      let!(:special_photo) { create(:photo, property: property, filename: 'photo with spaces & symbols!.jpg') }

      before do
        FileUtils.mkdir_p(File.dirname(special_photo.file_path))
        File.write(special_photo.file_path, "fake content")
      end

      after do
        File.delete(special_photo.file_path) if File.exist?(special_photo.file_path)
      end
    end

    context "performance testing" do
      before do
        FileUtils.mkdir_p(File.dirname(photo.file_path))
        File.write(photo.file_path, "fake image content")
      end

      after do
        File.delete(photo.file_path) if File.exist?(photo.file_path)
      end

      it "serves files efficiently with minimal database queries" do
        expect { get "/photos/#{property.id}/#{photo.filename}" }.to make_database_queries(count: 2)
      end

      it "serves large files without timeout" do
        # Simulate a larger file
        large_content = "x" * 1000000 # 1MB of data
        File.write(photo.file_path, large_content)

        start_time = Time.current
        get "/photos/#{property.id}/#{photo.filename}"
        end_time = Time.current

        expect(response).to have_http_status(:ok)
        expect(end_time - start_time).to be < 5.seconds
      end
    end

    context "HTTP headers and caching" do
      before do
        FileUtils.mkdir_p(File.dirname(photo.file_path))
        File.write(photo.file_path, "fake image content")
      end

      after do
        File.delete(photo.file_path) if File.exist?(photo.file_path)
      end

      it "includes proper content disposition header" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response.headers['Content-Disposition']).to include('inline')
        expect(response.headers['Content-Disposition']).to include(photo.filename)
      end

      it "includes content length header" do
        get "/photos/#{property.id}/#{photo.filename}"
        expect(response.headers['Content-Length']).to eq("fake image content".bytesize.to_s)
      end
    end

    context "edge cases" do
      it "handles very long property ids" do
        long_id = "9" * 100
        get "/photos/#{long_id}/#{photo.filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "handles very long filenames" do
        long_filename = "a" * 300 + ".jpg"
        get "/photos/#{property.id}/#{long_filename}"
        expect(response).to have_http_status(:not_found)
      end

      it "handles binary data in filename" do
        binary_filename = URI.encode_www_form_component("\x00\x01\x02.jpg")
        get "/photos/#{property.id}/#{binary_filename}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "route constraints and format handling" do
    let(:property) { create(:property, :with_cover_photo) }

    it "matches route constraint for complex filenames" do
      complex_filename = "property_1_living_room-view_2024.jpg"
      create(:photo, property: property, filename: complex_filename)

      expect { get "/photos/#{property.id}/#{complex_filename}" }.not_to raise_error
    end

    it "handles filenames with dots correctly" do
      dotted_filename = "file.with.many.dots.jpg"
      create(:photo, property: property, filename: dotted_filename)

      expect { get "/photos/#{property.id}/#{dotted_filename}" }.not_to raise_error
    end
  end
end

require "rails_helper"

RSpec.describe "Properties routing", type: :routing do
  before do
    Rails.application.routes.default_url_options[:host] = 'test.host'
  end

  after do
    Rails.application.routes.default_url_options.delete(:host)
  end
  describe "root route" do
    it "routes root to properties#index" do
      expect(get: "/").to route_to("properties#index")
    end

    it "generates root_path correctly" do
      expect(root_path).to eq("/")
    end

    it "generates root_url correctly" do
      expect(root_url).to eq("http://test.host/")
    end
  end

  describe "properties routes" do
    it "routes GET /properties to properties#index" do
      expect(get: "/properties").to route_to("properties#index")
    end

    it "routes GET /properties/:id to properties#show" do
      expect(get: "/properties/1").to route_to("properties#show", id: "1")
    end

    it "generates properties_path correctly" do
      expect(properties_path).to eq("/properties")
    end

    it "generates property_path correctly" do
      expect(property_path(1)).to eq("/properties/1")
    end

    it "generates properties_url correctly" do
      expect(properties_url).to eq("http://test.host/properties")
    end

    it "generates property_url correctly" do
      expect(property_url(1)).to eq("http://test.host/properties/1")
    end

    context "with property object" do
      let(:property) { build_stubbed(:property, id: 42) }

      it "generates property_path with object" do
        expect(property_path(property)).to eq("/properties/42")
      end

      it "generates property_url with object" do
        expect(property_url(property)).to eq("http://test.host/properties/42")
      end
    end

    context "edge cases for property ids" do
      it "handles large integer ids" do
        expect(property_path(999999)).to eq("/properties/999999")
      end

      it "handles string ids" do
        expect(property_path("123")).to eq("/properties/123")
      end
    end
  end

  describe "photo routes" do
    it "routes GET /photos/:property_id/:filename to photos#show" do
      expect(get: "/photos/1/image.jpg").to route_to(
        "photos#show",
        property_id: "1",
        filename: "image.jpg"
      )
    end

    it "routes nested photo path correctly" do
      expect(get: "/properties/1/photos/image.jpg").to route_to(
        "photos#show",
        property_id: "1",
        id: "image",
        format: "jpg"
      )
    end

    it "generates photo_path correctly" do
      expect(photo_path(property_id: 1, filename: "image.jpg")).to eq("/photos/1/image.jpg")
    end

    it "generates property_photo_path correctly" do
      expect(property_photo_path(1, "image")).to eq("/properties/1/photos/image")
    end

    it "generates photo_url correctly" do
      expect(photo_url(property_id: 1, filename: "image.jpg")).to eq("http://test.host/photos/1/image.jpg")
    end

    context "with property and photo objects" do
      let(:property) { build_stubbed(:property, id: 42) }
      let(:photo) { build_stubbed(:photo, filename: "test.jpg") }

      it "generates photo_path with objects" do
        expect(photo_path(property_id: property.id, filename: photo.filename)).to eq("/photos/42/test.jpg")
      end

      it "generates property_photo_path with objects" do
        expect(property_photo_path(property.id, "test")).to eq("/properties/42/photos/test")
      end
    end

    context "filename constraints" do
      it "handles simple filenames" do
        expect(get: "/photos/1/image.jpg").to route_to(
          "photos#show",
          property_id: "1",
          filename: "image.jpg"
        )
      end

      it "handles complex filenames with hyphens and underscores" do
        expect(get: "/photos/1/property_1_living-room_view.jpg").to route_to(
          "photos#show",
          property_id: "1",
          filename: "property_1_living-room_view.jpg"
        )
      end

      it "handles filenames with multiple dots" do
        expect(get: "/photos/1/file.with.dots.jpg").to route_to(
          "photos#show",
          property_id: "1",
          filename: "file.with.dots.jpg"
        )
      end

      it "handles filenames with spaces (URL encoded)" do
        expect(get: "/photos/1/file%20with%20spaces.jpg").to route_to(
          "photos#show",
          property_id: "1",
          filename: "file with spaces.jpg"
        )
      end

      it "handles different image extensions" do
        %w[jpg jpeg png gif webp].each do |ext|
          expect(get: "/photos/1/image.#{ext}").to route_to(
            "photos#show",
            property_id: "1",
            filename: "image.#{ext}"
          )
        end
      end

      it "handles uppercase extensions" do
        expect(get: "/photos/1/image.JPG").to route_to(
          "photos#show",
          property_id: "1",
          filename: "image.JPG"
        )
      end

      it "handles numeric filenames" do
        expect(get: "/photos/1/12345.jpg").to route_to(
          "photos#show",
          property_id: "1",
          filename: "12345.jpg"
        )
      end

      it "handles filenames with special characters" do
        expect(get: "/photos/1/photo&image!.jpg").to route_to(
          "photos#show",
          property_id: "1",
          filename: "photo&image!.jpg"
        )
      end
    end

    context "filename generation" do
      it "properly escapes special characters in paths" do
        filename = "photo with spaces & symbols!.jpg"
        path = photo_path(property_id: 1, filename: filename)
        expect(path).to eq("/photos/1/photo%20with%20spaces%20&%20symbols!.jpg")
      end

      it "handles Unicode characters in filenames" do
        filename = "фото_测试_éñ.jpg"
        path = photo_path(property_id: 1, filename: filename)
        expect(path).to include("/photos/1/")
        expect(path).to include(CGI.escape(filename))
      end
    end
  end

  describe "non-existent routes" do
    it "does not route POST to properties" do
      expect(post: "/properties").not_to be_routable
    end

    it "does not route PUT to properties" do
      expect(put: "/properties/1").not_to be_routable
    end

    it "does not route DELETE to properties" do
      expect(delete: "/properties/1").not_to be_routable
    end

    it "does not route PATCH to properties" do
      expect(patch: "/properties/1").not_to be_routable
    end

    it "does not route POST to photos" do
      expect(post: "/photos/1/image.jpg").not_to be_routable
    end

    it "does not route PUT to photos" do
      expect(put: "/photos/1/image.jpg").not_to be_routable
    end

    it "does not route DELETE to photos" do
      expect(delete: "/photos/1/image.jpg").not_to be_routable
    end
  end

  describe "health check route" do
    it "routes GET /up to rails/health#show" do
      expect(get: "/up").to route_to("rails/health#show")
    end

    it "generates rails_health_check_path correctly" do
      expect(rails_health_check_path).to eq("/up")
    end

    it "generates rails_health_check_url correctly" do
      expect(rails_health_check_url).to eq("http://test.host/up")
    end
  end

  describe "route precedence" do
    it "prioritizes specific photo route over nested photo route" do
      # Both routes should work, but the direct route should take precedence
      expect(get: "/photos/1/image.jpg").to route_to(
        "photos#show",
        property_id: "1",
        filename: "image.jpg"
      )
    end
  end

  describe "route generation with different hosts" do
    it "generates URLs with custom host" do
      original_host = Rails.application.routes.default_url_options[:host]
      Rails.application.routes.default_url_options[:host] = "example.com"

      expect(property_url(1)).to eq("http://example.com/properties/1")

      Rails.application.routes.default_url_options[:host] = original_host
    end
  end

  describe "route constraints validation" do
    it "validates that all defined routes are accessible" do
      Rails.application.routes.routes.each do |route|
        next unless route.defaults[:controller] == "photos"

        reasonable_filenames = [
          "image.jpg",
          "photo_1.png",
          "room-view.jpeg",
          "file.with.dots.webp"
        ]

        reasonable_filenames.each do |filename|
          path = "/photos/1/#{filename}"
          expect(get: path).to route_to(
            "photos#show",
            property_id: "1",
            filename: filename
          )
        end
      end
    end
  end
end

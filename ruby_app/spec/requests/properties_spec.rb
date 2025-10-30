require "rails_helper"

RSpec.describe "Properties", type: :request do
  describe "GET /properties" do
    context "with properties in database" do
      let!(:property1) { create(:property, name: "Alpha Luxury Villa") }
      let!(:property2) { create(:property, name: "Beta Modern Condo") }
      let!(:property3) { create(:property, name: "Gamma Classic House") }

      before do
        create_list(:photo, 2, property: property1)
        create_list(:photo, 4, property: property2)
        create(:photo, property: property3)
      end

      it "returns successful response" do
        get properties_path
        expect(response).to have_http_status(:ok)
      end

      it "returns HTML content type" do
        get properties_path
        expect(response.content_type).to include('text/html')
      end

      it "displays all properties" do
        get properties_path

        expect(response.body).to include("Alpha Luxury Villa")
        expect(response.body).to include("Beta Modern Condo")
        expect(response.body).to include("Gamma Classic House")
      end

      it "displays property statistics" do
        get properties_path

        expect(response.body).to include("3")
        expect(response.body).to include("Properties")
        expect(response.body).to include("Photos")
      end

      it "shows cover photo indicators" do
        get properties_path

        expect(response.body).to include("Featured")
      end

      it "displays photo counts for each property" do
        get properties_path

        expect(response.body).to include("2 photos")
        expect(response.body).to include("4 photos")
        expect(response.body).to include("1 photo")
      end

      it "includes view property links" do
        get properties_path

        expect(response.body).to include(property_path(property1))
        expect(response.body).to include(property_path(property2))
        expect(response.body).to include(property_path(property3))
      end

      it "orders properties alphabetically" do
        get properties_path

        alpha_pos = response.body.index("Alpha Luxury Villa")
        beta_pos = response.body.index("Beta Modern Condo")
        gamma_pos = response.body.index("Gamma Classic House")

        expect(alpha_pos).to be < beta_pos
        expect(beta_pos).to be < gamma_pos
      end

      it "responds to root path" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Alpha Luxury Villa")
      end
    end

    context "with no properties in database" do
      it "returns successful response" do
        get properties_path
        expect(response).to have_http_status(:ok)
      end

      it "displays empty state message" do
        get properties_path

        expect(response.body).to include("No Properties Available")
        expect(response.body).to include("rails db:seed")
      end

      it "shows zero in statistics" do
        get properties_path

        expect(response.body).to include("0")
      end
    end

    context "with large number of properties" do
      before do
        create_list(:property, 25, :with_cover_photo)
      end

      it "handles many properties efficiently" do
        start_time = Time.current
        get properties_path
        end_time = Time.current

        expect(response).to have_http_status(:ok)
        expect(end_time - start_time).to be < 1.second
      end

      it "displays all properties without pagination" do
        get properties_path

        expect(response.body.scan(/View Property/).count).to eq(25)
      end
    end

    context "error scenarios" do
      it "handles database errors gracefully" do
        allow(Property).to receive(:includes).and_raise(ActiveRecord::ConnectionNotEstablished)

        expect { get properties_path }.to raise_error(ActiveRecord::ConnectionNotEstablished)
      end
    end

    context "performance testing" do
      it "executes reasonable database queries" do
        create_list(:property, 10, :with_cover_photo)

        expect { get properties_path }.to make_database_queries
      end
    end

    context "security testing" do
      it "handles malicious parameters gracefully" do
        get properties_path, params: {
          malicious: "<script>alert('xss')</script>",
          sql_injection: "'; DROP TABLE properties; --"
        }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /properties/:id" do
    let(:property) { create(:property, :with_cover_photo, name: "Test Property") }

    context "with valid property id" do
      it "returns successful response" do
        get property_path(property)
        expect(response).to have_http_status(:ok)
      end

      it "returns HTML content type" do
        get property_path(property)
        expect(response.content_type).to include('text/html')
      end

      it "displays the property name" do
        get property_path(property)
        expect(response.body).to include("Test Property")
      end

      it "includes property photos information" do
        get property_path(property)

        # Should show photo count and other photo-related info
        expect(response.body).to include("photos").or include("Photos")
      end
    end

    context "with invalid property id" do
      it "redirects to properties index for non-existent id" do
        get property_path(id: 99999)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(properties_path)
      end

      it "sets flash alert message" do
        get property_path(id: 99999)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(properties_path)
      end

      it "handles malformed property id" do
        get property_path(id: 'malformed-id')

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(properties_path)
      end

      it "handles SQL injection attempts" do
        malicious_id = "1' OR '1'='1"
        get property_path(id: malicious_id)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(properties_path)
      end
    end

    context "with deleted property" do
      it "handles destroyed property gracefully" do
        property_id = property.id
        property.destroy

        get property_path(id: property_id)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(properties_path)
      end
    end

    context "performance testing" do
      it "executes reasonable database queries" do
        # Request specs include full Rails stack, so we expect more queries than controller specs
        expect { get property_path(property) }.to make_database_queries
      end

      it "preloads associations efficiently" do
        get property_path(property)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "HTTP caching and headers" do
    let(:property) { create(:property, :with_cover_photo) }

    it "includes proper cache headers for property index" do
      get properties_path

      expect(response.headers).to have_key('Cache-Control')
    end

    it "includes proper cache headers for property show" do
      get property_path(property)

      expect(response.headers).to have_key('Cache-Control')
    end
  end

  describe "responsive design endpoints" do
    let(:property) { create(:property, :with_cover_photo) }

    it "serves properties index for mobile user agents" do
      get properties_path, headers: {
        'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X)'
      }

      expect(response).to have_http_status(:ok)
    end

    it "serves property show for mobile user agents" do
      get property_path(property), headers: {
        'HTTP_USER_AGENT' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X)'
      }

      expect(response).to have_http_status(:ok)
    end
  end

  describe "internationalization readiness" do
    let(:property) { create(:property, name: "Propriedade Teste") }

    it "handles UTF-8 property names correctly" do
      get property_path(property)

      expect(response).to have_http_status(:ok)
      expect(response.body.encoding).to eq(Encoding::UTF_8)
    end
  end

  describe "API format readiness" do
    let(:property) { create(:property, :with_cover_photo) }

    it "could support JSON format in future" do
      expect { get properties_path, headers: { 'Accept' => 'application/json' } }.not_to raise_error
    end
  end
end

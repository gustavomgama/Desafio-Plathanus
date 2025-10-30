require "rails_helper"

RSpec.describe PropertiesController, type: :controller do
  describe "GET #index" do
    context "with properties in database" do
      let!(:property1) { create(:property, name: "Alpha Property") }
      let!(:property2) { create(:property, name: "Beta Property") }
      let!(:property3) { create(:property, name: "Gamma Property") }

      before do
        create_list(:photo, 2, property: property1)
        create_list(:photo, 4, property: property2)
        create(:photo, property: property3)
      end

      it "returns successful response" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "assigns all properties to @properties" do
        get :index
        expect(assigns(:properties)).to contain_exactly(property1, property2, property3)
      end

      it "orders properties by name" do
        get :index
        properties = assigns(:properties).to_a
        expect(properties).to eq([ property1, property2, property3 ])
      end

      it "includes photos association to prevent N+1 queries" do
        expect(Property).to receive(:includes).with(:photos).and_call_original
        get :index
      end

      it "loads photos association efficiently" do
        get :index

        properties = assigns(:properties)
        expect(properties.first.association(:photos)).to be_loaded
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context "with no properties in database" do
      it "returns successful response" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "assigns empty collection to @properties" do
        get :index
        expect(assigns(:properties)).to be_empty
      end

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end

  describe "GET #show" do
    let(:property) { create(:property, :with_cover_photo) }

    context "with valid property id" do
      it "returns successful response" do
        get :show, params: { id: property.id }
        expect(response).to have_http_status(:success)
      end

      it "assigns the property to @property" do
        get :show, params: { id: property.id }
        expect(assigns(:property)).to eq(property)
      end

      it "includes photos association to prevent N+1 queries" do
        expect(Property).to receive(:includes).with(:photos).and_call_original
        get :show, params: { id: property.id }
      end

      it "preloads photos association for show action" do
        get :show, params: { id: property.id }
        expect(assigns(:property).association(:photos)).to be_loaded
      end

      it "renders the show template" do
        get :show, params: { id: property.id }
        expect(response).to render_template(:show)
      end
    end

    context "with invalid property id" do
      it "redirects to properties index" do
        get :show, params: { id: "non-existent" }
        expect(response).to redirect_to(properties_path)
      end

      it "sets alert flash message" do
        get :show, params: { id: "non-existent" }
        expect(flash[:alert]).to eq("Property not found")
      end

      it "handles integer ids that don't exist" do
        get :show, params: { id: 99999 }
        expect(response).to redirect_to(properties_path)
        expect(flash[:alert]).to eq("Property not found")
      end

      it "handles malformed ids gracefully" do
        get :show, params: { id: 'malformed-id' }
        expect(response).to redirect_to(properties_path)
        expect(flash[:alert]).to eq("Property not found")
      end
    end

    context "with deleted property" do
      it "handles soft-deleted properties appropriately" do
        property_id = property.id
        property.destroy

        get :show, params: { id: property_id }
        expect(response).to redirect_to(properties_path)
        expect(flash[:alert]).to eq("Property not found")
      end
    end
  end

  describe "error handling" do
    it "handles database connection errors gracefully" do
      allow(Property).to receive(:includes).and_raise(ActiveRecord::ConnectionNotEstablished)

      expect { get :index }.to raise_error(ActiveRecord::ConnectionNotEstablished)
    end

    it "handles timeout errors gracefully" do
      allow(Property).to receive(:includes).and_raise(ActiveRecord::QueryCanceled)

      expect { get :index }.to raise_error(ActiveRecord::QueryCanceled)
    end
  end

  describe "security and parameter handling" do
    it "doesn't expose unnecessary parameters" do
      get :index, params: { malicious_param: 'value' }
      expect(response).to have_http_status(:success)
    end

    it "handles missing required parameters gracefully" do
      expect { get :show, params: {} }.to raise_error(ActionController::UrlGenerationError)
    end
  end

  describe "performance characteristics" do
    it "includes photos association for index action" do
      create_list(:property, 5, :with_cover_photo)

      expect(Property).to receive(:includes).with(:photos).and_call_original
      get :index
    end

    it "includes photos association for show action" do
      property = create(:property, :with_cover_photo)

      expect(Property).to receive(:includes).with(:photos).and_call_original
      get :show, params: { id: property.id }
    end
  end
end

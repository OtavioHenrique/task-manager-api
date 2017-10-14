require "rails_helper"

RSpec.describe 'Users API', type: :request  do
  let!(:user) { create(:user) } 
  let(:user_id) { user.id }
  let!(:auth_data) { user.create_new_auth_token }
  let(:headers) do 
    {
      "Accept" => "application/json",
      "Content-Type" => Mime[:json].to_s,
      "access-token" => auth_data["access-token"],
      "uid" => auth_data["uid"],
      "client" => auth_data["client"]
    }
  end

  before { host! "api.task-manager.dev:80/v2" }

  describe "GET /auth/validate_token" do
    context "when request headers are valid" do
      before do
        get "/auth/validate_token", params: {}, headers: headers
      end

      it "returns the user" do
        expect(json_body["data"]["id"].to_i).to eq(user_id)
      end

      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end

    context "when request headers are not valid" do
      before do
        headers["access-token"] = "invalid_token"
        get "/auth/validate_token", params: {}, headers: headers
      end

      it "returns 401 status" do
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "POST /auth" do
    before do
      post "/auth", params: user_params.to_json, headers: headers
    end

    context "when request params are valid" do
      let(:user_params) { attributes_for(:user) }
      
      it "returns correct json for user created" do
        expect(json_body["data"]["email"]).to eq(user_params[:email])
      end

      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end

    context "when request params are invalid" do
      let(:user_params) { attributes_for(:user, email: "invalid_email@") }

      it "returns 422 status" do
        expect(response).to have_http_status(422)
      end

      it "returns json data with errors" do
        expect(json_body).to have_key("errors")
      end
    end
  end

  describe "PUT /auth" do
    before do
      put "/auth", params: user_params.to_json, headers: headers
    end
    
    context "when request is valid" do
      let(:user_params) { { email: "new@email.com" } }

      it "returns status code 200" do
        expect(response).to have_http_status(200)   
      end

      it "returns json data with updated user" do
        expect(json_body["data"]["email"]).to eq(user_params[:email])
      end
    end

    context "when request params is invalid" do
      let(:user_params) { attributes_for(:user, email: "invalid_email@") }

      it "returns 422 status" do
        expect(response).to have_http_status(422)
      end

      it "returns json data with errors" do
        expect(json_body).to have_key("errors")
      end
    end
  end

  describe "DELETE /auth" do
    before do
      delete "/auth", params: {}, headers: headers
    end
    
    it "returns 200" do
      expect(response).to have_http_status(200)
    end

    it "remove user from database" do
      expect(User.find_by(id: user.id)).to be_nil
    end
  end
end

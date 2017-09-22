require "rails_helper"

RSpec.describe 'Users API', type: :request  do
  let!(:user) { create(:user) } 
  let(:user_id) { user.id }
  let(:headers) do 
    {
      "Accept" => "application/json",
      "Content-Type" => Mime[:json].to_s
    }
  end

  before { host! "api.task-manager.dev:80/v1" }

  describe "GET /users/:id" do
    before do
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context "when user exists" do
      it "returns the user" do
        expect(json_body["id"]).to eq(user_id)
      end

      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end

    context "when users dont exist" do
      let(:user_id) { 40 }

      it "returns 404 status" do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "GET /users" do
    before do
      get "/users", params: {}, headers: headers
    end

    context "when exists users on db" do
      it "returns users" do
        expect(json_body.first["id"]).to eq(user_id)
      end

      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "POST /users" do
    before do
      post "/users", params: { user: user_params }.to_json, headers: headers
    end

    context "when request params are valid" do
      let(:user_params) { attributes_for(:user) }
      
      it "returns correct json for user created" do
        expect(json_body["email"]).to eq(user_params[:email])
      end

      it "returns 201 status" do
        expect(response).to have_http_status(201)
      end
    end

    context "when request params are invalid" do
      let(:user_params) { attributes_for(:user, email: "invalid_email@") }

      it "returns 422 status" do
        expect(response).to have_http_status(422)
      end

      it "returns json data with errors" do
        expect(json_body).to have_key('errors')
      end
    end
  end

  describe "PUT /users/:id" do
    before do
      put "/users/#{user_id}", params: { user: user_params }.to_json, headers: headers
    end
    
    context "when request is valid" do
      let(:user_params) { { email: "new@email.com" } }

      it "returns status code 200" do
        expect(response).to have_http_status(200)   
      end

      it "returns json data with updated user" do
        expect(json_body["email"]).to eq(user_params[:email])
      end
    end

    context "when request params is invalid" do
      let(:user_params) { attributes_for(:user, email: "invalid_email@") }

      it "returns 422 status" do
        expect(response).to have_http_status(422)
      end

      it "returns json data with errors" do
        expect(json_body).to have_key('errors')
      end
    end
  end

  describe "DELETE /users/:id" do
    before do
      delete "/users/#{user_id}", params: {}, headers: headers
    end
    
    it "returns 404" do
      expect(response).to have_http_status(204)
    end

    it "remove user from database" do
      expect(User.find_by(id: user.id)).to be_nil
    end
  end
end

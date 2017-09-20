require "rails_helper"

RSpec.describe 'Users API', type: :request  do
  let!(:user) { create(:user) } 
  let(:user_id) { user.id }
  
  before { host! "api.task-manager.dev:80/v1" }

  describe "GET /users/:id" do
    before do
      headers = { "Accept" => "application/json" }
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context "when user exists" do
      it "returns the user" do
        user_response = JSON.parse(response.body)
        expect(user_response["id"]).to eq(user_id)
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
      headers = { "Accept" => "application/json" }
      get "/users", params: {}, headers: headers
    end

    context "when exists users on db" do
      it "returns users" do
        user_response = JSON.parse(response.body)
        expect(user_response.first["id"]).to eq(user_id)
      end

      it "returns 200 status" do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "POST /users" do
    before do
      headers = { "Accept" => "application/json" }
      post "/users", params: { user: user_params }, headers: headers
    end

    context "when request params are valid" do
      let(:user_params) { attributes_for(:user) }
      
      it "returns correct json for user created" do
        user_response = JSON.parse(response.body)
        expect(user_response["email"]).to eq(user_params[:email])
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
        user_response = JSON.parse(response.body)
        expect(user_response).to have_key('errors')
      end
    end
  end
end

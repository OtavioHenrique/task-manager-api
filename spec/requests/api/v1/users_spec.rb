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
        it "should return the user" do
          user_response = JSON.parse(response.body)
          expect(user_response["id"]).to eq(user_id)
        end

        it "should return 200 status" do
          expect(response).to have_http_status(200)
        end
      end

      context "when users dont exist" do
        let(:user_id) { 40 }

      it "should return 404 status" do
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
      it "shoul return users" do
        user_response = JSON.parse(response.body)
        expect(user_response.first["id"]).to eq(user_id)
      end

      it "should return 200 status" do
        expect(response).to have_http_status(200)
      end
    end
  end
end

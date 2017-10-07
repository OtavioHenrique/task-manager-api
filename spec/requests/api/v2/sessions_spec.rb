require 'rails_helper'

RSpec.describe 'Sessions API', type: :request do 
  before { host! "api.task-manager.dev:80/v2" }
  
  let(:user) { create(:user) }
  let(:headers) do 
    {
      "Accept" => "application/json",
      "Content-Type" => Mime[:json].to_s
    }
  end

  describe 'POST /sessions' do
    before do 
      post '/sessions', params: { session: credentials }.to_json, headers: headers
    end

    context 'when the credentials are correct' do
      let(:credentials) { { email: user.email, password: 'password' } }

      it 'return 200 status' do
        expect(response).to have_http_status(200)
      end

      it 'returns json data with current signed in user and token' do
        user.reload
        expect(json_body["data"]["attributes"]["auth-token"]).to eq(user.auth_token)
      end
    end

    context 'when the credentials are incorrect' do
      let(:credentials) { { email: user.email, password: 'invalid_password' } }

      it 'return 401 status' do
        expect(response).to have_http_status(401)
      end

      it 'returns json data with errors' do
        user.reload
        expect(json_body).to have_key("errors")
      end
    end
  end

  describe 'DELETE /sessions/:id' do
    let(:auth_token) { user.auth_token }

    before do
      delete "/sessions/#{auth_token}", params: {}, headers: headers
    end

    it 'returns 204 status' do
      expect(response).to have_http_status(204)
    end

    it 'changes user auth token' do
      expect( User.find_by(auth_token: auth_token) ).to be_nil
    end
  end
end

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }
  
  it { is_expected.to have_many(:tasks).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value("costa@nonato.com").for(:email) }
  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do
    it 'returns email, created_at, and token' do
      user.save!
      allow(Devise).to receive(:friendly_token).and_return("")

      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: #{Devise.friendly_token}")
    end
  end

  describe '#generate_auth_token!' do
    it 'generate unique auth token' do
      allow(Devise).to receive(:friendly_token).and_return("9qwFSqwf30sG")
      user.generate_authentication_token!

      expect(user.auth_token).to eq("9qwFSqwf30sG")
    end

    it 'generate another auth token if curent token already has been taken' do
      allow(Devise).to receive(:friendly_token).and_return("a45bAdfKF23sA_", "a45bAdfKF23sA_", "abdf2423aAbvsGOH_")
      existing_user = create(:user) 
      user.generate_authentication_token!

      expect(user.auth_token).not_to eq(existing_user.auth_token)
    end
  end
end

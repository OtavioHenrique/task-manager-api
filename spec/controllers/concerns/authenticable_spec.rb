require 'rails_helper'

RSpec.describe Authenticable do
  controller(ApplicationController) do
    include Authenticable
  end

  let(:app_controller) { subject }
  
  describe '#current_user' do
    let(:user) { create(:user) }

    before do
      
    end

    it 'return user from authorization header' do
      expect(app_controller.current_user).to eq(user)
    end
  end
end

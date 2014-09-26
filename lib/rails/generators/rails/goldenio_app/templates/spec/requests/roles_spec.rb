require 'rails_helper'

RSpec.describe 'Roles', type: :request do
  let(:user) { Fabricate(:user, role: :admin) }

  describe 'GET /roles' do
    it 'show index page of roles' do
      get roles_path
      follow_sign_in_request
      expect(response.body).to include I18n.t('roles.index.title')
    end
  end
end

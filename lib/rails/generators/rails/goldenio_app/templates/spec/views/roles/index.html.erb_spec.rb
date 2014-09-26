require 'rails_helper'

RSpec.describe 'roles/index', type: :view do
  before(:each) do
    @roles = assign :roles, [
      Fabricate(:role, name: 'administrator'),
      Fabricate(:role, name: 'manager')
    ].paginate
  end

  it 'renders a list of roles' do
    render
    @roles.each do |role|
      assert_select 'tr>td', text: role.human_name, count: 1
      assert_select 'tr>td', text: role.description, count: 1
      assert_select 'tr>td', text: yes_or_no(role.enabled), count: 2
    end
  end
end

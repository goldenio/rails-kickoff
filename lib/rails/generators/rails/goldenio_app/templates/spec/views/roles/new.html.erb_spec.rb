require 'rails_helper'

RSpec.describe 'roles/new', type: :view do
  before(:each) do
    @role = assign :role, Fabricate.build(:role, name: 'administrator')
  end

  it 'renders new role form' do
    render

    assert_select 'form[action=?][method=?]', roles_path, 'post' do
      assert_select 'input#role_name[name=?]', 'role[name]'
      assert_select 'input#role_description[name=?]', 'role[description]'
      assert_select 'input#role_enabled[name=?]', 'role[enabled]'
    end
  end
end

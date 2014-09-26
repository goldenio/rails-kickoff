require 'rails_helper'

RSpec.describe 'roles/show', type: :view do
  before(:each) do
    @role = assign :role, Fabricate(:role, name: 'administrator')
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/#{@role.human_name}/)
    expect(rendered).to match(/#{@role.description}/)
    expect(rendered).to match(/#{yes_or_no(@role.enabled)}/)
  end
end

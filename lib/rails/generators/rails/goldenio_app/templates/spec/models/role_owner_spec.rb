require 'rails_helper'

RSpec.describe RoleOwner, type: :model do
  it 'should have owner and role' do
    role_owner = RoleOwner.create(
      owner: Fabricate(:user),
      role: Fabricate(:role)
    )
    expect(role_owner.valid?).to be true
  end
end

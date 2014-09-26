require 'rails_helper'

RSpec.describe Role, type: :model do
  it 'should have name' do
    role = Role.create
    expect(role.valid?).to be false
    expect(role.errors[:name].size).to eq 1
  end
end

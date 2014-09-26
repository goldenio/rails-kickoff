require 'rails_helper'

RSpec.describe User, type: :model do
  it 'should have email and password' do
    user = User.create
    expect(user.valid?).to be false
    expect(user.errors[:email].size).to eq 1
    expect(user.errors[:password].size).to eq 1
  end
end

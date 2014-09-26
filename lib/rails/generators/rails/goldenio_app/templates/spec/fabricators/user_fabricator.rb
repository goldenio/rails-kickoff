Fabricator :user do
  transient :role

  email { Faker::Internet.safe_email }
  password { Faker::Internet.password(8, 20) }
  # confirmed_at 7.days.ago

  roles { |attrs|
    case attrs[:role]
    when :admin
      [ Fabricate(:role, name: 'administrator') ]
    else
      []
    end
  }

  after_create { |user, transients|
    user.confirm!
  }
end

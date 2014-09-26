RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
    # Rails.application.load_tasks
    # Rails.application.load_seed
    # load "#{Rails.root}/db/seeds.rb"
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

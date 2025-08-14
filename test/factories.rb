FactoryBot.define do
  factory :subscriber do
    sequence(:email) { |n| "subscriber_email#{n}@gmail.com" }
    email_status { 'active' }
  end
  
  factory :company do
    company           { Faker::Company.name }
    symbol            { Faker::Finance.ticker }
    lead_managers     { Faker::Company.name }
    no_of_shares      { Faker::Number.number(digits: 6) }
    price_low         { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    price_high        { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    estimated_volume  { Faker::Number.number(digits: 7) }
    expected_to_trade { Faker::Date.forward(days: 30) }
  end
end
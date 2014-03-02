FactoryGirl.define do 

  factory :user, :class => User do
    sequence(:email) {|l| "test#{l}@testor.com"}
    password "123456"
    password_confirmation "123456"
    sequence(:persistence_token) {|l| "#{Authlogic::Random.hex_token}"}
    sequence(:single_access_token) {|l| "#{Authlogic::Random.hex_token}"}
    sequence(:apikey) {|l| "#{Authlogic::Random.hex_token}"}
  end

  factory :invalid_user, :class => User do
  end

  factory :tconfig do 
    theme "blah"
    sort  "blah"
    per_page 5
  end
end

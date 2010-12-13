Factory.define :user, :class => User do |f|
  f.sequence(:email) {|l| "test#{l}@testor.com"}
  f.password "123456"
  f.password_confirmation "123456"
  f.sequence(:persistence_token) {|l| "#{Authlogic::Random.hex_token}"}
  f.sequence(:single_access_token) {|l| "#{Authlogic::Random.hex_token}"}
  f.sequence(:apikey) {|l| "#{Authlogic::Random.hex_token}"}
end

Factory.define :invalid_user, :class => User do |f|
end

Factory.define :tconfig do |c|
  c.theme "blah"
  c.sort  "blah"
  c.per_page 5
end

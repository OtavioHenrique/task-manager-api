FactoryGirl.define do
  factory :task do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    done false 
    deadline { Faker::Date.forward }
    user
  end
end

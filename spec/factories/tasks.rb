FactoryGirl.define do
  factory :task do
    title { Faker::Lorem.setence }
    description { Faker::Lorem.setence }
    done false 
    deadline { Faker::Date.forward }
    user_id 1
  end
end

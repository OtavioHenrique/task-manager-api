FactoryGirl.define do
  factory :task do
    title "MyString"
    description "MyText"
    done false
    deadline "2017-09-26 19:41:00"
    user nil
  end
end

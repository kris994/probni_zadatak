FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:last_name)  { |n| "Person #{n}" }
    birth_year 1994
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "123456"
    password_confirmation "123456"

  end

  factory :micropost do
    content "Example!"
    user
  end


end
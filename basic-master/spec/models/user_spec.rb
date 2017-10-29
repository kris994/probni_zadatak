# describe User do
#   it { should have_db_column(:email).of_type(:string) }
#   it { should validate_presence_of(:email) }
# end

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { User.new(
                            name: "Kristina",
                            last_name: "Pomorisac",
                            birth_year: 1994,
                            email: "kristipomo@gmail.com",
                            password: "123456",
                            password_confirmation: "123456") }

  it { should respond_to(:name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:birth_year) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }

  it { should be_valid }

  it 'sends an email' do
    expect { subject.send_instructions }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  describe "when name is not present" do
    before {  user.name = " " }
    it { should_not be_valid }
  end

  describe "when last_name is not present" do
    before { user.last_name = " " }
    it { should_not be_valid }
  end

  describe "when birth_year is not present" do
    before { user.birth_year = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when last_name is too long" do
    before { user.last_name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when birth_year is too long" do
    before { user.birth_year = 1 * 5 }
    it { should_not be_valid }
  end

  describe "when birth_year is valid" do
    it { should validate_numericality_of(:birth_year).only_integer }
    it { should validate_numericality_of(:birth_year).is_less_than_or_equal_to(2017) }
    it { should validate_numericality_of(:birth_year).is_greater_than_or_equal_to(1900) }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,bar user.foo user@foo.]
      addresses << "too.long.email@address.com" + "a" * 250
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).not_to be_valid
      end
    end
  end

  describe "when email format is invalid" do
    it "should be valid" do
      addresses = %w[user@foo.bar a+b@a.com toshi...1@a.b.c]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    subject(:user) { User.new(
                              name: "Example Name",
                              last_name: "Example Last_Name",
                              birth_year: 1111,
                              email: "user@example.com",
                              password: " ",
                              password_confirmation: " ") }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { user.password_confirmation = "aaa" }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { user.password = user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { user.save }
    let(:found_user) { User.find_by(email: user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be false }
    end
  end

  describe "remember token" do
    before { user.save }
    it { expect(user.remember_token).not_to be_blank }
  end

  describe "micropost associations" do
    before { user.save }
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: user, created_at: 3.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: user, created_at: 1.hour.ago)
    end

    it "should have the right microposts in the right order" do
      expect(user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = user.microposts.to_a
      user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }

      before do
        user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Example!") }
      end

      specify do
        expect(user.feed).to include(newer_micropost)
        expect(user.feed).to include(older_micropost)
        expect(user.feed).to not_to include(unfollowed_post)

        followed_user.microposts.each do |micropost|
          expect(user.feed).to include(micropost)
        end
      end
    end
  end

  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      user.save
      user.follow!(other_user)
    end

    it { should be_following(other_user) }
    specify { expect(user.followed_users).to include(other_user) }

    describe "followed user" do
      specify { expect(other_user.followers).to include(user) }
    end

    describe "and unfollowing" do
      before { user.unfollow!(other_user) }

      it { should_not be_following(other_user) }
      specify { expect(user.followed_users).to not_to include(other_user) }
    end
  end


  end
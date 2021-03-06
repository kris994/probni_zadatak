require 'spec_helper'

RSpec.describe Relationship, type: :model do
  let(:follower) { FactoryGirl.create(:user) }
  let(:followed) { FactoryGirl.create(:user) }
  subject(:relationship) { follower.relationships.build(followed_id: followed.id) }

  it { should be_valid }

  it 'sends an email' do
    expect { subject.send_email }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }

    specify {
      expect(relationship.follower).to eq(follower)
      expect(relationship.followed).to eq(followed)
    }
  end

  describe "when followed id is not present" do
    before { relationship.followed_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { relationship.follower_id = nil }
    it { should_not be_valid }
  end
end
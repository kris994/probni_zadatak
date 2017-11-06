require "spec_helper"

RSpec.describe UserMailer, type: :mailer do

  describe 'new_follower_notification' do
    let(:user) { mock_model User, name: 'Kris', email: 'kris@email.com' }
    let(:follower) { mock_model Relationship, name: 'Tina', last_name: 'Tinic' }
    let(:mail) { described_class.new_follower_notification(user, follower).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Tina Tinic is now following you!')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq('My Twitter <example@example.com')
    end

  end
end
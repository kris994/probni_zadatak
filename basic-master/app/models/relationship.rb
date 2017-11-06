class Relationship < ActiveRecord::Base

  after_create :send_email

  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true


  def send_email
   UserMailer.new_follower_notification(followed, follower).deliver_now
  end

end

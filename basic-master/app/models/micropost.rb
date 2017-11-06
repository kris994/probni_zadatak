class Micropost < ActiveRecord::Base
  belongs_to :user

  default_scope -> {
    where('created_at >= ?', 3.day.ago.utc)}
  default_scope -> {
    order('created_at DESC') }


  validates :content, presence: true, length: { maximum: 160 }
  validates :user_id, presence: true

  after_create :add_mentions

  # shows microposts in your feed from the users being followed by the given user.
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  end

  # returns mentions located in micropost
  def add_mentions
    Mention.create_from_text(self)
  end
end

class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy
  has_many :mentions, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
           class_name:  "Relationship",
           dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  before_save { self.email = email.downcase }
  before_create :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :birth_year,  presence: true,
                          length: { maximum: 4 },
                          :numericality => {:only_integer => true},
                          :numericality => {:less_than_or_equal_to => 2017},
                          :numericality => {:greater_than_or_equal_to => 1900}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }

  def feed
    Micropost.from_users_followed_by(self)
    Micropost.recent_content
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  private

  def create_remember_token
    self.remember_token = User.digest(User.new_remember_token)
  end
end
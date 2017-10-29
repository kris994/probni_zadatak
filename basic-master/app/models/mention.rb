class Mention < ActiveRecord::Base
  belongs_to :user
  attr_reader :mentionable
  include Rails.application.routes.url_helpers

  validates :user_id, presence: true

  # shows all mentions from the user
  #def self.all(letters)
  #  return Mention.none unless letters.present?
  # users = User.limit(5).where('name like ?',"#{letters}%").compact
  # users.map do |user|
  #    { name: user.name, image: user.gravatar_for(size: 30) }
  #  end
  #end

  # it scans the micropost content and searches for the tag "@",
  # once it finds the user with "create_from_match" it will markdown the user
  def self.create_from_text(micropost)
    potential_matches = micropost.content.scan(/@\w+/i)
    potential_matches.uniq.map do |match|
      mention = Mention.create_from_match(match)
      next unless mention
      micropost.update_attributes!(content: mention.markdown_string(micropost.content))
      mention
    end.compact
  end

  # recognizes the user in the mention
  def self.create_from_match(match)
    user = User.find_by(name: match.delete('@'))
    UserMention.new(user) if user.present?
  end

  def initialize(mentionable)
    @mentionable = mentionable
  end

  # once the mention is made it will appear like "[**@Kristina**](http://localhost:3000/users/7)" without markdown
  class UserMention < Mention
    def markdown_string(text)
      host = Rails.env.development? ? 'localhost:3000' : ''
      text.gsub(/@#{mentionable.name}/i,
                "[**@#{mentionable.name}**](#{user_url(mentionable, host: host)})")
    end
  end
end

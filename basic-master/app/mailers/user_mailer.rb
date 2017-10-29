class UserMailer < ActionMailer::Base
  def new_follower_notification(user, follower)
    @user = user
    @follower = follower
    mail(:from => "My Twitter <example@example.com", :to => "#{@user.name} <#{@user.email}>",
         :subject => "#{@follower.name} (#{@follower.last_name}) is now following you!")
  end
end

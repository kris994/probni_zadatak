class RelationshipsController < ApplicationController
  before_action :signed_in_user
  skip_before_action :verify_authenticity_token

  # if the user is not being followed (follow!), create a new relationship based on the followed_id
  # and send an email notification the the followed user
  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    UserMailer.new_follower_notification(@user, current_user).deliver_now
    redirect_to @user
  end

  # if the user is followed (unfollow!), destroy the relationship
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    redirect_to @user
  end
end

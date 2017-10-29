class MicropostsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Tweet created!"
      redirect_to current_user
    else
      #flash[:danger] = @micropost.errors.full_messages.to_sentence
      @feed_items = []
      redirect_to correct_user
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  # this methods are private to make sure it can't be called outside its intended context
  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url if @micropost.nil?
  end
end

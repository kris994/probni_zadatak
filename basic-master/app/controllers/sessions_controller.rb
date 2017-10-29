class SessionsController < ApplicationController

  def new
  end

  # creates a new session on successful sign in
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  # destroys the session on sign out
  def destroy
    sign_out
    redirect_to root_url
  end
end

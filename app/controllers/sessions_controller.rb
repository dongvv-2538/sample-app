class SessionsController < ApplicationController
  def new
  end

  def create 
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      log_in user 
      params[:session][:remember_me] == '1' ? remember_user(user) : forget_user(user)
      redirect_back_or user
    else
      flash[:danger] = 'Invalid email or password' 
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    
    redirect_to root_path
  end


  private
    def session_params
      params.require(:session).permit(:email, :password)
    end
end

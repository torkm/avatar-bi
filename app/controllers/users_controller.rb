class UsersController < ApplicationController
  def index
    if user_signed_in?
      gon.avatars = current_user.avatars
    end
  end

  def show
  end

  def edit
  end

  def update
    if current_user.update(user_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

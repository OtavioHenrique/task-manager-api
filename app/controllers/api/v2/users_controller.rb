class Api::V2::UsersController < Api::V2::BaseController
  before_action :authenticate_with_token!, only: [:update, :destroy]
  respond_to :json

  def index
    user = User.all
    render json: user, status: :ok
  end

  def show
    begin
      user = User.find(params[:id])
      render json: user, status: :ok
    rescue
      head 404
    end
  end

  def create
    user = User.new(user_params)

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  def update
    user = current_user

    if user.update(user_params)
      render json: user, status: :ok
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.destroy
    head 204
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

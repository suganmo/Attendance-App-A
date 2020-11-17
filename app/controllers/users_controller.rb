class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  

  def index
    @users = User.all
     respond_to do |format|
      format.html do
      format.csv do |csv|
        send_users_csv(@posts)
          #csv用の処理を書く
      end
    end
  end
end

  def import
    User.import(params[:file])
    redirect_to users_path
  end

  def show
    if current_user.admin?
      redirect_to action: 'index'
    else
       @worked_sum = @attendances.where.not(started_at: nil).count
    end
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, :password, 
                                   :basic_work_time, :designated_work_start_time, :designated_work_time)
    end

    def overwork_request_params
      params.require(:user).permit(attendances: [:id, :scheduled_end_time, :work_description])[:attendacces]
    end

    def overwork_params
      params.require(:user).paramit(attendanses: [:scheduled_end_time, :next_day, :business_process, :confimation])[:attendances]
    end
end
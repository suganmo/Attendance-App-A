class UsersController < ApplicationController
 require "csv"
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :confirm_one_month, :update_monthly]
  before_action :logged_in_user, only: [:show, :index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :update_monthly]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: [:show, :confirm_one_month, :update_monthly]
  

  def index
    @users = User.all
  end

  def show
    @attendance = Attendance.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @update_monthly_count = Attendance.where(monthly_confirmation: @user.name, monthly_confirmation_status: "申請中").count
    @one_month_count = Attendance.where(month_confirmation: @user.name, month_confirmation_status: "申請中").count
    @overwork_count = Attendance.where(overwork_confirmation: @user.name, overwork_confirmation_status: "申請中").count
    @monthly_request = @user.attendances.find_by(update_monthly_day: @first_day)
   if current_user.admin?
     redirect_to action: 'index'
   else
     @worked_sum = @attendances.where.not(started_at: nil).count
   end
   respond_to do |format|
     format.html 
     format.csv do |csv|
       send_csv(@attendances)
        #csv用の処理を書く
     end
   end
  end

  def new
   @user = User.new
  end

  def import
    User.import(params[:file])
    redirect_to users_path
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
  
  def confirm_one_month
    @user = User.find(params[:id])
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
   
  def update_monthly
    ActiveRecord::Base.transaction do
      @user = User.find(params[:id])
      @attendance = Attendance.find(params[:id])
      @superiors = User.where(superior: true).where.not(id: @user.id)
      unless monthly_params[:monthly_confirmation].blank?
        @attendance.update_attributes(monthly_params)
        flash[:success] = "月次申請をしました。"
      else
        flash[:success] = "申請先を選択してください。"
      end
      redirect_to user_url(@user)
    end
  end

  def attendance_log
    @user = User.find(params[:id])
    @reset = DateTime.new(Time.current.year, Time.current.month, 1)
    if params[:date]
      date = params[:date].to_date # 日付形式にしてる
      @years = date.year
      @months = date.month
    else
      date = DateTime.new(params[:year].to_i, params[:month].to_i-1, 1)
      @years = date.year
      @month = date.month
    end
    @attemdance = @user.attendance
  end
  
  private
  
    def send_csv(attendances)
     csv_data = CSV.generate do |csv|
      colum_name = %w(日付 出社時間 退社時間)
      csv << colum_name
      attendances.each do |attendance|
       column_values = [attendance.worked_on, attendance.started_at, attendance.finished_at]
       csv << column_values
      end
     end
     send_data(csv_data, filename: "勤怠情報.csv")
    end

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end
    
    def logged_in_user
     unless logged_in?
       store_location
       flash[:danger] = "ログインしてください"
       redirect_to_login_url
     end
    end
    
    def admin_user
     redirect_to root_url unless current_user.admin?
    end
    
    def basic_info_params
      params.require(:user).permit(:name, :email, :department, :employee_number, :uid, :password, 
                                   :basic_work_time, :designated_work_start_time, :designated_work_time)
    end
        
end
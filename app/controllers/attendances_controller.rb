class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month, :notice_overwork_request, :approval_overwork_request, :edit_monthly_confirmation, :notice_monthly]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_monthly_confirmation]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month, :notice_overwork_request, :approval_overwork_request, :notice_monthly]
  before_action :set_one_month, only: [:edit_one_month, :edit_monthly_confirmation, :notice_monthly]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
    @attendance = @user.attendances.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end

  def update_one_month
   ActiveRecord::Base.transaction do # トランザクションを開始します。
    if attendances_invalid?
    attendances_params.each do |id, item|
     attendance = Attendance.find(id)
     attendance.update_attributes!(item)
    end
       flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
       redirect_to user_url(date: params[:date])
     else
       flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
       redirect_to attendances_edit_one_month_user_url(date: params[:date])
     end
   end
  end
  
  
  #◆残業申請全般
  def edit_overwork_request
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_overwork_request
    ActiveRecord::Base.transaction do
      @user = User.find(params[:user_id])
      @attendance = @user.attendances.find(params[:id])
      if @attendance.update_attributes(overwork_params)
         flash[:success] = "残業を申請しました。"
         redirect_to user_url(@user)
      else
        flash[:success] = "出勤時間が入力されていません。"
        redirect_to user_url(@user)
      end
    end
  end
  
  def notice_overwork_request
    @attendance = Attendance.find(params[:id])
    #@notice_users = User.where(id: Attendance.where.not(scheduled_end_time: nil).select(:user_id))
    @attendance_notices =  Attendance.where(overwork_confirmation: @user.name, overwork_confirmation_status: "申請中").group_by(&:user_id)
  end
  
  def approval_overwork_request
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      o1 = 0
      o2 = 0
      o3 = 0
      notice_overwork_params.each do |id, item|
        if item[:overwork_confirmation_status].present?
          if (item[:approval_check] == "1") && ((item[:overwork_confirmation_status] == "なし") || (item[:overwork_confirmation_status] == "承認") || (item[:overwork_confirmation_status] == "否認"))
            attendance = Attendance.find(id)
            user = User.find(attendance.user_id)
            if item[:overwork_confirmation_status] == "なし"
              o1 += 1
              item[:scheduled_end_time] = nil
              item[:next_day] = nil
              item[:business_processing_content] = nil
              item[:overwork_confirmation] = nil
            elsif item[:overwork_confirmation_status] == "承認"
              o2 += 1
            elsif item[:overwork_confirmation_status] == "否認"
              o3 += 1
            end
            attendance.update_attributes!(item)
          end
        end
      end
      flash[:success] = "残業申請を#{o1}件なし、#{o2}件承認、#{o3}を否認しました"
      redirect_to user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to attendances_notice_overwork_request_user_path(@user,item)
  end
  
  
  #◆月次申請全般
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
  
  def notice_monthly
    @attendance = Attendance.find(params[:id])
    @attendance_notices =  Attendance.where(monthly_confirmation: @user.name, monthly_confirmation_status: "申請中").group_by(&:user_id)
  end

  def approval_monthly
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      m1 = 0
      m2 = 0
      m3 = 0
      notice_monthly_params.each do |id, item|
        if item[:monthly_confirmation_status].present?
          if (item[:approval_check] == "1") && ((item[:monthly_confirmation_status] == "なし") || (item[:monthly_confirmation_status] == "承認済") || (item[:monthly_confirmation_status] == "否認"))
            attendance = Attendance.find(id)
            user = User.find(attendance.user_id)
            if item[:monthly_confirmation_status] == "なし"
              m1 += 1
              item[:scheduled_end_time] = nil
              item[:next_day] = nil
              item[:business_processing_content] = nil
              item[:monthly_confirmation] = nil
            elsif item[:monthly_confirmation_status] == "承認済"
              m2 += 1
            elsif item[:monthly_confirmation_status] == "否認"
              m3 += 1
            end
            attendance.update_attributes!(item)
          end
        end
      end
      flash[:success] = "月次申請を#{m1}件なし、#{m2}件承認、#{m3}を否認しました"
      redirect_to user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to attendances_approval_monthly_user_path(@user,item)
  end

  
  def attendance_edit_log
  end

  private

    # 1ヶ月勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note])[:attendances]
    end
    
    def monthly_params
      params.require(:attendance).permit(:update_monthly_day,:monthly_confirmation, :monthly_confirmation_status)
    end

    # 残業申請パラムス
    def overwork_params
      params.require(:attendance).permit(:scheduled_end_time, :next_day, :business_processing_content, :overwork_confirmation, :overwork_confirmation_status)
    end
    
    def notice_overwork_params
      params.require(:user).permit(attendances: [:overwork_confirmation_status, :approval_check])[:attendances]
    end

    def notice_monthly_params
      params.require(:user).permit(attendances: [:monthly_confirmation_status, :approval_check])[:attendances]
    end


    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end
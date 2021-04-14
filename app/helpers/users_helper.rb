module UsersHelper

  # 勤怠基本情報を指定のフォーマットで返します。  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
  def overtime_info(scheduled_end_time, designated_work_end_time, next_day)
      unless next_day == true
        format("%.2f", (((scheduled_end_time.hour * 60) - designated_work_end_time.hour * 60) / 60))
      else
        format("%.2f", (((scheduled_end_time.hour * 60) - designated_work_end_time.hour * 60) / 60) + 24)
    end
  end
end
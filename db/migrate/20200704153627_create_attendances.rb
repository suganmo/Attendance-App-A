class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.date :update_monthly_day
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :scheduled_end_time
      t.boolean :next_day, default: false
      t.boolean :approval_check, default: false
      t.string :business_processing_content
      t.string :application
      t.string :note
      t.string :monthly_confirmation
      t.string :monthly_confirmation_status
      t.string :month_confirmation
      t.string :month_confirmation_status
      t.string :overwork_confirmation
      t.string :overwork_confirmation_status
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

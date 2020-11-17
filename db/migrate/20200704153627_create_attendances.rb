class CreateAttendances < ActiveRecord::Migration[5.1]
  def change
    create_table :attendances do |t|
      t.date :worked_on
      t.datetime :started_at
      t.datetime :finished_at
      t.datetime :scheduled_end_time
      t.string :business_processing_content
      t.string :application
      t.string :note
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end

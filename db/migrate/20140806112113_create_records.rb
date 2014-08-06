class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :text
      t.string :url
      t.datetime :end_date
      t.timestamps
    end
  end
end

class AddSaltedToRecords < ActiveRecord::Migration
  def change
    add_column :records, :salted, :boolean
  end
end

class Record < ActiveRecord::Base
  validates :text, :url, :end_date, presence: true
  validates :url, format: { with: /[a-z0-9]{40}/, message: 'Wrong format of url !!' }
end

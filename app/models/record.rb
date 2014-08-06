class Record < ActiveRecord::Base
  validates  :text, :url, :end_date, presence: true
  validates  :url, format: { with: /[A-Za-z0-9]{32}/, message: "Wrong format of short url !!" }
end

class OtprecController < ApplicationController
  def index
  end

  def create
    @record   = Record.new

    text      = params['myform']['text']
    delay     = params[:store_days].to_i
    url       = Digest::SHA1.hexdigest("#{Time.now}#{([*('A'..'Z'),*('a'..'z'),*('0'..'9')]-%w(0 1 I O)).sample(32).join}")

    @record.text      = Base64.encode64(text)
    @record.url       = url
    @record.end_date  = delay.days.from_now
  
    if @record.save
      original_url = request.original_url
      url_parts = original_url.split('/')[0...-1]
      new_url = url_parts.join('/')+'/'+url
      @msg = new_url
    else
      @msg = "Oops, something goes wrong..."
    end
  end

  def show
    url = params[:url]
    record = Record.find_by! url: url
    if record && record.end_date > Time.now
      @msg = Base64.decode64(record.text)
      record.destroy
    else
      record.destroy
      flash[:error] = "Message wasn't found" 
      redirect_to root_url
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Message wasn't found" 
      redirect_to root_url
  end
end

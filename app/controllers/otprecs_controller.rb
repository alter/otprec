class OtprecsController < ApplicationController

  def index
  end

  def create
    @record   = Record.new

    text      = params['text']
    delay     = params['store_days'].to_i
    id        = Digest::SHA256.hexdigest("#{Time.now}#{([*('A'..'Z'), *('a'..'z'), *('0'..'9')] - %w(0 1 I O)).sample(32).join}")

    @record.text      = text
    @record.url       = id
    @record.end_date  = delay.days.from_now

    if @record.save
     # original_url = request.original_url
     # url_parts = original_url.split('/')[0...-1]
      @msg = "#{otprecs_url}/#{id}"
    else
      flash[:error] = 'Unable to save message, please try again without later'
      redirect_to root_url
    end
  end

  def show
    url = params[:id]
    if params.key?('myform')
      passphrase = params['myform']['passphrase']
    end
    passphrase = ENV['SECRET_KEY_BASE'] if passphrase.nil? || passphrase.empty?

    record = Record.find_by! url: url
    if record && record.end_date > Time.now
        @msg = record.text
    else
      record.destroy
      flash[:error] = "Message was removed because it's too old"
      redirect_to root_url
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Message wasn't found"
      redirect_to root_url
  end

  def destroy
    url = params[:id]
    record = Record.find_by! url: url
    record.destroy
  end
end

class OtprecController < ApplicationController
  def index
  end

  def create
    @record   = Record.new

    text      = params['myform']['text']
    delay     = params[:store_days].to_i
    salt      = params['myform']['salt']
    url       = Digest::SHA1.hexdigest("#{Time.now}#{([*('A'..'Z'),*('a'..'z'),*('0'..'9')]-%w(0 1 I O)).sample(32).join}")
  
    puts "SALT_raw is #{salt.inspect}"

    salt = ENV["SECRET_KEY_BASE"] if salt.nil? || salt.empty?
    if salt.nil?
      @msg='Admin have to use SECRET_KEY_BASE variable'
      return 
    end

    puts "SALT1 is #{salt}"

    begin
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.encrypt
      cipher.key = Digest::SHA2.digest(salt.chomp)
      encrypted = cipher.update(text)
      encrypted << cipher.final
      encrypted = Base64.encode64(encrypted)
    rescue OpenSSL::CipherError => e
      @msg = "incorrect password"
    rescue Exception => e
      @msg = "unknown error"
    end
    @record.text      = encrypted
    @record.url       = url
    @record.end_date  = delay.days.from_now

    if @record.save
      original_url = request.original_url
      url_parts = original_url.split('/')[0...-1]
      new_url = url_parts.join('/')+'/'+url
      @msg = new_url
    else
      flash[:error] = "Unable to save your password, please try again without hacks" 
      redirect_to root_url
    end
  end

  def show
    url   = params[:url]
    salt  = params[:salt]
    salt = ENV["SECRET_KEY_BASE"] if salt.nil? || salt.empty?
    puts "SALT2 is #{salt}"

    record = Record.find_by! url: url
    if record && record.end_date > Time.now
      begin
        encrypted = Base64.decode64(record.text)
        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
        cipher.decrypt
        cipher.key = Digest::SHA2.digest(salt.chomp)
        text = cipher.update(encrypted)
        text << cipher.final 
        @msg = text
        record.destroy
      rescue OpenSSL::Cipher::CipherError => e
        @msg = "incorrect password"
      rescue Exception => e
        @msg = "unknown error"
      end
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

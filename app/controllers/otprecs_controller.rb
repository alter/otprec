class OtprecsController < ApplicationController
  def encrypt_text(passphrase, text)
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = Digest::SHA2.digest(passphrase.chomp)
    encrypted = cipher.update(text)
    encrypted << cipher.final
    encrypted = Base64.encode64(encrypted)
  end

  def decrypt_text(passphrase, text)
    encrypted = Base64.decode64(text)
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = Digest::SHA2.digest(passphrase.chomp)
    text = cipher.update(encrypted)
    text << cipher.final
  end

  def index
  end

  def create
    @record   = Record.new

    text      = params['myform']['text']
    delay     = params[:store_days].to_i
    passphrase      = params['myform']['passphrase']
    id        = Digest::SHA1.hexdigest("#{Time.now}#{([*('A'..'Z'), *('a'..'z'), *('0'..'9')] - %w(0 1 I O)).sample(32).join}")

    passphrase = ENV['SECRET_KEY_BASE'] if passphrase.nil? || passphrase.empty?
    if passphrase.nil?
      @msg = 'Admin have to use SECRET_KEY_BASE variable'
      return
    end

    begin
      encrypted = encrypt_text(passphrase, text)
    rescue OpenSSL::Cipher::CipherError => e
      @msg = 'Incorrect passphrase'
    rescue => e
      @msg = 'unknown error'
    end

    @record.text      = encrypted
    @record.url       = id
    @record.end_date  = delay.days.from_now

    if @record.save
      original_url = request.original_url
      url_parts = original_url.split('/')[0...-1]
      @msg = "#{otprecs_url}/#{id}"
    else
      flash[:error] = 'Unable to save your password, please try again without hacks'
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
      begin
        text = decrypt_text(passphrase, record.text)
        @msg = text
        record.destroy
      rescue OpenSSL::Cipher::CipherError => e
        redirect_to decrypt_otprec_url
      rescue => e
        @msg = 'unknown error'
      end
    else
      record.destroy
      flash[:error] = "Message was removed because it's too old"
      redirect_to root_url
    end
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Message wasn't found"
      redirect_to root_url
  end

  def decrypt
    @id = params[:id]
  end
end

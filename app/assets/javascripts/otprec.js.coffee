# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '.subclick', ->
  text = $('#myform_text').val()
  pass = $('#myform_passphrase').val()
  days = $('#store_days').val()
  encrypted = CryptoJS.AES.encrypt(text, pass)
  $.post '/otprecs', {
    text: encrypted.toString(CryptoJS.enc.utf8);
    store_days: days
  }, (data) ->
    $('body').html(data);
    return

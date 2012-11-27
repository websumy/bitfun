# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$(document).ready ->
  $('#type a:first').tab('show')


$('a[data-toggle="tab"]').on 'show', (e) =>
  $('.tab-content').find('input, textarea').attr('disabled', 'disabled')
  $('.tab-content ' + e.target.hash).find('input, textarea').removeAttr('disabled')
  return false
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


jQuery ->
  # Create a comment
  $list = $('.comment-list')
  $form = $list.find('.new_comment')
  .on 'ajax:beforeSend', (e, xhr, settings) ->
    $(this).find('textarea').addClass('uneditable-input').attr('disabled', 'disabled')
  .on 'ajax:success', (e, response, status, xhr) ->
    $this = $(this)
    $this.find('textarea').removeClass('uneditable-input').removeAttr('disabled', 'disabled').val('');

    if xhr.getResponseHeader('Content-Type').indexOf('javascript') == -1
      $(response).hide().appendTo($this.prev()).show('slow')

  $list
  .on 'ajax:beforeSend', '.close', ->
    $(this).closest('.comment').fadeTo('fast', 0.5)
  .on 'ajax:success', '.close', ->
    $(this).closest('.comment').hide('fast')
  .on 'ajax:error', '.close', ->
    $(this).closest('.comment').fadeTo('fast', 1)

  .on 'click', '.comment_for', (e) ->
    e.preventDefault()
    $this = $(this)
    return false unless $form.length
    $form.next(':hidden').show()
    $this.hide().before($form)
    $form.find('input[name*=parent_id]').val($this.data('id') || '')

  .on 'ajax:before', '.voting', ->
    $this = $(this)
    return false if $this.data('sending')
    $this.data('sending', true)

  .on 'ajax:success', '.voting', (e, response) ->
    $this = $(this)
    $this.find('.count-likes').val(response.like)
    $this.find('.count-dislikes').val(response.dislike)
    $this.find('.btn').removeClass('disabled').data('method', false)

    if response.vote
      $this.find('.btn').first().addClass('disabled').data('method', 'delete')
    else if response.vote == false
      $this.find('.btn').last().addClass('disabled').data('method', 'delete')

  .on 'ajax:complete', '.voting', ->
    $(this).data('sending', false)

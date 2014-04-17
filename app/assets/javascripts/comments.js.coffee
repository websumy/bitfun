# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


jQuery ->
  # Create a comment

  scrollToElement = ($target) ->
    $window = $(window)
    wb = $window.scrollTop() + $window.height()
    tb = $target.offset().top + $target.outerHeight()

    if tb + 10 > wb

      $('html, body').animate(
        scrollTop: tb - $window.height() + 10
        500
      );

  checkVotingScore = ($voting) ->
    if parseInt($voting.find('.vote_result').text()) < 0
      $voting.addClass 'red'
    else
      $voting.removeClass 'red'

  $list = $ '.comment-list'

  $list.find('.voting').each ->
    checkVotingScore $(this)

  $form = $list.find('.form_wrapper')
  .on 'ajax:beforeSend', (e, xhr, settings) ->
    $(this).find('textarea').attr('disabled', 'disabled')
  .on 'ajax:success', (e, response, status, xhr) ->
    $this = $(this)
    $this.find('textarea').removeAttr('disabled', 'disabled').val('');

    if xhr.getResponseHeader('Content-Type').indexOf('javascript') == -1
      $form.before($(response).hide())

  $list
  .on 'ajax:beforeSend', '.btn-close-sm', ->
    $(this).closest('.comment').fadeTo('fast', 0.5)
  .on 'ajax:success', '.btn-close-sm', (e, response) ->
    $(this).closest('.comment').hide('fast')
  .on 'ajax:error', '.btn-close-sm', ->
    $(this).closest('.comment').fadeTo('fast', 1)

  .on 'click', '.comment_for', (e) ->
    e.preventDefault()
    $this = $(this)
    return true unless $form.length
    $this.addClass('hidden')

    $into = $this.siblings('.info_list').last()
    $into = $this.closest('.info_list') unless $into.length

    return true unless $into.length

    $form.addClass('hidden').find('input[name*=parent_id]').val($this.data('id') || '')
    $into.append $form
    $list.find('.comment_for.hidden').not($this).removeClass('hidden')

    $form.removeClass 'hidden'
    scrollToElement $form

  .on 'ajax:before', '.voting', ->
    $this = $(this)
    return false if $this.data('sending')
    $this.data('sending', true)

  .on 'ajax:success', '.voting', (e, response) ->
    $this = $(this)
    $this.find('.vote_result').text(parseInt(response.score) || 0)
    $this.find('.btn-action').removeClass('orange').data('method', false)

    checkVotingScore $this

    if response.vote
      $this.find('.btn-action').first().addClass('orange').data('method', 'delete')
    else if response.vote == false
      $this.find('.btn-action').last().addClass('orange').data('method', 'delete')

  .on 'ajax:complete', '.voting', ->
    $(this).data('sending', false)

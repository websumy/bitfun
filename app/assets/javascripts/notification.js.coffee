$ ->
  marker = '.hidden_mark'
  $('.notification_list').on 'click', '.click_handler', (e) ->
    e.preventDefault
    $this = $ this
    $marker = $this.closest(marker)
    $group = $this.closest('.notification_group')

    $marker.addClass('hidden')
    $group.find('.hidden').not($marker).removeClass('hidden')
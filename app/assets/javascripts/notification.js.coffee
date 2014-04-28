$ ->
  marker = '.hidden_mark'
  $list = $('.notification_list').on 'click', '.click_handler', (e) ->
    e.preventDefault
    $this = $ this
    $marker = $this.closest(marker)
    $group = $this.closest('.notification_group')

    $marker.addClass('hidden')
    $group.find('.hidden').not($marker).removeClass('hidden')

  if ($list.length)
    $(window).endlessScroll
      fireOnce: true,
      fireDelay: false,
      intervalFrequency: 250,
      inflowPixels: 200,
      loader: '',
      ceaseFireOnEmpty: false,
      callback: () ->
        window.endlessScrolllLoading = true;
        url = $('input[name=next]').last().val()

        return false unless url

        $('<div id="loading"/>').insertAfter($list)
        $.ajax
          cache: false
          url: url
          complete: (data) ->
            return true unless (data.status == 200)

            $(window).data('endelessscroll').stopFiring() unless data.responseText.length
            window.endlessScrolllLoading = false
            $elements = $(data.responseText)

            $elements.initButtonTooltips()
            $elements.initTooltips()
            $elements.findAndFormatDateTime()
            $list.append($elements)
            $('#loading').remove()
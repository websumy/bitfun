$(function(){

    var $table = $('#rating_table');

    var resetOrder = function(){
        $('.table-rating').find('tbody tr').each(function(k){
            var $this = $(this);
            $this.find('.name span').text(k + 1 + ".");
            $this.addClass((k % 2 == 0) ? 'even' : 'odd');
            if (k < 3) $this.addClass('first-three');
        })
    };

    resetOrder();

    var ajax_reload = function(url, data){
        $table.after($('<div id="loading"/>'));
        $.ajax({
            type: 'GET',
            url: url,
            data: data,
            dataType: 'script',
            complete: function(data) {
                if (data.status == 200)
                {
                    $table.html(data.responseText);
                    resetOrder();
                    $(window).data('endelessscroll').resetFiring();
                    $('#loading').remove();
                }
            }
        });
    };

    $('#rating_dropdown').ddslick({
        onSelected: function(data){
            var selected_interval = data.selectedData.value;
            if ($('#last_interval').data('value') !=  selected_interval){
                ajax_reload($('#current_users_url').data('current'), { interval: selected_interval });
                $('#last_interval').data('value', selected_interval)
            }
        }
    });

    $table.on('click', '.table-rating thead a', function(e){
        e.preventDefault();
        ajax_reload($(this).attr('href'));
    });

    if($table.length){
        $(window).endlessScroll({
            fireOnce: true,
            fireDelay: false,
            intervalFrequency: 250,
            inflowPixels: 200,
            loader: '',
            ceaseFireOnEmpty: false,
            callback: function(i) {
                window.endlessScrolllLoading = true;
                var url = $('#current_users_url').data('url');
                $table.after($('<div id="loading"/>'))
                $.ajax({
                    type: 'GET',
                    url: url,
                    dataType: 'script',
                    complete: function(data) {
                        if (data.status == 200)
                        {
                            window.endlessScrolllLoading = false;
                            $('#current_users_url').data('url', url.replace('page=' + (i + 1), 'page=' + (i + 2)));
                            if (data.responseText.length == 0) $(window).data('endelessscroll').stopFiring();
                            var $newElems = $( data.responseText ).css({ opacity: 0 });
                            $table.find('tbody').append($newElems);
                            resetOrder();
                            $newElems.animate({ opacity: 1 });
                            $('#loading').remove();
                        }
                    }
                });

            }
        });
    }
})
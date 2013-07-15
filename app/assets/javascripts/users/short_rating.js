$(function(){
    var $table = $('#short-table-rating');

    var resetTopOrder = function(){
        if ($table.length){
            $table.find('tbody tr').each(function(k){
                var $this = $(this);
                $this.find('.number_cell').text(k + 1 + ".");
                $this.addClass((k % 2 == 0) ? 'even' : 'odd');
            })
        }
    };

    resetTopOrder();

    $('#top_rating_dropdown').ddslick({
        onSelected: function(data){
            var selected_interval = data.selectedData.value;
            if ($('#last_top_interval').data('value') !=  selected_interval){
                ajax_reload('/get_rating', { interval: selected_interval });
                $('#last_top_interval').data('value', selected_interval)
            }
        }
    });

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
                    resetTopOrder();
                    $table.initTooltips();
                    $('#loading').remove();
                }
            }
        });
    };
});


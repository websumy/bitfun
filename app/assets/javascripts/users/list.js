$(function(){
    $('.filter_time select').ddslick();
    //data['interval'] = $('#dropdown_select').data('ddslick').selectedData.value || 'year';

    $('.content').on('click', '.table-rating thead a', function(e){
        e.preventDefault();
        $this = $(this),
        $table = $('.table-rating');
        $table.after($('<div id="loading"/>'))
        $.ajax({
            type: 'GET',
            url: $this.attr('href'),
            data: { interval: 'all' },
            dataType: 'script',
            complete: function(data) {
                if (data.status == 200)
                {
                    $table.html(data.responseText);
                    // $(window).data('endelessscroll').resetFiring();
                    $('#loading').remove();
                }
            }
        });
    });

});
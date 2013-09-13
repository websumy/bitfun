$(function(){

    var $trends = $('#trends'),
        $more = $('#show_more_trends'),
        count = $trends.find('.trend_item').length,
        i = 0;

    var showTrends = function(){
        $trends.find('.trend_item:hidden').each(function(key, value){
            if ( key > 0 && key % 3 == 0) return false;
            $(value).fadeIn(500);
            i ++;
        });
        if ( i == count) $more.hide();
    };

    showTrends();

    $more.on('click', function(e){
        e.preventDefault();
        showTrends();
        $(window).scrollTop($trends.find('.trend_item:visible').last().offset().top);
    });

    $('.btn-fun-report').not('[data-auth]').fancybox({
        type: 'ajax',
        padding : 0
    });

    $(document).on('ajax:success', '#new_report', function(evt, data, status, xhr){
        $.fancybox.close();
        if (data.success){
            show_notice(data.notice)
        }
        else{
            show_notice(data.notice, 'error')
        }
    });
});
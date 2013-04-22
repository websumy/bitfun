$(function(){

    // Get data for filter

    var get_filter_data = function(){
        var data = { 'type' : [] };

        $('.filter_obj a.active').each(function(e){
            data['type'].push($(this).data('value'))
        });
        if (!data['type'].length) data['type'].push("unknown");

        data['interval'] = $('#dropdown_select').data('ddslick').selectedData.value || 'year';
        data['view'] = $('#switch_view').find('a.active').data('value') || 'list';

        return data;
    };

    // Post data

    var post_filter_data = function(data){
        var postData = $.extend({}, get_filter_data(), data),
            searchUrl = $('.main_layout').data('search') || '',
            wall = $('#wall');
        $.ajax({
            type: 'GET',
            url: searchUrl.length ? searchUrl  : '',
            data: postData,
            dataType: 'script',
            complete: function(data) {
                if (data.status == 200)
                {
                    var layout = $('.main_layout'),
                        sidebar = $('.sidebar');

                    wall.html(data.responseText);
                    wall.initTooltipster();
                    $(window).data('endelessscroll').resetFiring();

                    if (postData.view == 'box'){
                        layout.addClass('grid');
                        sidebar.hide();
                        wall.imagesLoaded(function(){
                            if (wall.data('masonry')) wall.masonry('reload');
                            else wall.masonry({ itemSelector : '.post_card', gutterWidth: 21 })
                        });
                    }
                    else{
                        if (wall.data('masonry')) wall.masonry('destroy');
                        layout.removeClass('grid');
                        sidebar.show()
                    }
                }
            }
        });
    };

    $(".filter_obj a").on("click", function(e){
        e.preventDefault();
        $(this).toggleClass('active');
        post_filter_data()
    });

    $('#dropdown_select').ddslick({
        onSelected: function(data){
            var selected_interval = data.selectedData.value;
            if ($('#last_interval').data('value') !=  selected_interval){
                post_filter_data();
                $('#last_interval').data('value', selected_interval)
            }
        }
    });

    $('.rating-sort select').ddslick({});

    $('#switch_view').switcher({
        onChange: function(e){ post_filter_data({ view: e.data('value') })}
    })
});
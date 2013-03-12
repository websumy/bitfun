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

//        var tags = get_tags();
//        if (tags) data["query"] = tags;
        return data;
    };

    // Post data

    var post_filter_data = function(data){
        var postData = $.extend({}, get_filter_data(), data);
        $.ajax({
            type: 'POST',
            url: '/',
            data: postData,
            dataType: 'script',
            complete: function(data) {
                if (data.status == 200) $('.post_wall').html(data.responseText);
                if (postData.view == 'box'){
                    $('.main_layout.grid .post_wall').masonry('reload');
                }
                else{
                    $('.sidebar').show();
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

    var get_tags = function(){
        var tags = $('.search_by_tags').tagit("tags");
        return (tags.length) ? $.map(tags, function(tag){ return tag.value; }) : false;
    };

    $('.search_block a').click(function(e){
        e.preventDefault();
        var data = get_tags();
        if (data) window.location.href = "/search?" + $.param({query:data});
    });

    $('.tumbler_switch').switcher({
        onChange: function(element){
            var cuurrentState = element.data('value');
            if (cuurrentState == 'box'){
                $('.main_layout').addClass('grid');
                $('.sidebar').hide();
            }
            else{
                $('.main_layout').removeClass('grid');
                $('.sidebar').show();
            }
            post_filter_data( { view: cuurrentState } )
       }
    })
});
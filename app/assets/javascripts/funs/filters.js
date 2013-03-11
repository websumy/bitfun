$(function(){

    // Get data for filter

    var get_sorting_data = function(){
        var data = {
            'type' : [],
            'view' : 'list',
            'interval' : 'year'
        };

        $('.filter_obj a.active').each(function(e){
            data['type'].push($(this).data('value'))
        });
        if (!data['type'].length)
            data['type'].push("unknown");

        data['interval'] = $('#dropdown_select').data('ddslick').selectedData.value;

//        $("div.btn-group[data-type]").each(function(e){
//            var $this = $(this);
//            var type = $this.data("type");
//            switch(type) {
//                case "view":
//                    data[type] = $this.find("button.active").data("value");
//                    break;
//                case "type":
//                    data[type] = [];
//                    $this.find("button.active").each(function(){
//                        data[type].push($(this).data("value"));
//                    });
//                    if (!data[type].length)
//                        data[type].push("unknown");
//                    break;
//                case "interval":
//                    data[type] = $this.find("button").data("value");
//                    break;
//            }
//        });

//        var tags = get_tags();
//        if (tags) data["query"] = tags;

        return data;
    };

    // Post data

    var post_sorting_data = function(){
        $.ajax({
            type: 'POST',
            url: '/',
            data: get_sorting_data(),
            dataType: 'script'
        });
    };

    $(".filter_obj a").on("click", function(e){
        e.preventDefault();
        $(this).toggleClass('active');
        post_sorting_data()
    });

    $('#dropdown_select').ddslick({
        onSelected: function(data){
            var selected_interval = data.selectedData.value;
            if ($('#last_interval').data('value') !=  selected_interval){
                post_sorting_data();
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
            console.log(element);
        }
    })
});
$(function(){

    // Get tags for autocomplete

    var cache = {};
    var autocomplete_tags = function( request, response ) {
        if (request.term in cache){
            response(cache[request.term]);
        } else {
            $.post("/get_tags", {tag: request.term}, function(data){
                cache[request.term] = data;
                response(data);
            }, "json");
        }
    };

    // Initialize tagit plugin

    $('.search_by_tags').tagit({tagSource: autocomplete_tags, minLength: 1, allowNewTags: true, maxTags: 10, triggerKeys:['enter', 'space', 'tab']});

    // Reset link

    $('.icon-close').click(function(){
        var $search = $('.search_by_tags');
        if ($search.tagit("tags").length){
            $search.tagit('reset');
        }
        else {
            $.CloseActiveDropdowns();
        }
    });

    $.fn.get_tags = function(){
        var tags = $(this).tagit("tags");
        return (tags.length) ? $.map(tags, function(tag){ return tag.value; }) : false;
    };

    $('.search_block a').click(function(e){
        e.preventDefault();
        var data = $('.search_by_tags').get_tags();
        if (data) window.location.href = "/search?" + $.param({query:data});
    });


    // Initialize main search
    $main_serch = $('.main_search_by_tags');

    $main_serch.tagit({tagSource: autocomplete_tags, minLength: 1, allowNewTags: true, maxTags: 10, triggerKeys:['enter', 'space', 'tab']});

    // Reset button

    $('#main_search_reset').click(function(){
        var $search = $main_serch
        if ($search.tagit("tags").length) $search.tagit('reset');
    });

    $('.tag_search').on('click', 'a.tags', function(e){
        e.preventDefault();
        $main_serch.tagit("add", { label: $(this).text() });
    });

    $('.search_block a.find').click(function(e){
        e.preventDefault();
        var data = $('.tag_search').get_tags();
        if (data) window.location.href = "/search?" + $.param({query:data});
    });



});
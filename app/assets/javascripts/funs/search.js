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

    $('.search_by_tags').tagit({tagSource: autocomplete_tags, minLength: 2, allowNewTags: false, maxTags: 5});

    // Reset link

    $('.icon-close').click(function(){
        $('.search_by_tags').tagit('reset');
    });

});
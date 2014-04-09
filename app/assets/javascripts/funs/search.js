$(function(){

    // Get tags for autocomplete

    var cache = {},
        autocomplete = function( request, response ) {
        if (request.term in cache){
            response(cache[request.term]);
        } else {
            $.post('/get_tags', {tag: request.term}, function(data){
                cache[request.term] = data;
                response(data);
            }, 'json');
        }
    };

    var tagItSelector = '.search_by_tags',
        tagItWrapperSelector = '.search_by_tags_wrapper';

    $(tagItSelector).each(function(){
        var $this = $(this),
            selected = $.trim($this.data('selected-tags')),
            options = {
                tagSource: autocomplete,
                minLength: 1,
                allowNewTags: true,
                maxTags: 10,
                triggerKeys: ['enter', 'space', 'tab'],
                initialTags: []
            };

        if (selected.length){
            $.each(selected.split(','), function(k,v){
                v = $.trim(v);
                if (v.length)
                    options.initialTags.push(v)
            })
        }

        $this.tagit(options);
    });

    var findSibTagIt = function(el){
        return $(el).closest(tagItWrapperSelector).find(tagItSelector);
    };

    $(tagItWrapperSelector).on('click', '.find', function(e){
        e.preventDefault();
        var $list = findSibTagIt(this);
        if ($list.length){
            var data = $list.tagit('tags');
            if ($.isArray(data) && data.length)
                window.location.href = "/search?query=" + $.map(data, function(tag){ return tag.value }).join(',');
        }
    }).on('click', '.reset_tags', function(e){
        e.preventDefault();
        var $list = findSibTagIt(this);
        if ($list.length == 0) return;

        if ($list.tagit('tags').length){
            $list.tagit('fill', []);
        } else if ($(this).closest(tagItWrapperSelector).hasClass('close_on_empty'))
            $.CloseActiveDropdowns();
    }).on('click', 'a.tags', function(e){
        e.preventDefault();
        var $list = findSibTagIt(this);
        if ($list.length)
            $list.tagit('add', $(this).text());
    });
});
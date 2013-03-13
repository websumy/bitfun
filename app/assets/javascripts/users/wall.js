$(function(){

    // Masonry initialize

    $('.feed_layout.grid .post_wall').imagesLoaded( function(){
        $('.feed_layout.grid .post_wall').masonry({
            itemSelector : '.post_card',
            gutterWidth: 20
        });
    });

    $('#user_switch_view').switcher({
        onChange: function(e){
            var currentState = e.data('value'),
                url = $('#user_switch_content').find('a.switch.active').attr('href');
            $.ajax({
                type: 'GET',
                url: url,
                data: { view: currentState },
                dataType: 'script',
                complete: function(data) {
                    if (data.status == 200)
                    {
                        var layout = $('.feed_layout'),
                            wall = $('.post_wall');

                        wall.html(data.responseText);

                        if (currentState == 'box'){
                            layout.addClass('grid');
                            if (wall.data('masonry')) wall.masonry('reload');
                            else wall.masonry({ itemSelector : '.post_card', gutterWidth: 20 })
                        }
                        else{
                            if (wall.data('masonry')) wall.masonry('destroy');
                            layout.removeClass('grid');
                        }
                    }
                }
            });
        }
    });
    $('#user_switch_content').switcher({
        onChange: function(e){
            var currentState = $('#user_switch_view').find('a.switch.active').data('value'),
                url = e.attr('href');
            $.ajax({
                type: 'GET',
                url: url,
                dataType: 'script',
                complete: function(data) {
                    if (data.status == 200)
                    {
                        var wall = $('.post_wall');
                        wall.html(data.responseText);
                        if (currentState == 'box'){
                            if (wall.data('masonry')) wall.masonry('reload');
                        }

                    }
                }
            });
        }
    });

});
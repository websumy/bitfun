$(function(){

    // Masonry initialize

    $('.feed_layout.grid .post_wall').imagesLoaded( function(){
        $('.feed_layout.grid .post_wall').masonry({
            itemSelector : '.post_card',
            gutterWidth: 20
        });
    });

    var layout = $('.feed_layout'),
        loading = $('<div id="ajax_loading"><div class="loading_wrapper"></div></div>');

    $('#user_switch_view').switcher({
        onChange: function(e){
            var currentState = e.data('value'),
                url = $('#user_switch_content').find('a.switch.active').attr('href');

            layout.after(loading);
            $.ajax({
                type: 'GET',
                url: url,
                data: { view: currentState },
                dataType: 'script',
                complete: function(data) {
                    if (data.status == 200)
                    {
                        var wall = $('.post_wall');

                        wall.html(data.responseText);
                        wall.initTooltipster();
                        $(window).data('endelessscroll').resetFiring();

                        if (currentState == 'box'){
                            layout.addClass('grid');
                            if (wall.data('masonry')) wall.masonry('reload');
                            else wall.masonry({ itemSelector : '.post_card', gutterWidth: 20 })
                        }
                        else{
                            if (wall.data('masonry')) wall.masonry('destroy');
                            layout.removeClass('grid');
                            FB.XFBML.parse();
                            twttr.widgets.load();
                        }
                        $('#ajax_loading').remove();
                    }
                }
            });
        }
    });
    $('#user_switch_content').switcher({
        onChange: function(e){
            var currentState = $('#user_switch_view').find('a.switch.active').data('value'),
                url = e.attr('href');

            layout.after(loading);
            $.ajax({
                type: 'GET',
                url: url,
                dataType: 'script',
                complete: function(data) {
                    if (data.status == 200)
                    {
                        var wall = $('.post_wall');
                        wall.html(data.responseText);
                        wall.initTooltipster();
                        $(window).data('endelessscroll').resetFiring();
                        if (currentState == 'box'){
                            if (wall.data('masonry')) wall.masonry('reload');
                        }
                        FB.XFBML.parse();
                        twttr.widgets.load();
                    }
                    $('#ajax_loading').remove();
                }
            });
        }
    });

});
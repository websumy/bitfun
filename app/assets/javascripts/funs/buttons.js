$(function(){

    // Initialize totipster on hover for repost and like button

    $.fn.initButtonTooltips = function(){
        $(this).find('.post_nav .like_box, .post_nav .repost_box').each(function(key, element){
            if ( ! $(element).data('tooltipsterContent'))
            {
                $(element).tooltipster({
                    interactive: true,
                    animation: 'fade',
                    theme: 'likes_theme',
                    content: '<div class="popover_content">Загружается...</div>',
                    functionBefore: function(origin, continueTooltip) {
                        continueTooltip();
                        var isLike = origin.hasClass('like_box') ? true : false;
                        var counter = parseInt(origin.parents('.post_nav').find("span." + (isLike ? 'lcnt' : 'rcnt')).text()) || 0;
                        var content =  '<div class="popover_content empty_po">' + (isLike ? 'Нет голосов' : 'Нет репостов') + '</div>';
                        if (counter) {
                            if (origin.data('ajax') !== 'cached') {
                                $.ajax({
                                    type: 'GET',
                                    url: origin.find('a.item').attr('href'),
                                    success: function(data) {
                                        var partial = Hogan.compile("<div class='popover_content'>{{#users}}<a href='{{user_path}}'><img src='{{avatar_path}}' alt='{{login}}'>{{/users}}</a></div><div class='popover_footer'>Всего {{likes}} чел.</div>");
                                        var template = partial.render({ likes: counter, users: data }, partial);
                                        if (data.length) content = template; //HoganTemplates['app/templates/like_tooltip'].render({ likes: counter, users: data });
                                        origin.tooltipster('update', content).data('ajax', 'cached');
                                    }
                                });
                            }
                        }
                        else {
                            origin.tooltipster('update', content).data('ajax', 'cached');
                        }
                    }
                });
            }
        });
    };
    var content = $(".load_buttons");

    content.initButtonTooltips();

    // Processing repost callback

    content.on('ajax:success', '.repost_box a.item',  function(evt, data, status, xhr) {
        if (data.success) {
            var $counter = $(this).parents('.post_nav').find("span.rcnt");
            var value = parseInt($counter.text()) || 0;
            $counter.text(value + 1);
            $(this).parent('.repost_box').addClass('active').data('ajax', 'recache')
        }
    });

    // Processing like callback

    content.on({
        click: function(e) {
            if ($(this).data("disabled") && !$(this).data("auth"))
                return false;
            $(this).data("disabled", true);
        },
        'ajax:success':  function(evt, data, status, xhr){
            var $this = $(this);
            $this.data("disabled", false);
            var $counter = $this.parents('.post_nav').find("span.lcnt");
            var value = parseInt($counter.text()) || 0;

            if (data.type == "like") {
                $counter.text(value + 1);
                $this.data('method', 'delete').parent('.like_box').toggleClass('active')
            } else if(data.type == "unlike") {
                $counter.text(value - 1);
                $this.data('method', 'post').parent('.like_box').toggleClass('active')
            }
            $this.parent('.like_box').data('ajax', 'recache')
        }
    }, ".like_box a.item");
});
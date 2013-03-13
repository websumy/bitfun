$(function(){

    // Initialize totipster on hover for repost and like button

    $.initTooltipster = function(){
        $('.post_nav .like_box, .post_nav .repost_box').tooltipster({
            interactive: true,
            animation: 'fade',
            theme: 'likes_theme',
            content: '<div class="popover_content">Загружается...</div>',
            functionBefore: function(origin, continueTooltip) {
                continueTooltip();
                var isLike = origin.hasClass('like_box') ? true : false;
                var counter = parseInt(origin.parents('.post_nav').find("span." + (isLike ? 'lcnt' : 'rcnt')).text()) || 0;
                var content =  '<div class="popover_content">' + (isLike ? 'Нет голосов' : 'Нет репостов') + '</div>';
                if (counter) {
                    if (origin.data('ajax') !== 'cached') {
                        $.ajax({
                            type: 'GET',
                            url: origin.find('a.item').attr('href'),
                            success: function(data) {
                                if (data.length) content = HoganTemplates['like_tooltip'].render({ likes: counter, users: data });
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

    $.initTooltipster();

    // Processing repost callback

    $(".post_wall").on('ajax:success', '.repost_box a.item',  function(evt, data, status, xhr) {
        if (data.success) {
            var $counter = $(this).parents('.post_nav').find("span.rcnt");
            var value = parseInt($counter.text()) || 0;
            $counter.text(value + 1);
            $(this).parent('.repost_box').addClass('active').data('ajax', 'recache')
        }
    });

    // Processing like callback

    $('.post_wall').on({
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
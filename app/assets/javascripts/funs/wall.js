$(function(){

    // Masonry initialize
    var $wall = $('#wall');

    if ($wall.closest('.grid').length){
        $wall.imagesLoaded( function(){
            $wall.masonry({
                itemSelector : '.post_card',
                gutterWidth: 21
            });
        });
    }

    $wall.on('click', 'a.share_link',  function(e){
        e.preventDefault();
        var $this = $(this),
            $like_box = $this.closest('.post_share').find('.like_box');

        if ($like_box.length){
            $like_box.fadeToggle(500);
            $this.find('span').toggleClass('show');
        }
        else{
            $.ajax({
                type: 'GET',
                url: $this.attr('href'),
                success: function(data) {
                    if (data.length){
                        var $like_box = $('<div/>').addClass('like_box').hide();
                        $this.closest('.share_link').after($like_box);
                        $like_box.html(data)
                        FB.XFBML.parse($like_box.get(0));
                        twttr.widgets.load($like_box.get(0));
                        $like_box.fadeIn(500);
                        $this.find('span').addClass('show');
                    }
                }
            });
        }
    });

    // Replace post image to gif or video

    $(document).on('click', '.post_object a', function(e){
        $this = $(this);
        if ( ! $this.closest('.grid').length){
            if ($this.data('gif')){
                e.preventDefault();
                var path = $this.children('img').attr("src"),
                    h = $this.parent('.post_object').height();
                var img = new Image();
                $(img).bind('load', function(){
                    var diff = Math.floor(img.height/img.width*500) - h;
                    diff < 0 ? $this.parent('.post_object').css('margin-bottom', parseInt($this.parent('.post_object').css('margin-bottom'))-diff) : $this.parent('.post_object').css('margin-bottom', -24)
                });
                img.src = $this.attr('data-gif');
                $this.children('img').attr("src", $this.attr('data-gif'));
                $this.attr('data-gif', path).toggleClass('po-gif');
            }
            if ($this.data('video')){
                e.preventDefault();
                var videoUrl = {
                        youtube: 'http://www.youtube.com/embed/',
                        vimeo: 'http://player.vimeo.com/video/'
                    },
                    videoData = $this.data('video').split('-'),
                    videoIFrame = $('<iframe />', {
                        frameborder: 0,
                        src: videoUrl[videoData[0]] + videoData[1] + '?wmode=opaque&autoplay=1',
                        width: 500+'px',
                        height: 320+'px',
                        webkitAllowFullScreen: '',
                        mozallowfullscreen: '',
                        allowFullScreen: ''
                    });
                $this.after(videoIFrame).remove()
            }
        }
    });

    // Initialize endlessScroll on window only if we on page #wall

    if ($wall.length){

        $(window).endlessScroll({
            fireOnce: true,
            fireDelay: false,
            intervalFrequency: 250,
            inflowPixels: 200,
            loader: '',
            ceaseFireOnEmpty: false,
            callback: function(i) {
                window.endlessScrolllLoading = true;
                var url = $('#next_url').data('url');
                if (url){
                    $wall.after($('<div id="loading"/>'))
                    $.ajax({
                        type: 'GET',
                        url: url,
                        dataType: 'script',
                        complete: function(data) {
                            if (data.status == 200)
                            {
                                $('#next_url').data('url', url.replace('page=' + (i + 1), 'page=' + (i + 2)));

                                if (data.responseText.length == 0) $(window).data('endelessscroll').stopFiring();
                                window.endlessScrolllLoading = false;
                                var $newElems = $( data.responseText ).css({ opacity: 0 });

                                $newElems.imagesLoaded(function(){
                                    $newElems.animate({ opacity: 1 }).initButtonTooltips();
                                    $newElems.initTooltips();
                                    if ($wall.data('masonry')) $wall.masonry( 'appended', $newElems, true );
                                    $wall.append($newElems);
                                });
                                $('#loading').remove();
                            }
                        }
                    });
                }

            }
        });

        $(document).on('ajax:success', '.btn-fun-delete', function(evt, data, status, xhr){
            var $this = $(this);
            if (data.success){
                $this.parent('.post_frame').fadeOut('slow', function(){
                    if ($wall.data('masonry')) $wall.masonry('remove', this).masonry('reload');
                    show_notice(data.notice);
                })
            }
        });
    }



});
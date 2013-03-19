$(function(){

    // Masonry initialize

    $('.main_layout.grid .post_wall').imagesLoaded( function(){
        $('.main_layout.grid .post_wall').masonry({
            itemSelector : '.post_card',
            gutterWidth: 21
        });
    });

    // Replace post image to gif

    $(document).on('click', '.post_object a[data-gif]', function(e){
        e.preventDefault();
        $this = $(this);
        $this.children('img').attr("src", $this.data('gif'));
        $this.removeAttr('data-gif')
    });

    // Replace post image to video

    $(document).on('click', '.post_object a[data-video]', function(e){
        e.preventDefault();
        $this = $(this);
        var videoUrl = {
            youtube: 'http://www.youtube.com/embed/',
            vimeo: 'http://player.vimeo.com/video/'
        };
        var videoData = $this.data('video').split('-');
        var videoIFrame = $('<iframe />', {
            frameborder: 0,
            src: videoUrl[videoData[0]] + videoData[1] + '?wmode=opaque&autoplay=1',
            width: 500+'px',
            height: 320+'px',
            webkitAllowFullScreen: '',
            mozallowfullscreen: '',
            allowFullScreen: ''
        });
        $this.after(videoIFrame).remove()
    });

    // using some custom options

    var loading = false;

    EndlessScroll.prototype.shouldBeFiring = function() {
        this.calculateScrollableCanvas();
        return this.isScrollable
            && (this.options.fireOnce === false || (this.options.fireOnce === true && this.fired !== true && !loading));
    };

    $(window).endlessScroll({
        fireOnce: true,
        fireDelay: false,
        inflowPixels: 300,
        ceaseFireOnEmpty: false,
        insertAfter: ".post_wall",
        callback: function(i) {
            loading = true;
            var url = $('#next_url').data('url');
            $.ajax({
                type: 'GET',
                url: url,
                dataType: 'script',
                complete: function(data) {
                    if (data.status == 200)
                    {
                        $('#next_url').data('url', url.replace('page=' + (i + 1), 'page=' + (i + 2)));

                        if (data.responseText.length == 0) $(window).data('endelessscroll').stopFiring();
                        loading = false;
                        var $newElems = $( data.responseText ).css({ opacity: 0 }),
                            $wall = $('.post_wall');

                        $newElems.imagesLoaded(function(){
                            $newElems.animate({ opacity: 1 }).initTooltipster();
                            if ($wall.data('masonry')) $wall.masonry( 'appended', $newElems, true );
                            $wall.append($newElems);
                        });

                    }
                }
            });

        }
    });

});
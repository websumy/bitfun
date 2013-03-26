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

    // Replace post image to gif or video

    $(document).on('click', '.post_object a', function(e){
        $this = $(this);
        if ( ! $this.closest('.grid').length){
            if ($this.data('gif')){
                e.preventDefault();
                $this.children('img').attr("src", $this.data('gif'));
                $this.data('gif', 0);
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

    var loading = false;

    EndlessScroll.prototype.shouldBeFiring = function() {
        this.calculateScrollableCanvas();
        return this.isScrollable
            && (this.options.fireOnce === false || (this.options.fireOnce === true && this.fired !== true && !loading));
    };

    // Initialize endlessScroll on window only if we on page #wall

    if ($wall.length){
        $(window).endlessScroll({
            fireOnce: true,
            fireDelay: false,
            inflowPixels: 200,
            ceaseFireOnEmpty: false,
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
                            var $newElems = $( data.responseText ).css({ opacity: 0 });

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
    }



});
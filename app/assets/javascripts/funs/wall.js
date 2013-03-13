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

});
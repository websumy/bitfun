$(function(){
    // Follow and unfollow buttons

    $(document).on('ajax:success', 'a.follow, a.unfollow', function(evt, data, status, xhr){
        if (data.notice){
            var $this = $(this);
            if ($this.hasClass('follow')){
                $this.removeClass('follow').addClass('unfollow').data('method', 'delete')
            }
            else{
                $this.removeClass('unfollow').addClass('follow').data('method', 'post')
            }
            show_notice(data.notice)
        }
    });
});
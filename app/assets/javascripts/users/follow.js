$(function(){
    // Follow and unfollow buttons

    $(document).on('ajax:success', 'a.btn-follow', function(evt, data, status, xhr){
        if (data.notice){
            var $this = $(this);
            if ($this.hasClass('active')){
                $this.removeClass('active').data('method', 'post').html('<i class="icon"></i> Подписаться')
            }
            else{
                $this.addClass('active').data('method', 'delete').html('<i class="icon"></i> Отписаться &nbsp')
            }
            show_notice(data.notice)
        }
    });
});
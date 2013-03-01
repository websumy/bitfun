$(function(){

    // Initialize fancybox for reg and auth form

    $('.sign_pop_up').fancybox({
        type: 'ajax',
        wrapCSS: 'sign_form',
        closeBtn: false,
        minHeight: 900,
        padding : 0
    });

    // Processing callback from

    $(document).on('ajax:success', '#signup, #signin', function(evt, data, status, xhr){
        if (data.success){
            window.location = data.redirect
        }
        else {
            $(this).find('.error-block').remove();
            $(this).prepend($('<div class="error-block">' + data.errors + '</div>'));
        }
    });
});
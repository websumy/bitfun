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

    $(document).on('ajax:success', '#signup, #signin, #recover_pass, #need_email', function(evt, data, status, xhr){
        if (data.success){
            window.location = data.redirect
        }
        else {
            $errors = $(this).find('.error-block');
            if ($errors.length) { $errors.fadeOut(); $errors.text(data.errors).fadeIn()}
            else $(this).prepend($('<div class="error-block">' + data.errors + '</div>').fadeIn());
        }
    });
});
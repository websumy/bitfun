$(function(){

    $(document).on('show', '.add_fun_form a[data-toggle="tab"]', function(e){
        $('.add_fun_form .tab_content').find('input, textarea').attr('disabled', 'disabled');
        $('.add_fun_form .tab_content ' + e.target.hash).find('input, textarea').removeAttr('disabled');
    });

    $(document).on('shown', '.add_fun_form a[data-toggle="tab"]', function(e){
        $('#new_fun').resetClientSideValidations();
    });

    $(document).on('ajax:success', '#new_fun, #edit_fun', function(evt, data, status, xhr){
        $.fancybox.close();
        if (data.success){
            if (data.path) window.location.href = data.path;
            else window.location.reload()
        }else{
            show_notice(data.notice, 'error')
        }
    });

    $(document).on('ajax:beforeSend, submit', '#new_fun, #edit_fun, #new_report', function(){
        $('.add_fun_form').append($('<div class="__ajax"></div>'));
    });

    $(document).on('changed', '#upload_image_botton', function(){
        $('#fun_content_attributes_remote_file_url').val('');
        $(this).closest('.control-row').find(".error-block").remove();
        $('#new_fun').resetClientSideValidations();
    });

});
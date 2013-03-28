$(function(){

    // Initialize fancybox for add box

    $('#link_new_fun').not('[data-auth]').fancybox({
        type: 'ajax',
        padding : 0
    });

    $(document).on('show', '.add_fun_form a[data-toggle="tab"]', function(e){
        $('.add_fun_form .tab_content').find('input, textarea').attr('disabled', 'disabled');
        $('.add_fun_form .tab_content ' + e.target.hash).find('input, textarea').removeAttr('disabled');
    });

    $(document).on('shown', '.add_fun_form a[data-toggle="tab"]', function(e){
        $('#new_fun').resetClientSideValidations();
    });

    $(document).on('ajax:success', '#new_fun', function(evt, data, status, xhr){
        $.fancybox.close();
        if (data.success){
            show_notice(data.notice)
        }
        else{
            show_notice(data.notice)
        }
    });

    $(document).on('changed', '[data-provides="fileupload"]', function(){
        $('#fun_content_attributes_remote_file_url').val('');
        $('#new_fun').resetClientSideValidations();
    });

});
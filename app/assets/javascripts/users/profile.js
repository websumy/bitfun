$(function () {

    var $span = $('#change_photo'),
        $progress = $('.progress'),
        $bar = $progress.find('.bar'),
        $avatars = $('.photo_box img, .avatar_wrapper img');

    $span.on('click', function(e){
        if ($(this).is('.disabled'))
            e.preventDefault()
    });

    'use strict';

    $('#avatarupload').fileupload({
        autoUpload: true,
        maxFileSize: 2000000,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        singleFileUploads: false,

        add: function (e, data) {
            $span.data('value', $span.find('span').text());
            $span.addClass('disabled').find('span').text('Идет загрузка...');
            data.submit();
        },

        done: function(e, data) {
            $avatars.attr('src', data.result.thumb_url);
        },
        failed: function(e, data) {
            var msg = 'К сожалению, не удалось загрузить файл.';
            $.each(data.files, function (index, file) {
                if (file.error === 'maxFileSize') {
                    msg = 'Размер файла больше допустимого. Пожалуйста, загрузите файл меньшего размера.'
                }
                else if (file.error === 'acceptFileTypes') {
                    msg = 'Неверный тип файла. Пожалуйста, выберите правильный файл.'
                }
                else if (file.error === 'minFileSize') {
                    msg =  'Не удается загрузить пустой файл.'
                }
            });
            show_notice(msg, 'error');
        },
        progress: function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $progress.show();
            $bar.css(
                'width',
                progress + '%'
            );
        },
        always: function(e, data){
            $progress.hide();
            $bar.css('width','0%');
            $span.removeClass('disabled').find('span').text($span.data('value') || 'Изменить фото');
        }
    });

    $('.photo_settings').on(
        'ajax:success', function(evt, data, status, xhr){
        if (data.success)
            $avatars.attr('src', data.url);
    });

    $('#user_setting_attributes_sex_male').parents('.controls').find('label').each(function(k, l){$(l).addClass('inline')})

    var tabs = $('#change_edit_profile');

    function setState(){
        var hash = window.location.hash.substr(1);

        if (! tabs.find('a.switch.active').length) {
            if (hash.length) tabs.find('a.switch[data-tab='+ hash +']').addClass('active');
            else tabs.find('a.switch').first().addClass('active');
        }

        var currentState = tabs.find('a.switch.active').data('tab'),
            secondState = tabs.find('a.switch').not('.active').data('tab');

        if (currentState == 'settings') $('#avatarupload').hide();
        else $('#avatarupload').show();

       window.location.hash = currentState;

        $('#user_' + currentState).show().find('input, textarea').removeAttr('disabled');
        $('#user_' + secondState).hide().find('input, textarea').attr('disabled', 'disabled');
    }

    if (tabs.length) setState();

    tabs.switcher({
        onChange: function(e){
            setState();
            $('#edit_user').resetClientSideValidations();
        }
    });
});
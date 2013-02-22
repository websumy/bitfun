$(function () {

    $('.change_photo').on('click', function(e){
        if ($(this).is('.disabled'))
            e.preventDefault()
    });

    var $span = $('.change_photo');
    var $progress = $('.progress');
    var $bar = $progress.find('.bar');

    'use strict';

    $('#avatarupload').fileupload({
        autoUpload: true,
        maxFileSize: 1000000,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        singleFileUploads: false,

        add: function (e, data) {
            $span.data('value', $span.find('span').text());
            $span.addClass('disabled').find('span').text('Идет загрузка...');
            data.submit();
        },

        done: function(e, data) {
            $('.photo_box img, .avatar_wrapper img').attr('src', data.result.thumb_url);
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
});
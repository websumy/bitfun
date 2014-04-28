//= require jquery
//= require jquery_ujs
//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.autocomplete
//= require jquery.ui.draggable
//= require jquery-fileupload/jquery.iframe-transport
//= require jquery-fileupload/jquery.fileupload
//= require jquery-fileupload/jquery.fileupload-ui
//= require jquery-fileupload/locale
//= require source/bootstrap-tab
//= require rails.validations
//= require hogan.js
//= require moment
//= require moment/ru
//= require_tree .

$(function(){

    function BackToTop () {
        var backToTop = $('<a>', { id: 'back-to-top', href: '#top' });
        var icon = $('<i>');

        backToTop.appendTo ('body');
        icon.appendTo (backToTop);

        backToTop.hide();

        $(window).scroll(function () {
            if ($(this).scrollTop() > 150) {
                backToTop.fadeIn ();
            } else {
                backToTop.fadeOut ();
            }
        });

        backToTop.click (function (e) {
            e.preventDefault ();

            $('body, html').animate({
                scrollTop: 0
            }, 600);
        });
    }

    BackToTop();

    $("input.date_picker").datepicker({format:"yyyy-mm-dd"});

    $.FadeDropdown = function($e){
        $e.toggleClass('active');
        $($e.data('dropdown')).fadeToggle('fast');
    };

    $.CloseActiveDropdowns = function(){
        $('.active[data-dropdown]').each(function(){
            $.FadeDropdown($(this));
        });
    };

    $.fn.initTooltips = function(){
        $(this).find('[rel~="tooltip"]').tooltipster({
            theme: 'tooltips_theme',
            offsetY: -5
        });
    }

    $(document).initTooltips();

    $(document).on('click', '[data-dropdown]', function(e){
        e.preventDefault();
        if( ! $(this).hasClass('active')) $.CloseActiveDropdowns();
        $.FadeDropdown($(this));
    });

    $(document).on('click', function(e){
        var $this = $(e.target);
        if (! $this.parents('.main_panel, .tagit-choice').length && ! $this.data('dropdown')) $.CloseActiveDropdowns();
    });


    $(document).on('ajax:success', '.follow_parent a:visible', function(evt, data, status, xhr){
        if (data.notice){
            $(this).hide().siblings('a').show().css('display', 'inline-block');
            show_notice(data.notice)
        }
    });

//    //STICKY PROFILE
//    var offset = $(".sticky_profile").offset();
//    var topPadding = 200;
//    $(window).scroll(function() {
//
//        if ($(window).scrollTop() > (offset.top  - 200)) {
//            $(".sticky_profile").stop().animate({
//                marginTop: $(window).scrollTop() - offset.top + topPadding
//
//            }, 1000);
//        }
//        else {
//            $(".sticky_profile").stop().animate({
//                marginTop: 0
//            });
//        }
//    });

    $(document).on('click', 'a[rel=submit]', function(e){
        e.preventDefault();
        $(this).data('form') ? $($(this).data('form')).submit() : $(this).parents('form').submit()
    });

    $(document).on('click', 'a[data-disabled]', function(e){
        e.preventDefault();
    });

    $(document).on('click', 'a.cancel', function(e){
        e.preventDefault();
        $.fancybox.close()
    });

    var showAuthRequire = function(){
        show_notice('<a href="/users/sign_in" class="sign_pop_up">Авторизируйтесь</a> или <a href="/users/sign_up" class="sign_pop_up">зарегистрируйтесь</a>, чтобы можно было выполнять это действие.', 'error');
    };

    $(document).on('click', 'a[data-auth]', function(e){
        e.preventDefault();
        showAuthRequire();
    });



    $.rails.allowAction = function(element){
        if ( element.data('auth')){
            showAuthRequire();
            return false;
        }
        if ( ! element.attr('data-confirm')) return true;

        show_notice(element.data('confirm'), 'confirm', {
            buttons: [
                { addClass: 'btn btn-danger', text: 'Отменить', onClick: function($noty) {
                    $noty.close();
                }
                },
                { addClass: 'btn btn-primary', text: 'Подтвердить', onClick: function($noty) {
                    $noty.close();
                    element.removeAttr('data-confirm');
                    element.trigger('click.rails');
                }
                }

            ]
        });
        return false
    };

    // Initialize fancybox for add box

    $('.fancybox_ajax').not('[data-auth]').fancybox({
        type: 'ajax',
        padding : 0,
        helpers:  {
            overlay: {
                locked: false
            }
        }
    });

    $.fn.findAndFormatDateTime = function(){
        $(this).find('.date-time-format').datetimeformat({
            onComplete: function(element, object){
                element.tooltipster({
                    theme: 'tooltips_theme',
                    offsetY: -5,
                    content: object.moment.format('YYYY-MM-DD HH:mm')
                });
            }
        });
    };

    $(document).findAndFormatDateTime();
});

function show_notice(text, type, options) {
    var type = type || 'success',
        defaults = {
            text: text,
            type: type,
            dismissQueue: true,
            layout: 'top',
            theme: 'defaultTheme',
            timeout: 3000
        },
        noty_options = $.extend({}, defaults, options);

    noty(noty_options);
}

ClientSideValidations.formBuilders['SimpleForm::FormBuilder'] = {
    add: function(element, settings, message) {
        if (element.data('valid') !== false) {
            var wrapper = element.closest(settings.wrapper_tag);
            if (element.is('#fun_content_attributes_remote_file_url')) wrapper = wrapper.closest('.control-row'); // use only for add_fun form
            element.addClass('error');
            var errorElement = $('<' + settings.error_tag + ' class="' + settings.error_class + '">' + message + '</' + settings.error_tag + '>');
            wrapper.append(errorElement);
        } else {
            element.parent().find(settings.error_tag + '.' + settings.error_class).text(message);
        }
    },
    remove: function(element, settings) {
        var wrapper = element.parent(settings.wrapper_tag);
        element.removeClass('error');
        if (element.is('#fun_content_attributes_remote_file_url')) wrapper = wrapper.closest('.control-row');  // use only for add_fun form
        wrapper.find(settings.error_tag + '.' + settings.error_class).remove();
    }
};

ClientSideValidations.formBuilders['NestedForm::SimpleBuilder'] = ClientSideValidations.formBuilders['SimpleForm::FormBuilder'];

ClientSideValidations.callbacks.element.pass = function(element, callback, eventData) {
  callback();
  if(element.is('#fun_content_attributes_remote_file_url') && element.val()){
      $('#upload_image_botton').inputfileupload('clear');
  }
};

window.endlessScrolllLoading = false;

EndlessScroll.prototype.shouldBeFiring = function() {
    this.calculateScrollableCanvas();
    return this.isScrollable
        && (this.options.fireOnce === false || (this.options.fireOnce === true && this.fired !== true && !window.endlessScrolllLoading));
};

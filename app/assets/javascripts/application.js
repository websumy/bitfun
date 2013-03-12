//= require jquery
//= require jquery_ujs
//= require jquery.ui.core
//= require jquery.ui.widget
//= require jquery.ui.autocomplete
//= require jquery.ui.draggable
//= require source/bootstrap-tab
//= require rails.validations
//= require source/fileupload/jquery.fileupload
//= require_tree ./source/fileupload
//= require hogan.js
//= require_tree ./templates
//= require_tree .

$(function(){

    $("input.date_picker").datepicker({format:"yyyy-mm-dd"});

    // DROPDOWN SEARCH BLOCK
    var dropdown_search_link = $('[data-toggle="dropdown-search"]'),
        dropdown_search = $('.dropdown_search'),
        dropdown_profile = $('.dropdown_profile'),
        dropdown_profile_link = $('[data-toggle="dropdown-settings"]');

    dropdown_search_link.click(function(){
        if(dropdown_profile.is(':visible')){
            dropdown_profile.fadeOut('fast');
            dropdown_profile_link.parent().toggleClass('active');
        }
        $(this).parent().toggleClass('active');
        dropdown_search.fadeToggle('slow');
    });

    // DROPDOWN SEARCH BLOCK
    dropdown_profile_link.click(function(){
        if(dropdown_search.is(':visible')){
            dropdown_search.fadeOut('fast');
            dropdown_search_link.parent().toggleClass('active');
        }
        $(this).parent().toggleClass('active');
        dropdown_profile.fadeToggle('slow');
    });

    $('a[rel~="tooltip"]').tooltipster({
        theme: 'tooltips_theme',
        offsetY: -5
    });

    //STICKY PROFILE
    var offset = $(".sticky_profile").offset();
    var topPadding = 200;
    $(window).scroll(function() {

        if ($(window).scrollTop() > (offset.top  - 200)) {
            $(".sticky_profile").stop().animate({
                marginTop: $(window).scrollTop() - offset.top + topPadding

            }, 1000);
        }
        else {
            $(".sticky_profile").stop().animate({
                marginTop: 0
            });
        }
    });

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

    $(document).on('click', 'a[data-auth]', function(e){
        e.preventDefault();
        show_notice('Авторизируйтесь или зарегистрируйтесь, чтобы можно было выполнять это действие.', 'error');
    });

});

function show_notice(text, type) {
    type = type || 'success'
    var n = noty({
        text: text,
        type: type,
        dismissQueue: true,
        layout: 'top',
        theme: 'defaultTheme',
        timeout: 5000
    });
}

ClientSideValidations.formBuilders['SimpleForm::FormBuilder'] = {
    add: function(element, settings, message) {
        if (element.data('valid') !== false) {
            var wrapper = element.closest(settings.wrapper_tag);
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
        wrapper.find(settings.error_tag + '.' + settings.error_class).remove();
    }
};

ClientSideValidations.formBuilders['NestedForm::SimpleBuilder'] = ClientSideValidations.formBuilders['SimpleForm::FormBuilder'];

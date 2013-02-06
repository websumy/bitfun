// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require bootstrap-tab
//= require rails.validations
//= require_tree .

$(function(){

    var get_sorting_data = function(){
        var data = {
            'type' : [],
            'view' : 'list',
            'interval' : 'year'
        };

        $('.filter_obj a.active').each(function(e){
            data['type'].push($(this).data('value'))
        });
        if (!data['type'].length)
            data['type'].push("unknown");

//        $("div.btn-group[data-type]").each(function(e){
//            var $this = $(this);
//            var type = $this.data("type");
//            switch(type) {
//                case "view":
//                    data[type] = $this.find("button.active").data("value");
//                    break;
//                case "type":
//                    data[type] = [];
//                    $this.find("button.active").each(function(){
//                        data[type].push($(this).data("value"));
//                    });
//                    if (!data[type].length)
//                        data[type].push("unknown");
//                    break;
//                case "interval":
//                    data[type] = $this.find("button").data("value");
//                    break;
//            }
//        });

        var tags = get_tags();
        if (tags) data["query"] = tags;

        return data;
    };

    var post_sorting_data = function(data){
        $.ajax({
            type: 'POST',
            url: '/',
            data: data,
            dataType: 'script'
        });
    };

    $(".filter_obj a").on("click", function(e){
        e.preventDefault();
        $(this).toggleClass('active');
        post_sorting_data(get_sorting_data());
        console.log(get_sorting_data());
    });

    $("div.btn-group ul.dropdown-menu").on("click", "a", function(e){
        $("div.btn-group[data-type='interval'] button").text($(this).text() + " ").append($("<span>").addClass("caret")).data("value", $(this).data("value"));
        post_sorting_data(get_sorting_data());
    });

    $('#show_likes a, #show_reposts a').on('ajax:success',  function(evt, data, status, xhr){
        var $link = $(this);
        $.each(data, function(k, v){
            $link.after($("<img>").attr({
                "src": v.avatar.thumb.url,
                "class": "img-circle",
                "width": "30px"
            }));
        });
        $link.hide();
    });

    var cache = {};
    var autocomplete_tags = function( request, response ) {
        if (request.term in cache){
            response(cache[request.term]);
        } else {
            $.post("/get_tags", {tag: request.term}, function(data){
                cache[request.term] = data;
                response(data);
            }, "json");
        }
    };

    $('#tags').tagit({tagSource: autocomplete_tags, minLength: 2, allowNewTags: false, maxTags: 5});

    var get_tags = function(){
        var tags = $('#tags').tagit("tags");
        return (tags.length) ? $.map(tags, function(tag){ return tag.value; }) : false;
    };

    $('.search_tag button').click(function(e){
        var data = get_tags();
        if (data) window.location.href = "/search?" + $.param({query:data});
    });

    $("input.date_picker").datepicker({format:"yyyy-mm-dd"});

    $('.alert .close').on("click", function(e) {
        $(this).parent().fadeOut(3000);
    });

    var show_alert = function(message){
        $("#js-alert").alert().show().find("div").text(message);
        $(window).scrollTop(0);
        $('.alert .close').click();
    };

    $("#funs_list").on('ajax:success', 'a.repost',  function(evt, data, status, xhr) {
        if (data.type == "success") {
            var $span = $(this).find("span");
            var value = parseInt($span.text()) || 0;
            $span.text(value + 1).removeClass("badge-info").addClass("badge-success");
            $(this).attr('href', '#'); // need remove link or disabled
        } else {
            show_alert(data.message);
        }
    });

    $('#funs_list').on({
        click: function(e) {
            if ($(this).data("disabled"))
                return false;
            $(this).data("disabled", true);
        },
        'ajax:success':  function(evt, data, status, xhr){
            $this = $(this);
            $this.data("disabled", false);
            var $span = $this.find("span");
            var value = parseInt($span.eq(1).text()) || 0;
            if (data.type == "like") {
                $span.eq(0).text("Unlike fun");
                $span.eq(1).text(value + 1).removeClass("badge-info").addClass("badge-success");
                $this.data('method', 'delete')
            } else if(data.type == "unlike") {
                $span.eq(0).text("Like fun");
                $span.eq(1).text(value - 1).removeClass("badge-success").addClass("badge-info");
                $this.data('method', 'post')
            }
        }
    }, "a.like");

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

    $('.icon-close').click(function(){
        $(this).parents('.dropdown_search').fadeOut('fast');
        dropdown_search_link.parent().toggleClass('active');
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

    // ddSlick (dropdown select)
    $('.dropdown_select').ddslick({});


    // FOLLOW/UNFOLLOW
    $('.circle_follow_status a').bind('click', function(e){
        e.preventDefault();
        var status = $(this).attr('class');
        if(status == 'follow'){
            $(this).attr('class', 'unfollow').attr('title', 'Не хочу читать');
        }
        else if(status == 'unfollow'){
            $(this).attr('class', 'follow').attr('title', 'Читать');
        }
    });

    // SHOW/HIDE SHARE
    $('.share_link').bind('click', function(e){
        e.preventDefault();
        var $$ = $(this),
            span = $$.find('span'),
            share_list = $$.parents('.orange_box').next('ul');

        if(span.hasClass('hide')){
            span.attr('class', 'show');
            share_list.slideDown('fast');
        }
        else if(span.hasClass('show')){
            span.attr('class', 'hide');
            share_list.slideUp('fast');
        }
    });

    // BOOTSTRAP
//    $('.sidebar .nav_tabs a:first').tab('show');


    // TOGGLE VIEW
    $('.tumbler_switch .switch').click(function(e){
//        if(!$(this).parents('.tumbler_switch').hasClass('toggle_reload')){
        e.preventDefault();
        var $$ = $(this);
        if($$.hasClass('active')){
            return false;
        }
        else{
            var sib = $$.siblings('a'),
                slider = sib.find('.toggle_slider'),
                cwidth = $$.outerWidth(),
                swidth = sib.outerWidth();

            function changeClass(sib, cur){
                cur.toggleClass('active');
                sib.toggleClass('active');
            }
            //            changeClass(sib, $$);
            if($$.hasClass('hold_left')){
                slider.animate({left: -cwidth, width: cwidth}, 300, function(){changeClass(sib, $$);});
            }
            else if($$.hasClass('hold_right')){
                slider.animate({left: swidth, width: cwidth}, 300, function(){changeClass(sib, $$);});
            }

            slider.animate({left: 0, width: swidth});
        }
//        }
    });

    // MASONRY JS
    $('.main_layout.grid .post_wall').imagesLoaded( function(){
        $('.main_layout.grid .post_wall').masonry({
            itemSelector : '.post_card',
            gutterWidth: 21
        });
    });
    $('.feed_layout.grid .post_wall').imagesLoaded( function(){
        $('.feed_layout.grid .post_wall').masonry({
            itemSelector : '.post_card',
            gutterWidth: 20
        });
    });

    // TOOLTIPSTER
    $('.post_layout .like_box').tooltipster({
        interactive: true,
        animation: 'grow',
//        animation: 'fade',
//        animation: 'slide',
//        animation: 'fall',
//        animation: 'swing',
        theme: 'likes_theme',
        content: '<div class="popover_content">' +
            '<a href="#"><img src="/assets/default-avatar-30.jpg" alt="img" /></a> ' +
            '<a href="#"><img src="/assets/default-avatar-30.jpg" alt="img" /></a> ' +
            '<a href="#"><img src="/assets/default-avatar-30.jpg" alt="img" /></a> ' +
            '<a href="#"><img src="/assets/default-avatar-30.jpg" alt="img" /></a> ' +
            '<a href="#"><img src="/assets/default-avatar-30.jpg" alt="img" /></a> ' +
            '</div>' +
            '<div class="popover_footer">' +
            '<a href="#">... и еще 387 людям</a>' +
            '' +
            '</div>'
    });
    $('[rel="tooltip"]').tooltipster({
        theme: 'tooltips_theme',
        offsetY: -5
    });

    // FANCYBOX
    $('.modal_link').fancybox({
        padding : 0
    });
    $('.signUp').fancybox({
        wrapCSS: 'sign_form',
        closeBtn: false,
        padding : 0
    });

    // NOTY
    function generate(type, text) {
        var n = noty({
            text: text,
            type: type,
            dismissQueue: true,
            layout: 'top',
            theme: 'defaultTheme'
        });

    }

//    if($('.container').hasClass('profile_layout')){
//        generate('information', 'К сожалению ваша учетная запись не была обновлена из-за ошибки:<br>- Адрес электронной почты<br>- Имя пользователя');
//        generate('success', 'Ваша учетная запись была обновлена!');
//    }

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

});

ClientSideValidations.formBuilders['SimpleForm::FormBuilder'] = {
    add: function(element, settings, message) {
        if (element.data('valid') !== false) {
            var wrapper = element.closest(settings.wrapper_tag);
            wrapper.parent().addClass(settings.wrapper_error_class);
            var errorElement = $('<' + settings.error_tag + ' class="' + settings.error_class + '">' + message + '</' + settings.error_tag + '>');
            wrapper.append(errorElement);
        } else {
            element.parent().find(settings.error_tag + '.' + settings.error_class).text(message);
        }
    },
    remove: function(element, settings) {
        var wrapper = element.closest(settings.wrapper_tag + '.' + settings.wrapper_error_class);
        wrapper.removeClass(settings.wrapper_error_class);
        var errorElement = wrapper.find(settings.error_tag + '.' + settings.error_class);
        errorElement.remove();
    }
};

ClientSideValidations.formBuilders['NestedForm::SimpleBuilder'] = ClientSideValidations.formBuilders['SimpleForm::FormBuilder'];

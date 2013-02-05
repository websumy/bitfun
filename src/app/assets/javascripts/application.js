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
//= require jquery.noty.js
//= require noty_position.js
//= require noty_theme.js
//= require_tree .

$(document).ready(function(){

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
    // FILTER OBJECT(active)
    $('.filter_obj a').click(function(){
        if($(this).hasClass('active')){
            $(this).removeClass('active');
        }
        else{
            $(this).addClass('active');
        }
    });

    // MENU(active)
    $('.menu a').click(function(e){
        e.preventDefault();
        var parent = $(this).parents('.item_wrapper');
        parent.siblings().removeClass('active');
        parent.addClass('active');
    });

    // DROPDOWN SELECT(dropkick)
    $('.dropdown_select').dropkick();


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
  	console.log('html: '+n.options.id);
    }
    if($('.container').hasClass('profile_layout')){
        generate('information', 'К сожалению ваша учетная запись не была обновлена из-за ошибки:<br>- Адрес электронной почты<br>- Имя пользователя');
        generate('success', 'Ваша учетная запись была обновлена!');
    }

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


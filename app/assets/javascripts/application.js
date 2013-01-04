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
//= require bootstrap
//= require rails.validations
//= require_tree .

$(function(){

    $('.like_button a').live("click", function(e){
        e.preventDefault();

        var link = $(this);
        $.ajax({
            url: link.attr("href"),
            beforeSend: function(xhr) {
                xhr.setRequestHeader("Accept", "text/javascript");
            },
            success:function(data){
                link.after(data);
                link.remove();
            },
            dataType: 'html'
        });

    });

    $("#sort").on("change", "select#interval, input:checkbox", function(){
        $(this).parents("form:first").submit();
    });

    $('#show_likes a').on('ajax:success',  function(evt, data, status, xhr){
        var $link = $(this);
        $.each(data, function(k, v){
            $link.after($("<img>").attr({
                "src": v.avatar.thumb.url,
                "class": "img-circle",
                "width": "50px"
            }));
        });
        $link.hide();
    });

    var cache = {};
    var get_tags = function( request, response ) {
        if (request.term in cache){
            response(cache[request.term]);
        } else {
            $.post("/get_tags", {tag: request.term}, function(data){
                cache[request.term] = data;
                response(data);
            }, "json");
        }
    };

    $('#tags').tagit({tagSource: get_tags, minLength: 2, allowNewTags: false, maxTags: 5});

    $('.search_tag button').click(function(e){
        var tags = $('#tags').tagit("tags");
        if (tags.length){
            var data =  $.map(tags, function(tag){ return tag.value; });
            if (data.length) window.location.href = "/search?" + $.param({query:data});
        }
    });

    $("input.date_picker").datepicker({format:"yyyy-mm-dd"});

    $('.alert .close').live("click", function(e) {
        $(this).parent().fadeOut(3000);
    });

    var show_alert = function(message){
        $("#js-alert").alert().show().find("div").text(message);
        $(window).scrollTop(0);
        $('.alert .close').click();
    };

    $('a.repost').on('ajax:success',  function(evt, data, status, xhr) {
        if (data.type == "success") {
            var $span = $(this).find("span");
            var value = parseInt($span.text()) || 0;
            $span.text(value + 1).removeClass("badge-info").addClass("badge-success");
            $(this).attr('href', '#');
        } else {
            show_alert(data.message);
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

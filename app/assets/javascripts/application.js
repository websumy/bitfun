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
//= require bootstrap-dropdown
//= require bootstrap-modal
//= require bootstrap-tab
//= require bootstrap-alert
//= require rails.validations
//= require_tree .

$(function(){

    var get_sorting_data = function(){
        var data = {};

        $("div.btn-group[data-type]").each(function(e){
            var $this = $(this);
            var type = $this.data("type");
            switch(type) {
                case "view":
                    data[type] = $this.find("button.active").data("value");
                    break;
                case "type":
                    data[type] = [];
                    $this.find("button.active").each(function(){
                        data[type].push($(this).data("value"));
                    });
                    if (!data[type].length)
                        data[type].push("unknown");
                    break;
                case "interval":
                    data[type] = $this.find("button").data("value");
                    break;
            }
        });

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

    $("div.btn-group").on("button-change", "button", function(e){
        post_sorting_data(get_sorting_data());
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

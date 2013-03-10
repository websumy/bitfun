/* ========================================================
 * Switcher.js v 1.0
 * Copyright 2013 Andrey Konoplenko
 * ======================================================== */

!function ($) {

    "use strict";

    var Switcher = function (element, options) {
        this.element = $(element),
        this.options = $.extend({}, $.fn.switcher.defaults, options);
    }

    Switcher.prototype = {

        constructor: Switcher

        , show: function () {
            var $this = this.element

            if ($this.hasClass('active')) return

            var sib = $this.siblings('a'),
                slider = sib.find('.toggle_slider'),
                cwidth = $this.outerWidth() || 0,
                swidth = sib.outerWidth() || 0,
                changeClass = function (sib, cur){
                    cur.toggleClass('active');
                    sib.toggleClass('active');
                };

            if ($this.hasClass('hold_left'))
                slider.animate({left: -cwidth, width: cwidth}, 300, function(){changeClass(sib, $this)});
            else
                slider.animate({left: swidth, width: cwidth}, 300, function(){changeClass(sib, $this)});

            slider.animate({left: 0, width: swidth});

            $this.trigger({type: 'shown'})

            this.options.onChange(this);

        }
    }

    var old = $.fn.switcher

    $.fn.switcher = function ( option ) {
        return this.each(function () {
            var $this = $(this)
                , data = $this.data('switcher')
            if (!data) $this.data('switcher', (data = new Switcher(this)))
            if (typeof option == 'string') data[option]()
        })
    }

    $.fn.switcher.defaults = {
        onChange: function(date) {
            console.log(12121212121);
        }
    };

    $.fn.switcher.Constructor = Switcher

    $.fn.switcher.noConflict = function () {
        $.fn.switcher = old
        return this
    }

    $(document).on('click.switcher.data-api', '[data-toggle="switcher"]', function (e) {
        e.preventDefault()
        $(this).switcher('show')
    })

}(window.jQuery);
/* ========================================================
 * Switcher.js v 1.0
 * Copyright 2013 Andrey Konoplenko
 * ======================================================== */

!function ($) {

    "use strict";

    var Switcher = function (element, options) {
        this.$element = $(element);
        this.options = $.extend({}, $.fn.switcher.defaults, options);
        this.$links = this.$element.find('a.switch');
        this.listen()
    };

    Switcher.prototype = {

        constructor: Switcher,

        listen: function () {
            this.$links.on('click.switcher', $.proxy(this.change, this))
        },

        change: function (e) {
            var $current = $(e.target).closest('a.switch');
            if ($current.hasClass('active')) return
            var sib = $current.siblings('a'),
                cwidth = +$current.outerWidth() || 0,
                swidth = +sib.outerWidth() || 0,
                animateCallback = function(){
                    $current.toggleClass('active');
                    sib.toggleClass('active');
                    if (typeof this.options.onChange == 'function') this.options.onChange($current)
                };
            sib.find('.toggle_slider').animate({left: ($current.hasClass('hold_left')) ? -cwidth : swidth, width: cwidth}, 300, $.proxy(animateCallback, this)).animate({left: 0, width: swidth})
        }
    };

    var old = $.fn.switcher;

    $.fn.switcher = function ( option ) {
        return this.each(function () {
            var $this = $(this),
                data = $this.data('switcher'),
                options = typeof option == 'object' && option;
            if (!data) $this.data('switcher', new Switcher(this, options))
        })
    };

    $.fn.switcher.defaults = {
        onChange: function() {}
    };

    $.fn.switcher.Constructor = Switcher;

    $.fn.switcher.noConflict = function () {
        $.fn.switcher = old;
        return this
    };

    $(document).on('click.switcher.data-api', '[data-toggle="switcher"]', function (e) {
        e.preventDefault();
        var $this = $(this);
        if ($this.data('switcher')) return
        $this.switcher($this.data());
        var $target = $(e.target).closest('a.switch');
        if ($target.length > 0) $target.trigger('click.switcher')
    })

}(window.jQuery);
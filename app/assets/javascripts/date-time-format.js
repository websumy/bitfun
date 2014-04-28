!function ($, moment) {

    "use strict"; // jshint ;_

    var settings = {
        datetime: false,
        refreshMillis: 20000,
        todayFormat: '[сегодня в] HH:mm',
        yesterdayFormat: '[вчера в] HH:mm',
        thisYearFormat: 'D MMM в HH:mm',
        defaultFormat: 'D MMM YYYY в HH:mm',
        innerSelector: false,
        onComplete: false
    };

    var DateTimeFormat = function (element, options) {
        options = typeof options == 'object' ? options : {};

        this.$element = $(element);
        this.options = $.extend({}, settings, typeof options == 'object' ? options : {});
        this.dateTimeStr = this.options.datetime || this.$element.data('iso8601');

        if ( ! (this.dateTimeStr && moment(this.dateTimeStr).isValid())) return;

        this.moment = moment(this.dateTimeStr);

        this.init();
    };

    DateTimeFormat.prototype = {

        init: function() {
            this.setText().startInterval();
            if ($.isFunction(this.options.onComplete))
                this.options.onComplete(this.$element, this)
        },

        setText: function(){
            if (this.options.innerSelector){
                this.$element.find(this.options.innerSelector).text(this.getMomentStr())
            }else{
                this.$element.text(this.getMomentStr())
            }
            return this;
        },

        startInterval: function() {
            if (this.options.refreshMillis > 0){
                if (this.isLessThenHour()){
                    if(!this.intervalId){
                        this.intervalId = setInterval($.proxy(this.refreshText, this), this.options.refreshMillis);
                    }
                }
            }
            return this
        },

        refreshText: function(){
            this.setText();

            if (this.intervalId && ! this.isLessThenHour()){
                clearInterval(this.intervalId);
            }
        },

        getMomentStr: function () {
            if (this.isLessThenHour()) return this.moment.fromNow();
            if (this.isToday()) return this.moment.format(this.options.todayFormat);
            if (this.isYesterday()) return this.moment.format(this.options.yesterdayFormat);
            if (this.isThisYear()) return this.moment.format(this.options.thisYearFormat);

            return this.moment.format(this.options.defaultFormat);
        },
        isLessThenHour: function () {
            return this.moment.isAfter(moment().subtract(1, 'hour'))
        },
        isToday: function () {
            return this.moment.isSame(moment(), 'day')
        },
        isYesterday: function () {
            return this.moment.isSame(moment().subtract(1, 'day'), 'day');
        },
        isThisYear: function () {
            return this.moment.isSame(moment(), 'year')
        }
    };

    /* DateTimeFormat PLUGIN DEFINITION
     * =========================== */

    $.fn.datetimeformat = function (options) {
        return this.each(function () {
            var $this = $(this), data = $this.data('datetimeformat');
            if (!data) $this.data('datetimeformat', (new DateTimeFormat(this, options)))
            if (typeof options == 'string') data[options]()
        })
    };

    $.fn.datetimeformat.Constructor = DateTimeFormat;
}(window.jQuery, moment);

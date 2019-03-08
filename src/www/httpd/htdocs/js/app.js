var APP = (function () {

    function init() {
        APP.global.init();
    }

    return {
        init: init
    };

})(jQuery);

$(function () {
    APP.init();
});

var APP = APP || {};

APP.reboot = (function ($) {

    var timeoutVar;

    function init() {
        rebootCamera();
    }

    function rebootCamera() {
        $.ajax({
            type: "GET",
            url: 'cgi-bin/reboot.sh',
            dataType: "json",
            error: function(response) {
                console.log('error', response);
            }
        });
    }

    return {
        init: init
    };

})(jQuery);

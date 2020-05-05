var APP = APP || {};

APP.ptz = (function ($) {

    function init() {
        registerEventHandler();
    }

    function registerEventHandler() {
        $(document).on("click", '#img-au', function (e) {
            move('#img-au', 'up');
        });
        $(document).on("click", '#img-al', function (e) {
            move('#img-al', 'left');
        });
        $(document).on("click", '#img-ar', function (e) {
            move('#img-ar', 'right');
        });
        $(document).on("click", '#img-ad', function (e) {
            move('#img-ad', 'down');
        });
        $(document).on("click", '#button-goto', function (e) {
            gotoPreset('#button-goto', '#select-goto');
        });
    }

    function move(button, dir) {
        $(button).attr("disabled", true);
        $.ajax({
            type: "GET",
            url: 'cgi-bin/ptz.sh?dir='+dir,
            dataType: "json",
            error: function(response) {
                console.log('error', response);
                $(button).attr("disabled", false);
            },
            success: function(data) {
                $(button).attr("disabled", false);
            }
        });
    }

    function gotoPreset(button, select) {
        $(button).attr("disabled", true);
        $.ajax({
            type: "GET",
            url: 'cgi-bin/preset.sh?num='+$(select + " option:selected").text(),
            dataType: "json",
            error: function(response) {
                console.log('error', response);
                $(button).attr("disabled", false);
            },
            success: function(data) {
                $(button).attr("disabled", false);
            }
        });
    }

    return {
        init: init
    };

})(jQuery);

var APP = APP || {};

APP.status = (function ($) {

    var timeoutVar;

    function init() {
        updateStatusPage();
    }

    function updateStatusPage() {
        $.ajax({
            type: "GET",
            url: 'cgi-bin/status.json',
            dataType: "json",
            success: function(data) {
                for (let key in data) {
                    if (key != "uptime" && key != "total_memory" && key != "free_memory") {
                        $('#' + key).text(data[key]);
                    }
                }

                $('#uptime').text(String.format("%t", parseInt(data.uptime)));
                $('#memory').text("" + data.free_memory + "/" + data.total_memory + " KB");
            },
            error: function(response) {
                console.log('error', response);
            },
            complete: function () {
                clearTimeout(timeoutVar);
                timeoutVar = setTimeout(updateStatusPage, 10000);

            }
        });
    }

    return {
        init: init
    };

})(jQuery);

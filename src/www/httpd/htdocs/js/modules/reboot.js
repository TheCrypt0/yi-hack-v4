var APP = APP || {};

APP.reboot = (function ($) {

    var timeoutVar;

    function init() {
        registerEventHandler();
        setStatus("Camera is online.");
    }

    function registerEventHandler() {
        $(document).on("click", '#button-reboot', function (e) {
            rebootCamera();
        });
    }

    function rebootCamera() {
        $('#button-reboot').attr("disabled", true);
        $.ajax({
            type: "GET",
            url: 'cgi-bin/reboot.sh',
            dataType: "json",
            error: function(response) {
                console.log('error', response);
                $('#button-reboot').attr("disabled", false);
            },
            success: function(data) {
                setStatus("Camera is rebooting...");
                waitForBoot();
            }
        });
    }

    function waitForBoot() {
        setInterval(function(){
            $.ajax({
                url: '/',
                success: function(data) {
                    setStatus("Camera is back online, redirecting to home.");
                    $('#button-reboot').attr("disabled", false);
                    window.location.href="/";
                },
                error: function(data) {
                    setStatus("Waiting for the camera to come back online...");
                },
                timeout: 3000,
            });
        }, 5000);
    }

    function setStatus(text)
    {
        $('input[type="text"][data-key="STATUS"]').prop('value', text);
    }

    return {
        init: init
    };

})(jQuery);

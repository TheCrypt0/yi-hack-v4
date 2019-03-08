var APP = APP || {};

APP.configurations = (function ($) {

    function init() {
        registerEventHandler();
        fetchConfigs();
    }

    function registerEventHandler() {
        $(document).on("change", '.configs-switch input[type="checkbox"]', function (e) {
            updateConfigs();
        });
    }

    function fetchConfigs() {
        $.ajax({
            type: "GET",
            url: 'cgi-bin/get_configs.sh',
            dataType: "json",
            success: function(response) {
                $.each(response, function (key, state) {
                    $('input[type="checkbox"][data-key="' + key +'"]').prop('checked', state === 'yes');
                });
            },
            error: function(response) {
                console.log('error', response);
            }
        });
    }

    function updateConfigs() {
        let configs = {};
        $('.configs-switch input[type="checkbox"]').each(function () {
            configs[$(this).attr('data-key')] = $(this).prop('checked') ? 'yes' : 'no';
        });

        $.ajax({
            type: "POST",
            url: 'cgi-bin/update_configs.sh',
            data: configs,
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

var APP = APP || {};

APP.mqtt = (function ($) {

    function init() {
        registerEventHandler();
        fetchConfigs();
    }

    function registerEventHandler() {
        $(document).on("click", '#button-save', function (e) {
            saveConfigs();
        });
    }

    function fetchConfigs() {
        loadingStatusElem = $('#loading-status');
        loadingStatusElem.text("Loading...");
       
        $.ajax({
            type: "GET",
            url: 'cgi-bin/get_configs.sh?conf=mqtt',
            dataType: "json",
            success: function(response) {
                loadingStatusElem.fadeOut(500);

                $.each(response, function (key, state) {
                    if(key == "MQTT_PASSWORD")
                        $('input[type="password"][data-key="' + key +'"]').prop('value', state);
                    else
                        $('input[type="text"][data-key="' + key +'"]').prop('value', state);
                });
            },
            error: function(response) {
                console.log('error', response);
            }
        });

        $.ajax({
            type: "GET",
            url: 'cgi-bin/get_configs.sh?conf=system',
            dataType: "json",
            success: function(response) {

                $.each(response, function (key, state) {
                    if(key == "MQTT")
                        $('input[type="checkbox"][data-key="' + key +'"]').prop('checked', state === 'yes');
                });
            },
            error: function(response) {
                console.log('error', response);
            }
        });
    }

    function saveConfigs() {
        var saveStatusElem;

        let configs = {};
        let configsSystem = {};
        
        saveStatusElem = $('#save-status');
        saveStatusElem.text("Saving...");
        
        $('.configs-switch input[type="text"]').each(function () {
            configs[$(this).attr('data-key')] = $(this).prop('value');
        });

        $('.configs-switch input[type="password"]').each(function () {
            configs[$(this).attr('data-key')] = $(this).prop('value');
        });

        configsSystem["MQTT"]=$("#enable-mqtt").prop('checked') ? 'yes' : 'no';

        $.ajax({
            type: "POST",
            url: 'cgi-bin/set_configs.sh?conf=mqtt',
            data: configs,
            dataType: "json",
            success: function(response) {
                saveStatusElem.text("Saved");
            },
            error: function(response) {
                saveStatusElem.text("Error while saving");
                console.log('error', response);
            }
        });

        $.ajax({
            type: "POST",
            url: 'cgi-bin/set_configs.sh?conf=system',
            data: configsSystem,
            dataType: "json",
            success: function(response) {
            },
            error: function(response) {
                saveStatusElem.text("Error while saving");
                console.log('error', response);
            }
        });
    }

    return {
        init: init
    };

})(jQuery);

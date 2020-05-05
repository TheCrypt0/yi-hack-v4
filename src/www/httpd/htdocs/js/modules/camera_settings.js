var APP = APP || {};

APP.camera_settings = (function ($) {

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
            url: 'cgi-bin/get_configs.sh?conf=camera',
            dataType: "json",
            success: function(response) {
                loadingStatusElem.fadeOut(500);

                $.each(response, function (key, state) {
                    if(key=="SENSITIVITY")
                        $('select[data-key="' + key +'"]').prop('value', state);
                    else
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

        saveStatusElem = $('#save-status');

        saveStatusElem.text("Saving...");

        $('.configs-switch input[type="checkbox"]').each(function () {
            configs[$(this).attr('data-key')] = $(this).prop('checked') ? 'yes' : 'no';
        });

        configs["SENSITIVITY"] = $('select[data-key="SENSITIVITY"]').prop('value');

        $.ajax({
            type: "POST",
            url: 'cgi-bin/set_configs.sh?conf=camera',
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
            type: "GET",
            url: 'cgi-bin/camera_settings.sh?' +
                'save_video_on_motion=' + configs["SAVE_VIDEO_ON_MOTION"] +
                '&sensitivity=' + configs["SENSITIVITY"] +
                '&led=' + configs["LED"] +
                '&ir=' + configs["IR"] +
                '&rotate=' + configs["ROTATE"] +
                '&switch_on=' + configs["SWITCH_ON"],
            dataType: "json",
            success: function(response) {

            },
            error: function(response) {
                console.log('error', response);
            }
        });
    }

    return {
        init: init
    };

})(jQuery);

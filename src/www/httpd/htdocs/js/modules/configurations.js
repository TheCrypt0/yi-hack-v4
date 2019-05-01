var APP = APP || {};

APP.configurations = (function ($) {

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
        $.ajax({
            type: "GET",
            url: 'cgi-bin/get_configs.sh',
            dataType: "json",
            success: function(response) {
                $.each(response, function (key, state) {
                    if(key=="HOSTNAME")
                        $('input[type="text"][data-key="' + key +'"]').prop('value', state);
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
        
        configs["HOSTNAME"] = $('input[type="text"][data-key="HOSTNAME"]').prop('value');
        
        if(!validateHostname(configs["HOSTNAME"]))
        {
            saveStatusElem.text("Failed");
            alert("Hostname not valid!");
            return;
        }

        $.ajax({
            type: "POST",
            url: 'cgi-bin/update_configs.sh',
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
    }
    
    function validateHostname(hostname) {
        return /^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/.test(hostname);
    }

    return {
        init: init
    };

})(jQuery);

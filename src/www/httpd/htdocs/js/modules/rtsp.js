var APP = APP || {};

APP.rtsp = (function ($) {

    let rtspConfigs={};
    
    var isRtspPresent=false;
    var isLicensePresent=false;
    var isLicenseForThisCamera=false;
    var isCameraStillBooting=true;
    
    var licenseStatusElem;
        
    var stepsElem;
    var stepRtspElem;
    var stepLicenseElem;

    var configSection;
    
    var licUploadRow;
    var rtspUploadRow;
    
    var uploadButton;

    var filesToUpload;

    function init() {
        registerEventHandler();
        fetchConfigs();
        
        initElems();
    }
    
    function initElems()
    {
        stepsElem=$("#steps-enable-rtsp");
        stepRtspElem=$("#step-upload-rtsp");
        stepLicenseElem=$("#step-upload-license");
        
        licUploadRow=$("#license-upload-row");
        rtspUploadRow=$("#rtsp-upload-row");
        
        licenseStatusElem=$("#license-status");
        
        uploadButton=$("#button-upload");

        configSection=$("#config-section");
        
        configSection.hide();

        stepsElem.hide();
        
        stepRtspElem.hide();
        stepLicenseElem.hide();
        
        licUploadRow.hide();
        rtspUploadRow.hide();
        
        uploadButton.hide();
    }

    function registerEventHandler() {
        $(document).on("click", '#button-save', function (e) {
            saveConfigs();
        });
        $(document).on("click", '#button-upload', function (e) {
            uploadFiles();
        });
    }

    function fetchConfigs() {
        loadingStatusElem = $('#loading-status');
        loadingStatusElem.text("Loading...");
       
        $.ajax({
            type: "GET",
            url: 'cgi-bin/rtsp_backend.sh?action=getconf',
            dataType: "json",
            success: function(response) {
                loadingStatusElem.fadeOut(500);

                $.each(response, function (key, state) {
                    rtspConfigs[key]=state;
                    
                    if($('input[type="checkbox"][data-key="' + key +'"]').length)
                        $('input[type="checkbox"][data-key="' + key +'"]').prop('checked', state === 'yes');
                    else if($('input[type="text"][data-key="' + key +'"]').length)
                        $('input[type="text"][data-key="' + key +'"]').prop('value', state);
                    
                });
                
                printRtspUrls();
                rtspChecks();
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
        
        $('.configs-switch input[type="checkbox"]').each(function () {
            var key=$(this).attr('data-key');
            if(key!="RTSP")
                configs[key] = $(this).prop('checked') ? 'yes' : 'no';
            else
                configsSystem[key] = $(this).prop('checked') ? 'yes' : 'no';
        });

        $.ajax({
            type: "POST",
            url: 'cgi-bin/set_configs.sh?conf=viewd',
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
    
    function uploadFiles()
    {
        var licFilename=getFilename($("#file-license").val());
        var rtspFilename=getFilename($("#file-rtsp").val());

        var fileName="";

        filesToUpload=0;
        
        if(licFilename!="")
        {
            if(!isLicForCamera(licFilename))
            {
                alert("ERROR: The license isn't for this camera.");
                return;
            }
            
            fileName="etc/" + licFilename;
            uploadFile("#license-form", "#file-license", fileName, uploadFinished);
        }
        
        if(rtspFilename!="")
        {
            if(rtspFilename.split('.').pop()!="7z")
            {
                alert("ERROR: The RTSP file isn't a 7z archive.");
                return;
            }

            fileName="rtspv4__upload";
            uploadFile("#rtsp-form", "#file-rtsp", fileName, uploadFinished);
        }
    }

    function uploadFile(formId, fileId, filename, callback)
    {
        uploadButton.prop('value', 'Uploading...');
        filesToUpload++;
        console.log("Uploading " + filename);
        var fd = new FormData($(formId));
        fd.append('file',$(fileId)[0].files[0]);
        ajaxUpload(fd, filename, callback);
    }
    
    function ajaxUpload(fd, fileName, callback)
    {
        $.ajax({
            url: "cgi-bin/upload.sh?file=" + fileName,
            type: 'POST',
            data: fd,
            success: function(data){
                console.log(data);
                callback(data);
            },
            cache: false,
            contentType: false,
            processData: false
        });
    }

    function uploadFinished()
    {
        filesToUpload--;
        if(filesToUpload==0)
        {
            uploadButton.prop('value', 'Done!');
            setTimeout(location.reload.bind(location), 1000);
        }
    }
    
    function printRtspUrls(addr)
    {
        var baseUrl;
        baseUrl="rtsp://" + rtspConfigs["REMOTE_ADDR"] + "/";
        
        $('#hires-url').text(baseUrl + "ch0_0.h264");
        $('#lowres-url').text(baseUrl + "ch0_1.h264");
        $('#audio-url').text(baseUrl + "ch0_2.aac");
    }
    
    function rtspChecks()
    {        
        var rtspFile=getFilename(rtspConfigs["RTSP_FILE"]);
        var viewdFile=getFilename(rtspConfigs["VIEWD_FILE"]);
        var licFile=getFilename(rtspConfigs["LIC_FILE"]);
        var camhash=rtspConfigs["CAMHASH"];
        
        if(rtspFile=="rtspv4" && viewdFile=="viewd")
            isRtspPresent=true;
            
        if(licFile!="")
            isLicensePresent=true;

        if(camhash=="")
            isCameraStillBooting=true;
        else
            isCameraStillBooting=false;
            
        if(isLicForCamera(licFile))
            isLicenseForThisCamera=true;

        /*
        console.log("camhash: " + camhash);        
        console.log("isRtspPresent: " + isRtspPresent);
        console.log("isLicensePresent: " + isLicensePresent);
        console.log("isLicenseForThisCamera: " + isLicenseForThisCamera);
        */
        
        if(!isRtspPresent || !isLicensePresent || !isLicenseForThisCamera)
        {
            stepsElem.show();
            uploadButton.show();
        }
        
        if(!isLicensePresent || (!isLicenseForThisCamera && !isCameraStillBooting))
        {
            stepLicenseElem.show();
            licUploadRow.show();
        }
        
        if(!isRtspPresent)
        {
            licenseStatusElem.text("You first need to upload the rtspv4 file.");
            stepRtspElem.show();
            rtspUploadRow.show();
        }
        else if (isCameraStillBooting)
        {
            licenseStatusElem.text("The camera is still booting. Reloading the page in 2 seconds..");
            setTimeout(location.reload.bind(location), 2000);
        }
        else if (!isLicensePresent)
        {
            licenseStatusElem.text("You need to upload the license file.");
        }
        else if (!isLicenseForThisCamera)
        {
            licenseStatusElem.text("The license you uploaded isn't for this camera.");
        }
        else
        {
            licenseStatusElem.text("All the required files are on the camera.");
            configSection.show();
            stepsElem.hide();
        }
    }
    
    function isLicForCamera(licfile)
    {
        return (licfile==("viewd_" + rtspConfigs["CAMHASH"].substring(0,8) + ".lic"));
    }
    
    function getFilename(path)
    {
        return path.split(/(\\|\/)/g).pop();
    }

    return {
        init: init
    };

})(jQuery);

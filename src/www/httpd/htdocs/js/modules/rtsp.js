var APP = APP || {};

APP.rtsp = (function ($) {

    let rtspConfigs={};
    
    var isRtspPresent=false;
    var isLicensePresent=false;
    var isLicenseForThisCamera=false;
    
    var licenseStatusElem;
        
    var stepsElem;
    var stepRtspElem;
    var stepLicenseElem;
    
    var licUploadRow;
    var rtspUploadRow;
    
    var uploadButton;

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
                    if(key == "RTSP")
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

        configsSystem["RTSP"]=$("#enable-rtsp").prop('checked') ? 'yes' : 'no';

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
        
        if(licFilename!="")
        {
            if(!isLicForCamera(licFilename))
            {
                alert("ERROR: The license isn't for this camera.");
                return;
            }
            
            var fileName="etc/" + licFilename;
            
            console.log("Uploading " + fileName);
        
            var fd = new FormData($("#license-form"));
            
            fd.append('file',$('#file-license')[0].files[0]);
            
            ajaxUpload(fd, fileName);
        }
        
        if(rtspFilename!="")
        {            
            var fileName=rtspFilename;
            
            if(fileName.split('.').pop()!="7z")
            {
                alert("ERROR: The RTSP file isn't a 7z archive.");
                return;
            }
            
            console.log("Uploading " + fileName);
            
            fileName="rtspv4__upload";
        
            var fd = new FormData($("#rtsp-form"));
            
            fd.append('file',$('#file-rtsp')[0].files[0]);
            
            ajaxUpload(fd, fileName);
        }
    }
    
    function ajaxUpload(fd, fileName)
    {
        $.ajax({
            url: "cgi-bin/upload.sh?file=" + fileName,  
            type: 'POST',
            data: fd,
            success: function(data){
                console.log(data);
            },
            cache: false,
            contentType: false,
            processData: false
        });
    }
    
    function uploadLicense()
    {
        
    }
    
    function printRtspUrls(addr)
    {
        var baseUrl;
        baseUrl="rtsp://" + rtspConfigs["REMOTE_ADDR"] + "/";
        
        $('#hires-url').text(baseUrl + "ch0_0.h264");
        $('#lowres-url').text(baseUrl + "ch1_0.h264");
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
        
        if(!isLicensePresent || !isLicenseForThisCamera)
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

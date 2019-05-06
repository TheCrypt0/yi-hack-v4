var APP = APP || {};

APP.update = (function ($) {

    let configs={};
    
    var uploadSection;
    var uploadButton;
    
    var filesToUpload;

    function init() {
        registerEventHandler();
        fetchConfigs();
        
        uploadButton=$("#button-upload");
        
        uploadSection=$("#upload-section");
        //uploadSection.hide();
    }

    function registerEventHandler() {
        $(document).on("click", '#button-upload', function (e) {
            uploadFiles();
        });
    }

    function fetchConfigs() {
        loadingStatusElem = $('#loading-status');
        loadingStatusElem.text("Loading...");
       
        $.ajax({
            type: "GET",
            url: 'cgi-bin/update_backend.sh',
            dataType: "json",
            success: function(response) {
                loadingStatusElem.fadeOut(500);
                $.each(response, function (key, state) {
                    configs[key]=state;
                    
                    if($('input[type="checkbox"][data-key="' + key +'"]').length)
                        $('input[type="checkbox"][data-key="' + key +'"]').prop('checked', state === 'yes');
                    else if($('input[type="text"][data-key="' + key +'"]').length)
                        $('input[type="text"][data-key="' + key +'"]').prop('value', state);
                    
                });
                
                updateChecks();
            },
            error: function(response) {
                console.log('error', response);
            }
        });
    }
    
    function uploadFiles()
    {
        if(configs["IS_SD_PRESENT"]=="NO")
        {
            alert("An SD card must be present in the camera to flash a new image.");
            return;
        }

        var homeFilename=getFilename($("#file-home").val());
        var rootfsFilename=getFilename($("#file-rootfs").val());
        
        if(homeFilename=="" || rootfsFilename=="")
        {
            alert("Both home and rootfs files must be supplied.");
            return;
        }
        
        if(!homeFilename.startsWith("home"))
        {
            alert("Wrong home filename.");
            return;
        }
        
        if(!rootfsFilename.startsWith("rootfs"))
        {
            alert("Wrong rootfs filename.");
            return;
        }
        
        buttonShowUploading();
        
        filesToUpload=0;
        
        uploadFirmwareImage("#home-form", "#file-home", homeFilename, function(){ 
            console.log("Home uploaded!"); 
            uploadFinished();
         });
         
        uploadFirmwareImage("#rootfs-form", "#file-rootfs", rootfsFilename, function(){
            console.log("Rootfs uploaded!");
            uploadFinished();
        });
    }
    
    function uploadFirmwareImage(formId, fileId, filename, callback)
    {
        filesToUpload++;
        console.log("Uploading " + filename);
        var fd = new FormData();
        fd.append('file',$(fileId)[0].files[0]);
        ajaxUpload(fd, filename, callback);
    }
    
    function uploadFinished()
    {
        filesToUpload--;
        if(filesToUpload==0)
        {
            buttonShowDone();
            alert("Update files successfully uploaded!\n\nNow reboot your camera and wait a couple of minutes for the process to complete.");
        }
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
    
    function updateChecks()
    {
        var verStatusElem=$("#version-status");
        var needsUpdate=configs["NEEDS_UPDATE"];
        var isSdPresent=configs["IS_SD_PRESENT"]=="YES" ? true : false;

        if(!isSdPresent)
        {
            var elem=$("#upload-tbody");
            elem.text("An SD card must be present in the camera to flash a new image.")
        }
        
        if(needsUpdate=="yes")
        {
            uploadSection.show();
            verStatusElem.text("A new version is available!");
        }
        else if(needsUpdate=="no")
            verStatusElem.text("You are up to date!");
        else if(needsUpdate=="no_currentversionisbeta")
            verStatusElem.text("Congratulations, you are using a pre-release version!");
    }
    
    function buttonShowUploading()
    {
        uploadButton.prop('value', 'Uploading...');
    }
    
    function buttonShowDone()
    {
        uploadButton.prop('value', 'Done!');
    }
    
    function getFilename(path)
    {
        return path.split(/(\\|\/)/g).pop();
    }
    
    return {
        init: init
    };

})(jQuery);

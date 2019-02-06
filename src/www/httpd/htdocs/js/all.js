function get(url,callback,id) {
	var xhr=new XMLHttpRequest;
	xhr.open('GET',url);
    xhr.onreadystatechange = function() {
        if(xhr.readyState===4)
        {
            if(xhr.status!==200)
                console.log("Error while getting '%s'. readyState: %d - status: %d", url, xhr.readyState, xhr.status);
            else
                callback(xhr.responseText,id);
        }
	};
	xhr.send()
}

function repText(string,id) {
	document.getElementById(id).innerHTML = string.responseText;
}

function setText(id, string)
{
    document.getElementById(id).innerHTML = string;
}

function insertHtml(id, html) {
    var i=0;
    var elm = document.getElementById(id);
    elm.innerHTML = html;
    var scripts = elm.getElementsByTagName("script");
    var scriptsClone = [];
    for (i = 0; i < scripts.length; i++) {
        scriptsClone.push(scripts[i]);
    }
    for (i = 0; i < scriptsClone.length; i++) {
        var currentScript = scriptsClone[i];
        var s = document.createElement("script");
        for (var j = 0; j < currentScript.attributes.length; j++) {
            var a = currentScript.attributes[j];
            s.setAttribute(a.name, a.value);
        }
        s.appendChild(document.createTextNode(currentScript.innerHTML));
        currentScript.parentNode.replaceChild(s, currentScript);
    }
}

function hasClass( target, className ) {
    return new RegExp('(\\s|^)' + className + '(\\s|$)').test(target.className);
}

function toggleMobileNav() {
	if( hasClass(document.getElementsByTagName("nav")[0], "mobile") ) {
		document.getElementsByTagName("nav")[0].classList.remove("mobile");
	}
	else {
		document.getElementsByTagName("nav")[0].classList.add("mobile");
	}
}

/*
 *  Main page (container) functions
 */

function mainInit()
{
    document.getElementsByTagName("html")[0].onclick=function(){
        document.getElementsByTagName("nav")[0].classList.remove("mobile");
    }

    document.getElementsByTagName("nav")[0].onclick=function(e){
        e.stopPropagation();
    }

    var parsedUrl = new URL(window.location.href);
    var currentPage=parsedUrl.searchParams.get("page");

    if(!currentPage)
        currentPage="status";

    loadPage(currentPage);

    setText("nav-title", hostname);
    document.title=hostname + " - " + currentPage;

}

function loadPage(currentPage)
{    console.log("Current page: %s", currentPage);

    get("pages/" + currentPage + ".html", function(data)
    {
        insertHtml("container", data);
        pageInit();
    });
}

/*
 *   Status page functions
 */

function updateStatusPage()
{
    get("cgi-bin/status.json", showStatusPageDataCallback);
}

function showStatusPageDataCallback(data)
{
    var status=JSON.parse(data);

    for(key in status)
    {
        if(key!="uptime" && key!="total_memory" && key!="free_memory")
            setText(key, status[key]);
    }
    
    setText("uptime", parseUptime(status.uptime));
    setText("memory", "" + status.free_memory + "/" + status.total_memory + " KB");
}

function parseUptime(uptime)
{
    var val = parseInt(uptime); 
    var days = 0; 
    var hours = 0;
    var minutes = 0;
    
    if (val >= (60*60*24))
    {
        days = Math.floor(val / (60*60*24)); 
        val = val - (days * (60*60*24));
    }
    
    if (val >= 60*60)
    {
       hours = Math.floor(val / (60*60));
        val = val - (hours * (60*60));
    }
    minutes = Math.floor(val/60);

    var stringDays = ""; 
    var stringHours = "";
    var stringMinutes = "";
    if (days === 1) {
        stringDays = "1 day "; 
    } else if (days > 1) {
        stringDays = days + " days "; 
    } 

    if (hours === 1) {
        stringHours = "1 hour "; 
    } else if (hours > 1) {
        stringHours = hours + " hours "; 
    }

    if (minutes === 1) {
        stringMinutes = "1 minute";
    } else if (minutes > 1) {
        stringMinutes = minutes + " minutes"; 
    } 

    var returnString =  stringDays + stringHours + stringMinutes;
    return returnString.trim(); 
}


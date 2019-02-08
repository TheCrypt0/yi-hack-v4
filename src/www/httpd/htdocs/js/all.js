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

String.format = function()
{
	var a = [ ];
	for (var i = 1; i < arguments.length; i++)
		a.push(arguments[i]);
	return ''.format.apply(arguments[0], a);
}

String.prototype.format = function()
{
	if (!RegExp)
		return;

	var html_esc = [/&/g, '&#38;', /"/g, '&#34;', /'/g, '&#39;', /</g, '&#60;', />/g, '&#62;'];
	var quot_esc = [/"/g, '&#34;', /'/g, '&#39;'];

	function esc(s, r) {
		if (typeof(s) !== 'string' && !(s instanceof String))
			return '';

		for( var i = 0; i < r.length; i += 2 )
			s = s.replace(r[i], r[i+1]);
		return s;
	}

	var str = this;
	var out = '';
	var re = /^(([^%]*)%('.|0|\x20)?(-)?(\d+)?(\.\d+)?(%|b|c|d|u|f|o|s|x|X|q|h|j|t|m))/;
	var a = b = [], numSubstitutions = 0, numMatches = 0;

	while (a = re.exec(str))
	{
		var m = a[1];
		var leftpart = a[2], pPad = a[3], pJustify = a[4], pMinLength = a[5];
		var pPrecision = a[6], pType = a[7];

		numMatches++;

		if (pType == '%')
		{
			subst = '%';
		}
		else
		{
			if (numSubstitutions < arguments.length)
			{
				var param = arguments[numSubstitutions++];

				var pad = '';
				if (pPad && pPad.substr(0,1) == "'")
					pad = leftpart.substr(1,1);
				else if (pPad)
					pad = pPad;
				else
					pad = ' ';

				var justifyRight = true;
				if (pJustify && pJustify === "-")
					justifyRight = false;

				var minLength = -1;
				if (pMinLength)
					minLength = +pMinLength;

				var precision = -1;
				if (pPrecision && pType == 'f')
					precision = +pPrecision.substring(1);

				var subst = param;

				switch(pType)
				{
					case 'b':
						subst = (+param || 0).toString(2);
						break;

					case 'c':
						subst = String.fromCharCode(+param || 0);
						break;

					case 'd':
						subst = ~~(+param || 0);
						break;

					case 'u':
						subst = ~~Math.abs(+param || 0);
						break;

					case 'f':
						subst = (precision > -1)
							? ((+param || 0.0)).toFixed(precision)
							: (+param || 0.0);
						break;

					case 'o':
						subst = (+param || 0).toString(8);
						break;

					case 's':
						subst = param;
						break;

					case 'x':
						subst = ('' + (+param || 0).toString(16)).toLowerCase();
						break;

					case 'X':
						subst = ('' + (+param || 0).toString(16)).toUpperCase();
						break;

					case 'h':
						subst = esc(param, html_esc);
						break;

					case 'q':
						subst = esc(param, quot_esc);
						break;

					case 't':
						var td = 0;
						var th = 0;
						var tm = 0;
						var ts = (param || 0);

						if (ts > 60) {
							tm = Math.floor(ts / 60);
							ts = (ts % 60);
						}

						if (tm > 60) {
							th = Math.floor(tm / 60);
							tm = (tm % 60);
						}

						if (th > 24) {
							td = Math.floor(th / 24);
							th = (th % 24);
						}

						subst = (td > 0)
							? String.format('%dd %dh %dm %ds', td, th, tm, ts)
							: String.format('%dh %dm %ds', th, tm, ts);

						break;

					case 'm':
						var mf = pMinLength ? +pMinLength : 1000;
						var pr = pPrecision ? ~~(10 * +('0' + pPrecision)) : 2;

						var i = 0;
						var val = (+param || 0);
						var units = [ ' ', ' K', ' M', ' G', ' T', ' P', ' E' ];

						for (i = 0; (i < units.length) && (val > mf); i++)
							val /= mf;

						subst = (i ? val.toFixed(pr) : val) + units[i];
						pMinLength = null;
						break;
				}
			}
		}

		if (pMinLength) {
			subst = subst.toString();
			for (var i = subst.length; i < pMinLength; i++)
				if (pJustify == '-')
					subst = subst + ' ';
				else
					subst = pad + subst;
		}

		out += leftpart + subst;
		str = str.substr(m.length);
	}

	return out + str;
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
    
    setText("uptime", String.format("%t",parseInt(status.uptime)));
    setText("memory", "" + status.free_memory + "/" + status.total_memory + " KB");
}



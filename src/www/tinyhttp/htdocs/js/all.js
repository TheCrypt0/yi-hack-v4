function get(url,callback,id) {
	var xhr=new XMLHttpRequest;
	xhr.open('GET',url);
	xhr.onreadystatechange = function() {
		3 < xhr.readyState && callback(xhr,id)
	};
	xhr.send()
}

function text(string,id) {
	document.getElementById(id).innerHTML = string.responseText;
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

document.getElementsByTagName("html")[0].onclick=function(){
	document.getElementsByTagName("nav")[0].classList.remove("mobile");
}

document.getElementsByTagName("nav")[0].onclick=function(e){
    e.stopPropagation();
}
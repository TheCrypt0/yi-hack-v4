function get(url,call) {
	var x=new XMLHttpRequest;
	x.open('GET',url);
	x.onreadystatechange = function() {
		3 < x.readyState && call(x)
	};
	x.send()
}

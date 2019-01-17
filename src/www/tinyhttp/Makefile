CC=arm-hisiv300-linux-gcc

all: tinyhttp cgi

tinyhttp: tinyhttp.c
	$(CC) -w -o tinyhttp tinyhttp.c
	
cgi: ./cgi-bin/test.c
	$(CC) -w -static -o ./cgi-bin/test.cgi ./cgi-bin/test.c
	
clean:
	rm tinyhttp
	rm ./cgi-bin/*.cgi

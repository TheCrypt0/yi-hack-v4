CC=arm-hisiv300-linux-gcc

all: tinyhttp cgi

tinyhttp: tinyhttp.c
	$(CC) -w -Os -o tinyhttp tinyhttp.c

cgi: ./cgi-bin/test.c
	$(CC) -w -Os -o ./cgi-bin/test.cgi ./cgi-bin/test.c

clean:

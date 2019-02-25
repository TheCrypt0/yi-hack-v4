CC=arm-hisiv300-linux-gcc
STRIP=arm-hisiv300-linux-strip

all: wsdiscovery

wsdiscovery: wsdiscovery.c
	$(CC) -Os -o wsdiscovery wsdiscovery.c
	$(STRIP) wsdiscovery

clean:
	rm -f wsdiscovery
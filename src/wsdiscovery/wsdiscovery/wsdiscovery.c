#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <ifaddrs.h>
#include <signal.h>

#define MULTICAST_PORT 3702
#define MULTICAST_GROUP "239.255.255.250"
#define UUID_SIZE 37
#define BUF_SIZE 2048

int cnt = 1;
char uuid[UUID_SIZE];
char addressBuffer[INET_ADDRSTRLEN];
char name[UUID_SIZE];
char hex[16] = "0123456789abcdef";

int check_link(const char *ifname) {
    int state = -1;
    int socId = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
	int rv;
	if ((socId < 0) < 0)
        perror("Socket failed");

    struct ifreq if_req;
    (void) strncpy(if_req.ifr_name, ifname, sizeof(if_req.ifr_name));

	if ((rv = ioctl(socId, SIOCGIFFLAGS, &if_req)) == -1)
        perror("Ioctl failed");
	
    close(socId);

    return (if_req.ifr_flags & IFF_UP) && (if_req.ifr_flags & IFF_RUNNING);
}

void get_uuid(char *buf)
{
	int i = 0; 
	while(i < 36) {
		/* Format has to be xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx */
		if(i == 8 || i == 13 || i ==18 || i == 23)
			buf[i] = '-';
		else if(i == 14)
			buf[i] = '4';
		else
			buf[i] = hex[rand() % 16];
		++i;
	}
}

void get_msgid(char *buf)
{
	strcpy(buf, uuid);
	int i = 9;
	while(i < 36) {
		if(i == 13 || i ==18 || i == 23)
			buf[i] = '-';
		else if(i == 14)
			buf[i] == '4';
		else
			buf[i] = hex[rand() % 16];
	 ++i;
	}
}

static void signal_callback(int signum)
{
	++cnt;
	int addrlen, bye_sock, family, s;
    struct sockaddr_in bye_addr;
	
	bzero(&bye_addr,sizeof(bye_addr));
    bye_addr.sin_family = AF_INET;
    bye_addr.sin_addr.s_addr=htonl(INADDR_ANY);
    bye_addr.sin_port = htons(MULTICAST_PORT);
    addrlen = sizeof(bye_addr);
	
    if ((bye_sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        perror("socket failed");
        exit(1);
    }
	
	char msgid[UUID_SIZE];
	char msgchar[BUF_SIZE];
	get_msgid(msgid);
	
	/* Send our SOAP Goodbye Mesage */
	bye_addr.sin_addr.s_addr = inet_addr(MULTICAST_GROUP);
	sprintf(msgchar, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:wsa=\"http://schemas.xmlsoap.org/ws/2004/08/addressing\" xmlns:d=\"http://schemas.xmlsoap.org/ws/2005/04/discovery\" xmlns:tdn=\"http://www.onvif.org/ver10/network/wsdl\"><SOAP-ENV:Header><wsa:MessageID>urn:uuid:%s</wsa:MessageID><wsa:ReplyTo SOAP-ENV:mustUnderstand=\"true\"><wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address></wsa:ReplyTo><wsa:To SOAP-ENV:mustUnderstand=\"true\">urn:schemas-xmlsoap-org:ws:2005:04:discovery</wsa:To><wsa:Action SOAP-ENV:mustUnderstand=\"true\">http://schemas.xmlsoap.org/ws/2005/04/discovery/Bye</wsa:Action><d:AppSequence InstanceId=\"0\" MessageNumber=\"%i\"></d:AppSequence></SOAP-ENV:Header><SOAP-ENV:Body><d:Bye><wsa:EndpointReference><wsa:Address>urn:uuid:%s</wsa:Address></wsa:EndpointReference><d:Types>tdn:NetworkVideoTransmitter</d:Types><d:Scopes>onvif://www.onvif.org/name/%s onvif://www.onvif.org/Profile/Streaming</d:Scopes><d:XAddrs>http://%s/onvif/device_service</d:XAddrs><d:MetadataVersion>0</d:MetadataVersion></d:Bye></SOAP-ENV:Body></SOAP-ENV:Envelope>", msgid, cnt, uuid, name, addressBuffer);
	if (sendto(bye_sock, msgchar, strlen(msgchar), 0, (struct sockaddr *) &bye_addr, addrlen) < 0) {
		perror("sendto");
		exit(1);
	}

	exit(1);
}

char * extract_between(const char *str, const char *p1, const char *p2)
{
  const char *i1 = strstr(str, p1);
  if(i1 != NULL)
  {
    const size_t pl1 = strlen(p1);
    const char *i2 = strstr(i1 + pl1, p2);
    if(p2 != NULL)
    {
     /* Found both markers, extract text. */
     const size_t mlen = i2 - (i1 + pl1);
     char *ret = malloc(mlen + 1);
     if(ret != NULL)
     {
       memcpy(ret, i1 + pl1, mlen);
       ret[mlen] = '\0';
       return ret;
     }
    }
  }
}

int main(int argc, const char * argv[])  {

    int addrlen, sock, family, s;
    struct sockaddr_in addr;
    struct ip_mreq mreq;
    struct ifaddrs * ifAddrStruct = NULL;
    struct ifaddrs * ifa = NULL;
    void * tmpAddrPtr = NULL;
	char msgid[UUID_SIZE];
	char msgchar[BUF_SIZE];
	
	srand((unsigned int) time(0));					/* Setting Time as random seed */
	strcat(name, argv[2]);
	
	signal(SIGTERM, signal_callback);				/* Handler for Sigterm */
	signal(SIGINT, signal_callback);				/* and Sigint */
	
    bzero(&addr,sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr=htonl(INADDR_ANY);
    addr.sin_port = htons(MULTICAST_PORT);
    addrlen = sizeof(addr);
	
    while (strlen(addressBuffer) == 0) {			/* check if we allready have an valid IPv4 address assigned */
		if (getifaddrs(&ifAddrStruct) == -1) 
		{
			perror("getifaddrs");
			exit(1);
		} 
		for (ifa = ifAddrStruct; ifa != NULL; ifa = ifa->ifa_next) {
			if ((strcmp(ifa->ifa_name,argv[1])==0)&&ifa ->ifa_addr->sa_family==AF_INET) { 	/* Check it is a valid IPv4 address */
				tmpAddrPtr = &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;
				inet_ntop(AF_INET, tmpAddrPtr, addressBuffer, INET_ADDRSTRLEN);
			}
		}
		if(strlen(addressBuffer) == 0)				/* Sleep for one secound if we still didnt get an valid IPv4 address */
			sleep(1);
	}
	
    if (ifAddrStruct != NULL)
        freeifaddrs(ifAddrStruct);

    if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        perror("socket failed");
        exit(1);
    }

    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
        perror("bind failed");
        exit(1);
    }

    mreq.imr_multiaddr.s_addr = inet_addr(MULTICAST_GROUP); 	/* Set Multicast IP address */
	mreq.imr_interface.s_addr = inet_addr(addressBuffer);		/* Set interface for Multicast subscription */
    if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char *)&mreq, sizeof(mreq)) == -1) {
        perror("Error joining multicast group");
        exit(1);
    }
	
	get_uuid(uuid);			/* Get our UUID for this session */
	get_msgid(msgid);		/* Get the first Message ID for this session */
	
	/* Send the XML-SOAP Hello message */
	sprintf(msgchar, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:wsa=\"http://schemas.xmlsoap.org/ws/2004/08/addressing\" xmlns:d=\"http://schemas.xmlsoap.org/ws/2005/04/discovery\" xmlns:tdn=\"http://www.onvif.org/ver10/network/wsdl\"><SOAP-ENV:Header><wsa:MessageID>urn:uuid:%s</wsa:MessageID><wsa:ReplyTo SOAP-ENV:mustUnderstand=\"true\"><wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address></wsa:ReplyTo><wsa:To SOAP-ENV:mustUnderstand=\"true\">urn:schemas-xmlsoap-org:ws:2005:04:discovery</wsa:To><wsa:Action SOAP-ENV:mustUnderstand=\"true\">http://schemas.xmlsoap.org/ws/2005/04/discovery/Hello</wsa:Action><d:AppSequence InstanceId=\"0\" MessageNumber=\"%i\"></d:AppSequence></SOAP-ENV:Header><SOAP-ENV:Body><d:Hello><wsa:EndpointReference><wsa:Address>urn:uuid:%s</wsa:Address></wsa:EndpointReference><d:Types>tdn:NetworkVideoTransmitter</d:Types><d:Scopes>onvif://www.onvif.org/name/%s onvif://www.onvif.org/Profile/Streaming</d:Scopes><d:XAddrs>http://%s/onvif/device_service</d:XAddrs><d:MetadataVersion>0</d:MetadataVersion></d:Hello></SOAP-ENV:Body></SOAP-ENV:Envelope>", msgid, cnt, uuid, name, addressBuffer);
	addr.sin_addr.s_addr = inet_addr(MULTICAST_GROUP);
	if (sendto(sock, msgchar, strlen(msgchar), 0, (struct sockaddr *) &addr, addrlen) < 0) {
 	    perror("sendto");
	    exit(1);
	}

    while (1) {
	    char buf[BUF_SIZE] = "";

        if (recvfrom(sock, buf, sizeof(buf), 0, (struct sockaddr *) &addr, &addrlen) < 0) {
	      perror("recvfrom");
	      exit(1);
	    }
        if(strstr(buf, "NetworkVideoTransmitter") && !strstr(buf, "XAddrs")) {
			++cnt;
			char msgchar[BUF_SIZE] = "";
			char msgid[UUID_SIZE] = "";
			get_uuid(msgid);			/* Get a new Message ID */

            sprintf(msgchar, "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:wsa=\"http://schemas.xmlsoap.org/ws/2004/08/addressing\" xmlns:d=\"http://schemas.xmlsoap.org/ws/2005/04/discovery\" xmlns:tdn=\"http://www.onvif.org/ver10/network/wsdl\"><SOAP-ENV:Header><wsa:MessageID>urn:uuid:%s</wsa:MessageID><wsa:RelatesTo>%s</wsa:RelatesTo><wsa:ReplyTo SOAP-ENV:mustUnderstand=\"true\"><wsa:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:Address></wsa:ReplyTo><wsa:To SOAP-ENV:mustUnderstand=\"true\">http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsa:Action SOAP-ENV:mustUnderstand=\"true\">http://schemas.xmlsoap.org/ws/2005/04/discovery/ProbeMatches</wsa:Action><d:AppSequence InstanceId=\"0\" MessageNumber=\"%i\"></d:AppSequence></SOAP-ENV:Header><SOAP-ENV:Body><d:ProbeMatches><d:ProbeMatch><wsa:EndpointReference><wsa:Address>urn:uuid:%s</wsa:Address></wsa:EndpointReference><d:Types>tdn:NetworkVideoTransmitter</d:Types><d:Scopes>onvif://www.onvif.org/name/%s onvif://www.onvif.org/Profile/Streaming</d:Scopes><d:XAddrs>http://%s/onvif/device_service</d:XAddrs><d:MetadataVersion>0</d:MetadataVersion></d:ProbeMatch></d:ProbeMatches></SOAP-ENV:Body></SOAP-ENV:Envelope>", msgid, extract_between(buf, "<a:MessageID>", "</a:MessageID>"), cnt, uuid, name, addressBuffer );
	        if (sendto(sock, msgchar, strlen(msgchar), 0, (struct sockaddr *) &addr, addrlen) < 0) {
 	            perror("sendto");
	            exit(1);
	        }

        }
    }
}
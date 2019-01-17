/*
 * tinyhttp.c - a minimal HTTP server that serves static and
 *          dynamic content for use on embedded linux platforms
 *
 *          usage: tiny <port>
 */

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <netdb.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define BUFSIZE 512
#define MAXERRS 16
#define SERVER_STRING "Server: tinyhttp\n"
#define WWWPATH "../www/htdocs"
#define CGIPATH "../www"

extern char **environ; /* the environment */

/* cerror - returns an error message to the client */
void cerror(FILE *stream, char *cause, char *errno, char *msg) {
  fprintf(stream, "HTTP/1.1 %s %s\n", errno, msg);
  fprintf(stream, SERVER_STRING);
  fprintf(stream, "Content-type: text/html\n\n");
  fprintf(stream, "%s: %s\n", errno, msg);
}

int main(int argc, char **argv) {

  /* variables for connection management */
  int parentfd;          /* parent socket */
  int childfd;           /* child socket */
  int portno;            /* port to listen on */
  int clientlen;         /* byte size of client's address */
  int optval;            /* flag value for setsockopt */
  struct sockaddr_in serveraddr; /* server's addr */
  struct sockaddr_in clientaddr; /* client addr */

  /* variables for connection I/O */
  FILE *stream;          /* stream version of childfd */
  char buf[512];         /* message buffer */
  char method[4];        /* request method */
  char uri[64];          /* request uri */
  char version[16];      /* request method */
  char filename[64];     /* path derived from uri */
  char filetype[16];     /* path derived from uri */
  char cgiargs[512];     /* cgi argument list */
  char *p;               /* temporary pointer */
  int is_static;         /* static request? */
  int is_gzipped;		 /* gzipped content? */
  struct stat sbuf;      /* file status */
  int fd;                /* static content filedes */
  int pid;               /* process id from fork */
  int wait_status;       /* status from wait */

  /* check command line args */
  if (argc != 2) {
    fprintf(stderr, "usage: %s <port>\n", argv[0]);
    exit(1);
  }
  portno = atoi(argv[1]);

  /* open socket descriptor */
  parentfd = socket(AF_INET, SOCK_STREAM, 0);
  if (parentfd < 0) {
	perror("ERROR opening socket");
    exit(1);
  }

  /* allows us to restart server immediately */
  optval = 1;
  setsockopt(parentfd, SOL_SOCKET, SO_REUSEADDR,
	     (const void *)&optval , sizeof(int));

  /* bind port to socket */
  bzero((char *) &serveraddr, sizeof(serveraddr));
  serveraddr.sin_family = AF_INET;
  serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
  serveraddr.sin_port = htons((unsigned short)portno);
  if (bind(parentfd, (struct sockaddr *) &serveraddr,
	sizeof(serveraddr)) < 0) {
      perror("ERROR on binding");
      exit(1);
    }

  /* get us ready to accept connection requests */
  if (listen(parentfd, 100) < 0) {  /* allow 100 requests to queue up */
    perror("ERROR on listen");
    exit(1);
  }
  /* main loop: wait for a connection request, parse HTTP,
   * serve requested content, close connection. */
  clientlen = sizeof(clientaddr);
  while (1) {

    /* wait for a connection request */
    childfd = accept(parentfd, (struct sockaddr *) &clientaddr, &clientlen);
    if (childfd < 0) {
      perror("ERROR on accept");
	  exit(1);
	}

    /* open the child socket descriptor as a stream */
    if ((stream = fdopen(childfd, "r+")) == NULL) {
      perror("ERROR on fdopen");
	  exit(1);
	}

    /* get the HTTP request line and output to stdout */
    fgets(buf, BUFSIZE, stream);
    printf("%s", buf);
    sscanf(buf, "%s %s %s\n", method, uri, version);

    /* tiny only supports the GET method */
    if (strcasecmp(method, "GET")) {
      cerror(stream, method, "501", "Not Implemented");
      fclose(stream);
      close(childfd);
      continue;
    }

    /* read (and ignore) the HTTP headers */
    while(strcmp(buf, "\r\n")) {
      fgets(buf, BUFSIZE, stream);
      // printf("%s", buf);
    }

    /* parse the uri */
    if (!strstr(uri, "cgi-bin")) {  /* static content */
      is_static = 1;
      is_gzipped = 0;
      strcpy(cgiargs, "");
      strcpy(filename, WWWPATH);
      strcat(filename, uri);
      if (uri[strlen(uri)-1] == '/')
	    strcat(filename, "index.html");
	    if (strstr(filename, ".css") || strstr(filename, ".js") || strstr(filename, ".html")) {
		    strcat(filename, ".gz");
        is_gzipped = 1;
      }
    }
    else {                          /* dynamic content */
      is_static = 0;
      p = index(uri, '?');
      if (p) {
	    strcpy(cgiargs, p+1);
	    *p = '\0';
      }
      else {
	    strcpy(cgiargs, "");
      }
      strcpy(filename, CGIPATH);
      strcat(filename, uri);
    }

    /* make sure the file exists */
    if (stat(filename, &sbuf) < 0) {
      cerror(stream, filename, "404", "Not found");
      fclose(stream);
      close(childfd);
      continue;
    }

    /* serve static content */
    if (is_static) {
      if (strstr(filename, ".html"))
	    strcpy(filetype, "text/html");
      else if (strstr(filename, ".png"))
	    strcpy(filetype, "image/png");
      else if (strstr(filename, ".css"))
	    strcpy(filetype, "text/css");
      else if (strstr(filename, ".js"))
	    strcpy(filetype, "text/javascript");
      else
	    strcpy(filetype, "text/plain");

      /* print response header */
      fprintf(stream, "HTTP/1.1 200 OK\n");
      fprintf(stream, SERVER_STRING);
	    if (is_gzipped == 1)
		    fprintf(stream, "Content-encoding: gzip\n");
      fprintf(stream, "Content-type: %s\n", filetype);
      fprintf(stream, "\r\n");
      fflush(stream);

      /* Use mmap to return arbitrary-sized response body */
      fd = open(filename, O_RDONLY);
      p = mmap(0, sbuf.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
      fwrite(p, 1, sbuf.st_size, stream);
      munmap(p, sbuf.st_size);
    }

    /* serve dynamic content */
    else {
      /* make sure file is a regular executable file */
      if (!(S_IFREG & sbuf.st_mode) || !(S_IXUSR & sbuf.st_mode)) {
	    cerror(stream, filename, "403", "Forbidden");
	    fclose(stream);
	    close(childfd);
	    continue;
      }

      /* a real server would set other CGI environ vars as well*/
      setenv("QUERY_STRING", cgiargs, 1);

      /* print first part of response header */
      sprintf(buf, "HTTP/1.1 200 OK\n");
      write(childfd, buf, strlen(buf));
      sprintf(buf, SERVER_STRING);
      write(childfd, buf, strlen(buf));

      /* create and run the child CGI process so that all child
         output to stdout and stderr goes back to the client via the
         childfd socket descriptor */
      pid = fork();
      if (pid < 0) {
	    perror("ERROR in fork");
	    exit(1);
      }
      else if (pid > 0) { /* parent process */
	    wait(&wait_status);
      }
      else { /* child  process*/
	    close(0); /* close stdin */
	    dup2(childfd, 1); /* map socket to stdout */
	    dup2(childfd, 2); /* map socket to stderr */
	    if (execve(filename, NULL, environ) < 0) {
	      perror("ERROR in execve");
	    }
      }
    }

    /* clean up */
    fclose(stream);
    close(childfd);
  }
}

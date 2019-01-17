#include <stdio.h>

int main()
{
  printf("Content-type: text/html\n\n");
  printf("<html>\n");
  printf("<body>\n");
  printf("<h1>If you can read this, CGI is working!</h1>\n");
  printf("</body>\n");
  printf("</html>\n");
  return 0;
}

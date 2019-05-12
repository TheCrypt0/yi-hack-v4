/*
 * Proccgi
 *
 * Reads form variables and dumps them on standard output.
 * Distributed by the GNU General Public License. Use and be happy.
 *
 * Frank Pilhofer
 * fp@fpx.de
 *
 * Last changed 11/06/1997
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <memory.h>

/*
 * Duplicate string
 */

char *
FP_strdup (char *string)
{
  char *result;

  if (string == NULL)
    return NULL;

  if ((result = (char *) malloc (strlen (string) + 1)) == NULL) {
    fprintf (stderr, "proccgi -- out of memory dupping %d bytes\n",
	     (int) strlen (string));
    return NULL;
  }

  strcpy (result, string);
  return result;
}

/*
 * Read CGI input
 */

char *
LoadInput (void)
{
  char *result, *method, *p;
  int length, ts;

  if ((method = getenv ("REQUEST_METHOD")) == NULL) {
    return NULL;
  }

  if (strcmp (method, "GET") == 0) {
    if ((p = getenv ("QUERY_STRING")) == NULL)
      return NULL;
    else
      result = FP_strdup (p);
  }
  else if (strcmp (method, "POST") == 0) {
    if ((length = atoi (getenv ("CONTENT_LENGTH"))) == 0)
      return NULL;

    if ((result = malloc (length + 1)) == NULL) {
      fprintf (stderr, "proccgi -- out of memory allocating %d bytes\n",
	       length);
      return NULL;
    }

    if ((ts = fread (result, sizeof (char), length, stdin)) < length) {
      fprintf (stderr, "proccgi -- error reading post data, %d bytes read, %d expedted\n",
	       ts, length);
    }
    result[length] = '\0';
  }
  else {
    return NULL;
  }

  return result;
}

/*
 * Parse + and %XX in CGI data
 */

char *
ParseString (char *instring)
{
  char *ptr1=instring, *ptr2=instring;

  if (instring == NULL)
    return instring;

  while (isspace (*ptr1))
    ptr1++;

  while (*ptr1) {
    if (*ptr1 == '+') {
      ptr1++; *ptr2++=' ';
    }
    else if (*ptr1 == '%' && isxdigit (*(ptr1+1)) && isxdigit (*(ptr1+2))) {
      ptr1++;
      *ptr2    = ((*ptr1>='0'&&*ptr1<='9')?(*ptr1-'0'):((char)toupper(*ptr1)-'A'+10)) << 4;
      ptr1++;
      *ptr2++ |= ((*ptr1>='0'&&*ptr1<='9')?(*ptr1-'0'):((char)toupper(*ptr1)-'A'+10));
      ptr1++;
    }
    else 
      *ptr2++ = *ptr1++;
  }
  while (ptr2>instring && isspace(*(ptr2-1)))
    ptr2--;

  *ptr2 = '\0';

  return instring;
}

/*
 * break into attribute/value pair. Mustn't use strtok, which is
 * already used one level below. We assume that the attribute doesn't
 * have any special characters.
 */

void
HandleString (char *input)
{
  char *data, *ptr, *p2;

  if (input == NULL) {
    return;
  }

  data = FP_strdup   (input);
  ptr  = ParseString (data);

  /*
   * Security:
   *
   * only accept all-alphanumeric attributes, and don't accept empty
   * values
   */

  if (!isalpha(*ptr) && *ptr != '_') {free (data); return;}
  ptr++;
  while (isalnum(*ptr) || *ptr == '_') ptr++;
  if (*ptr != '=') {free (data); return;}

  *ptr = '\0';
  p2 = ptr+1;

  fprintf (stdout, "FORM_%s=\"", data);

  /*
   * escape value
   */

  while (*p2) {
    switch (*p2) {
    case '"': case '\\': case '`': case '$':
      putc ('\\', stdout);
    default:
      putc (*p2,  stdout);
      break;
    }
    p2++;
  }
  putc ('"',  stdout);
  putc ('\n', stdout);
  *ptr = '=';
  free (data);
}

int
main (int argc, char *argv[])
{
  char *ptr, *data = LoadInput();
  int i;

  /*
   * Handle CGI data
   */

  if (data) {
    ptr = strtok (data, "&");
    while (ptr) {
      HandleString (ptr);
      ptr = strtok (NULL, "&");
    }
    free (data);
  }

  /*
   * Add Path info
   */

  if (getenv ("PATH_INFO") != NULL) {
    data = FP_strdup (getenv ("PATH_INFO"));
    ptr = strtok (data, "/");
    while (ptr) {
      HandleString (ptr);
      ptr = strtok (NULL, "/");
    }
    free (data);
  }

  /*
   * Add args
   */

  for (i=1; i<argc; i++) {
    HandleString (argv[i]);
  }

  /*
   * done
   */

  return 0;
}

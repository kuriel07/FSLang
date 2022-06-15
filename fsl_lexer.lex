%{
/*=========================================================================
C-libraries and Token definitions
=========================================================================*/
#include <string.h> /* for strdup */
#include "fsl.h"
/*#include <stdlib.h> */ /* for atoi */

#define YY_INPUT(buf,result,max_size) { \
	int c = '*', n, d; \
	for ( n = 0; n < max_size && \
		     (c = fgetc( yyin )) != EOF && c != '\n'; ++n ) \
		buf[n] = (char)(c); \
	if ( c == '\n' ) { \
        	while((d = fgetc( yyin )) == '\r' || d == '\n') {  }\
        	if( d == EOF) {\
            		fclose( yyin);\
        	} else {\
            		fseek( yyin, -1, SEEK_CUR);\
		    	buf[n++] = (char) c; \
        	}\
	} \
	if ( c == EOF ) {\
		printf( "input in flex scanner failed\n" ); \
	}\
	result = n; \
	if(result<=0) result=YY_NULL; \
}


%}
/*=========================================================================
TOKEN Definitions
=========================================================================*/
ALPHANUMERIC [A-Za-z0-9]*
NUMERIC [0-9]*

/*=========================================================================
REGULAR EXPRESSIONS defining the tokens for the Simple language
=========================================================================*/
%%
[ \r\t]+ {  }
[\n]+ { }

"input" { return P_INPUT; }
"output" { return P_OUTPUT; }

"+" { return P_ADD; }
"-" { return P_SUB; }
"*" { return P_MUL; }
"/" { return P_DIV; }
"=" { return P_ASSIGNMENT; }
";" { return P_EOS; }

{NUMERIC} { yylval.value = atoi(yytext); return P_CONST; }
{ALPHANUMERIC} { strncpy(yylval.string, yytext, 4096); return P_VAR; }


. { return( yytext[0] ); }
%%

int yywrap(void) { return -1; }

void yyinit(void) {
	YY_FLUSH_BUFFER;
	BEGIN(INITIAL);
}

/************************** End Scanner File *****************************/

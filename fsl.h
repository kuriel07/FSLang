
#if !defined( FSL__H )

typedef union semrec
{
	char string[4096];
	int value;
} YYSTYPE;

#define P_INPUT			512
#define P_OUTPUT		513
#define P_VAR				514
#define P_CONST			515

#define P_ADD				516
#define P_SUB				517
#define P_MUL				518
#define P_DIV				519

#define P_ASSIGNMENT		520
#define P_EOS					521
#define P_STRING			523 

extern YYSTYPE yylval;
extern int errors;

#define FSL__H
#endif
